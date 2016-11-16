//
//  LFNetDiagnoService.m
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "LFNetDiagnoService.h"
#import "LFNetPing.h"
#import "LFNetTraceRoute.h"
#import "LFNetGetAddress.h"
#import "LFNetTimer.h"
#import "LFNetConnect.h"

static NSString *const kPingOpenServerIP = @"";
static NSString *const kCheckOutIPURL = @"";

@interface LFNetDiagnoService () <LFNetPingDelegate, LFNetTraceRouteDelegate,LFNetConnectDelegate> {
    NSString *_userId;
    NSString *_diagnosisTime;
    NSString *_hardwareVersion;
    NSString *_systemVersion;
    NSString *_softwareVersion;
    NSString *_cameraPermission;
    NSString *_microphonePermission;
    NSInteger _addressNum;
    NSInteger _loopCount;
    NSArray *_addressArr;
    
    NETWORK_TYPE _curNetType;
    NSString *_localIp;
    NSString *_gatewayIp;
    NSArray *_dnsServers;
    NSArray *_hostAddress;
    
    NSMutableString *_logInfo;  //记录网络诊断log日志
    BOOL _connectSuccess;  //记录连接是否成功
    LFNetPing *_netPinger;
    LFNetTraceRoute *_traceRouter;
    LFNetConnect *_netConnect;
}

@end

@implementation LFNetDiagnoService
#pragma mark - public method
/**
 * 初始化网络诊断服务
 */
- (id)initWithUserId:(NSString *)userId diagnosisTime:(NSString *)time hardwareVersion:(NSString *)hardware systemVersion:(NSString *)system softwareVersion:(NSString *)software cameraPermission:(NSString *)camera microphonePermission:(NSString *)microphone dormain:(NSArray *)dormain{
    self = [super init];
    if (self) {
        _userId = userId;
        _diagnosisTime = time;
        _hardwareVersion = hardware;
        _systemVersion = system;
        _softwareVersion = software;
        _cameraPermission = camera;
        _microphonePermission = microphone;
        _dormain =dormain[0];
        _addressArr = [NSArray arrayWithArray:dormain];
        _addressNum = dormain.count;
        _loopCount=0;
        
        _logInfo = [[NSMutableString alloc] initWithCapacity:20];
    }
    return self;
}

/**
 * 开始诊断网络
 */
- (void)startNetDiagnosis
{
    _dormain = _addressArr[_loopCount];
    if (!_dormain || [_dormain isEqualToString:@""])
        return;
    
    [_logInfo setString:@""];
    [self recordCurrentAppVersion];
    [self recordLocalNetEnvironment];
    
    //未联网不进行任何检测
    if (_curNetType == 0) {
        //        _isRunning = NO;
        [self recordStepInfo:@"\n当前主机未联网，请检查网络！"];
        [self recordStepInfo:@"\n网络诊断结束\n"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(netDiagnosisDidEnd:andProgress:)]) {
            [self.delegate netDiagnosisDidEnd:_logInfo andProgress:100];
        }
        return;
    }
    
    //    if (_isRunning) {
    //[self recordOutIPInfo];
    //    }
    
    //    if (_isRunning) {
    // connect诊断，同步过程, 如果TCP无法连接，检查本地网络环境
    _connectSuccess = NO;
    [self recordStepInfo:@"\n开始尝试TCP连接..."];
    if ([_hostAddress count] > 0) {
        _netConnect = [[LFNetConnect alloc] init];
        _netConnect.delegate = self;
        for (int i = 0; i < [_hostAddress count]; i++) {
            [_netConnect runWithHostAddress:[_hostAddress objectAtIndex:i] port:80];
        }
    } else {
        [self recordStepInfo:@"DNS解析失败"];
    }
    //jsw change 改动
    [self pingDialogsis:_connectSuccess];

    //开始诊断traceRoute
    [self recordStepInfo:@"\n开始traceroute..."];
    _traceRouter = [[LFNetTraceRoute alloc] initWithMaxTTL:TRACEROUTE_MAX_TTL timeout:TRACEROUTE_TIMEOUT maxAttempts:TRACEROUTE_ATTEMPTS port:TRACEROUTE_PORT];
    _traceRouter.delegate = self;
    if (_traceRouter) {
        [NSThread detachNewThreadSelector:@selector(doTraceRoute:) toTarget:_traceRouter withObject:_dormain];
    }

}

- (void)stopNetDialogsis{
    if (_netConnect != nil) {
        [_netConnect stopConnect];
        _netConnect = nil;
    }
    if (_netPinger != nil) {
        [_netPinger stopPing];
        _netPinger = nil;
    }
    if (_traceRouter != nil) {
        [_traceRouter stopTrace];
        _traceRouter = nil;
    }
}

- (void)printLogInfo
{
    
}


#pragma mark -
#pragma mark - private method

/*
 *  获取App相关信息
 */
- (void)recordCurrentAppVersion
{
    if (_loopCount>0) {
        return;
    }
    [self recordStepInfo:@"开始诊断...\n"];
    //输出应用版本信息和用户ID
    [self recordStepInfo:[NSString stringWithFormat:@"userId: %@", _userId]];
    
    [self recordStepInfo:[NSString stringWithFormat:@"诊断时间: %@", _diagnosisTime]];
    
    [self recordStepInfo:[NSString stringWithFormat:@"硬件版本: %@", _hardwareVersion]];
    [self recordStepInfo:[NSString stringWithFormat:@"系统版本: %@", _systemVersion]];
    [self recordStepInfo:[NSString stringWithFormat:@"软件版本: %@", _softwareVersion]];
    [self recordStepInfo:[NSString stringWithFormat:@"摄像头权限: %@", _cameraPermission]];
    [self recordStepInfo:[NSString stringWithFormat:@"麦克风权限: %@", _microphonePermission]];
}


/*
 *  获取本地网络环境信息
 */
- (void)recordLocalNetEnvironment
{
    [self recordStepInfo:[NSString stringWithFormat:@"\n\n诊断域名 %@...\n", _dormain]];
    //判断是否联网以及获取网络类型
    NSArray *typeArr = [NSArray arrayWithObjects:@"2G", @"3G", @"4G", @"5G", @"wifi", nil];
//    if(typeArr && typeArr.count >= _curNetType - 1){
    
    _curNetType = [LFNetGetAddress getNetworkTypeFromStatusBar];
    if (_curNetType == 0) {
        [self recordStepInfo:[NSString stringWithFormat:@"当前是否联网: 未联网"]];
    } else {
        [self recordStepInfo:[NSString stringWithFormat:@"当前是否联网: 已联网"]];
        if (_curNetType > 0 && _curNetType < 6) {
            [self
             recordStepInfo:[NSString stringWithFormat:@"当前联网类型: %@",
                             [typeArr objectAtIndex:_curNetType - 1]]];
        }
    }
    
    //本地ip信息
    _localIp = [LFNetGetAddress deviceIPAdress];
    [self recordStepInfo:[NSString stringWithFormat:@"当前本机IP: %@", _localIp]];
    
    if (_curNetType == NETWORK_TYPE_WIFI) {
        _gatewayIp = [LFNetGetAddress getGatewayIPAddress];
        [self recordStepInfo:[NSString stringWithFormat:@"本地网关: %@", _gatewayIp]];
    } else {
        _gatewayIp = @"";
    }
    
    
    _dnsServers = [NSArray arrayWithArray:[LFNetGetAddress outPutDNSServers]];
    [self recordStepInfo:[NSString stringWithFormat:@"本地DNS: %@",
                          [_dnsServers componentsJoinedByString:@", "]]];
    
    [self recordStepInfo:[NSString stringWithFormat:@"远端域名: %@", _dormain]];
    
    // host地址IP列表
    long time_start = [LFNetTimer getMicroSeconds];
    _hostAddress = [NSArray arrayWithArray:[LFNetGetAddress getDNSsWithDormain:_dormain]];
    long time_duration = [LFNetTimer computeDurationSince:time_start] / 1000;
    if ([_hostAddress count] == 0) {
        [self recordStepInfo:[NSString stringWithFormat:@"DNS解析结果: 解析失败"]];
    } else {
        [self
         recordStepInfo:[NSString stringWithFormat:@"DNS解析结果: %@ (%ldms)",
                         [_hostAddress componentsJoinedByString:@", "],
                         time_duration]];
    }
//    }
}

/**
 * 使用接口获取用户的出口IP和DNS信息
 */
- (void)recordOutIPInfo
{
    [self recordStepInfo:@"\n开始获取运营商信息..."];
    NSMutableURLRequest *request =[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kCheckOutIPURL]
                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                             timeoutInterval:10];
    
    // data是返回的数据
    NSError *error = nil;
    NSData *data =
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error != nil) {
        [self recordStepInfo:@"\n获取超时"];
        return;
    }
    NSString *response = [[NSString alloc] initWithData:data encoding:0x80000632];
    [self recordStepInfo:response];
}



- (void)pingDialogsis:(BOOL)pingLocal
{
    //诊断ping信息, 同步过程
    NSMutableArray *pingAdd = [[NSMutableArray alloc] init];
    NSMutableArray *pingInfo = [[NSMutableArray alloc] init];
    if (pingLocal) {
        [pingAdd addObject:_localIp];
        [pingInfo addObject:@"本机IP"];
        if (_gatewayIp && ![_gatewayIp isEqualToString:@""]) {
            [pingAdd addObject:_gatewayIp];
            [pingInfo addObject:@"本地网关"];
        }
        if ([_dnsServers count] > 0) {
            [pingAdd addObject:[_dnsServers objectAtIndex:0]];
            [pingInfo addObject:@"DNS服务器"];
        }
    }
    
    [self recordStepInfo:@"\n开始ping..."];
    _netPinger = [[LFNetPing alloc] init];
    _netPinger.delegate = self;
    for (int i = 0; i < [pingAdd count]; i++) {
        [self recordStepInfo:[NSString stringWithFormat:@"ping: %@ %@ ...",
                              [pingInfo objectAtIndex:i],
                              [pingAdd objectAtIndex:i]]];
        if ([[pingAdd objectAtIndex:i] isEqualToString:kPingOpenServerIP]) {
            [_netPinger runWithHostName:[pingAdd objectAtIndex:i] normalPing:NO];
        } else {
            [_netPinger runWithHostName:[pingAdd objectAtIndex:i] normalPing:YES];
        }
    }
}

#pragma mark - netPingDelegate

- (void)appendPingLog:(NSString *)pingLog
{
    [self recordStepInfo:pingLog];
}

- (void)netPingDidEnd
{
    //
}

#pragma mark - traceRouteDelegate
- (void)appendRouteLog:(NSString *)routeLog
{
    [self recordStepInfo:routeLog];
}

- (void)traceRouteDidEnd
{
    _loopCount++;
    if (self.delegate && [self.delegate respondsToSelector:@selector(netDiagnosisDidEnd:andProgress:)]) {
        [self.delegate netDiagnosisDidEnd:_logInfo andProgress:100*_loopCount/_addressNum];
    }
    if (_loopCount == _addressNum) {
        //        _isRunning = NO;
        [self recordStepInfo:@"\n网络诊断结束\n"];
        return;
    }else{
        [self startNetDiagnosis];
    }
}

#pragma mark - connectDelegate
- (void)appendSocketLog:(NSString *)socketLog
{
    [self recordStepInfo:socketLog];
}

- (void)connectDidEnd:(BOOL)success
{
    if (success) {
        _connectSuccess = YES;
    }
}


#pragma mark - common method
/**
 * 输出信息
 */
- (void)recordStepInfo:(NSString *)stepInfo
{
    if (stepInfo == nil) stepInfo = @"";
    [_logInfo appendString:stepInfo];
    [_logInfo appendString:@"\n"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(netDiagnosisStepInfo:)]) {
        [self.delegate netDiagnosisStepInfo:[NSString stringWithFormat:@"%@\n", stepInfo]];
    }
}

@end
