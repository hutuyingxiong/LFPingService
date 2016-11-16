//
//  LFNetConnect.m
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

#import "LFNetConnect.h"
#import "LFNetTimer.h"

#define MAXCOUNT_CONNECT 5

@interface LFNetConnect () {
    BOOL _isExistSuccess;  //监测是否有connect成功
    int _connectCount;     //当前执行次数
    
    int tcpPort;             //执行端口
    NSString *_hostAddress;  //目标域名的IP地址
    NSString *_resultLog;
    NSInteger _sumTime;
    CFSocketRef _socket;
    
    BOOL _isIPV6;
}

@property (nonatomic, assign) long _startTime;  //每次执行的开始时间

@end

@implementation LFNetConnect
@synthesize _startTime;

- (void)stopConnect
{
    _connectCount = MAXCOUNT_CONNECT + 1;
}

- (void)runWithHostAddress:(NSString *)hostAddress port:(int)port
{
    _hostAddress = hostAddress;
    _isIPV6 = [_hostAddress rangeOfString:@":"].location == NSNotFound?NO:YES;
    tcpPort = port;
    _isExistSuccess = FALSE;
    _connectCount = 0;
    _sumTime = 0;
    _resultLog = @"";
    if (self.delegate && [self.delegate respondsToSelector:@selector(appendSocketLog:)]) {
        [self.delegate appendSocketLog:[NSString stringWithFormat:@"connect to host %@ ...", _hostAddress]];
    }
    _startTime = [LFNetTimer getMicroSeconds];
    [self connect];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while (_connectCount < MAXCOUNT_CONNECT);
}

///**
// * socket连接
// */
//- (void)connect{
//    CFSocketContext CTX = {0, (__bridge_retained void *)(self), NULL, NULL, NULL};
//    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP,kCFSocketConnectCallBack, TCPServerConnectCallBack, &CTX);
//    
//    struct sockaddr_in addr;
//    memset(&addr, 0, sizeof(addr));
//    addr.sin_len = sizeof(addr);
//    addr.sin_family = AF_INET;
//    addr.sin_port = htons(tcpPort);
//    addr.sin_addr.s_addr = inet_addr([_hostAddress UTF8String]);
//    
//    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr, sizeof(addr));
//    
//    CFSocketConnectToAddress(_socket, address, 3);
//    CFRelease(address);
//    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
//    CFRunLoopSourceRef source =
//    CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, _connectCount);  //定义循环对象
//    CFRunLoopAddSource(cfrl, source, kCFRunLoopDefaultMode);  //将循环对象加入当前循环中
//    CFRelease(source);
//}

/**
 * 建立socket对hostaddress进行连接
 */
- (void)connect
{
    NSData *addrData = nil;
    
    //设置地址
    if (!_isIPV6) {
        struct sockaddr_in nativeAddr4;
        memset(&nativeAddr4, 0, sizeof(nativeAddr4));
        nativeAddr4.sin_len = sizeof(nativeAddr4);
        nativeAddr4.sin_family = AF_INET;
        nativeAddr4.sin_port = htons(tcpPort);
        inet_pton(AF_INET, _hostAddress.UTF8String, &nativeAddr4.sin_addr.s_addr);
        addrData = [NSData dataWithBytes:&nativeAddr4 length:sizeof(nativeAddr4)];
    } else {
        struct sockaddr_in6 nativeAddr6;
        memset(&nativeAddr6, 0, sizeof(nativeAddr6));
        nativeAddr6.sin6_len = sizeof(nativeAddr6);
        nativeAddr6.sin6_family = AF_INET6;
        nativeAddr6.sin6_port = htons(tcpPort);
        inet_pton(AF_INET6, _hostAddress.UTF8String, &nativeAddr6.sin6_addr);
        addrData = [NSData dataWithBytes:&nativeAddr6 length:sizeof(nativeAddr6)];
    }
    
    if (addrData != nil) {
        [self connectWithAddress:addrData];
    }
}

-(void)connectWithAddress:(NSData *)addr{
    struct sockaddr *pSockAddr = (struct sockaddr *)[addr bytes];
    int addressFamily = pSockAddr->sa_family;
    
    //创建套接字
    CFSocketContext CTX = {0, (__bridge_retained void *)(self), NULL, NULL, NULL};
    _socket = CFSocketCreate(kCFAllocatorDefault, addressFamily, SOCK_STREAM, IPPROTO_TCP,
                             kCFSocketConnectCallBack, TCPServerConnectCallBack, &CTX);
    
    //执行连接
    CFSocketConnectToAddress(_socket, (__bridge CFDataRef)addr, 3);
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();  // 获取当前运行循环
    CFRunLoopSourceRef source =
    CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, _connectCount);  //定义循环对象
    CFRunLoopAddSource(cfrl, source, kCFRunLoopDefaultMode);  //将循环对象加入当前循环中
    CFRelease(source);
}

/**
 * connect回调函数
 */
static void TCPServerConnectCallBack(CFSocketRef socket, CFSocketCallBackType type,CFDataRef address, const void *data, void *info){
    if (data != NULL) {
        printf("connect");
        LFNetConnect *con = (__bridge_transfer LFNetConnect *)info;
        [con readStream:FALSE];
    } else {
        
        LFNetConnect *con = (__bridge_transfer LFNetConnect *)info;
        [con readStream:TRUE];
    }
}

/**
 * 返回后de操作
 */
- (void)readStream:(BOOL)success
{
    //    NSString *errorLog = @"";
    if (success) {
        _isExistSuccess = TRUE;
        NSInteger interval = [LFNetTimer computeDurationSince:_startTime] / 1000;
        _sumTime += interval;
        _resultLog = [_resultLog
                      stringByAppendingString:[NSString stringWithFormat:@"%d's time=%ldms, ",
                                               _connectCount + 1, (long)interval]];
    } else {
        _sumTime = 99999;
        _resultLog =
        [_resultLog stringByAppendingString:[NSString stringWithFormat:@"%d's time=超时, ",
                                             _connectCount + 1]];
    }
    if (_connectCount == MAXCOUNT_CONNECT - 1) {
        if (_sumTime >= 99999) {
            _resultLog = [_resultLog substringToIndex:[_resultLog length] - 1];
        } else {
            _resultLog = [_resultLog
                          stringByAppendingString:[NSString stringWithFormat:@"平均=%ldms",
                                                   (long)(_sumTime / 5)]];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(appendSocketLog:)]) {
            [self.delegate appendSocketLog:_resultLog];
        }
    }
    
    CFRelease(_socket);
    _connectCount++;
    if (_connectCount < MAXCOUNT_CONNECT) {
        _startTime = [LFNetTimer getMicroSeconds];
        [self connect];
        
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(connectDidEnd:)]) {
            [self.delegate connectDidEnd:_isExistSuccess];
        }
    }
}

@end
