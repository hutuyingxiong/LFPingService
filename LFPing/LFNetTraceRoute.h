//
//  LFNetTraceRoute.h
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int TRACEROUTE_PORT = 30001;
static const int TRACEROUTE_MAX_TTL = 30;
static const int TRACEROUTE_ATTEMPTS = 3;
static const int TRACEROUTE_TIMEOUT = 5000000;

/*
 * @protocal LFNetTraceRouteDelegate监测TraceRoute命令的的输出到日志变量；
 *
 */
@protocol LFNetTraceRouteDelegate <NSObject>
- (void)appendRouteLog:(NSString *)routeLog;
- (void)traceRouteDidEnd;
@end


/*
 * @class LFNetTraceRoute TraceRoute网络监控
 * 主要是通过模拟shell命令traceRoute的过程，监控网络站点间的跳转
 * 默认执行20转，每转进行三次发送测速
 */
@interface LFNetTraceRoute : NSObject {
    int udpPort;      //执行端口
    int maxTTL;       //执行转数
    int readTimeout;  //每次发送时间的timeout
    int maxAttempts;  //每转的发送次数
    NSString *running;
    bool isrunning;
}

@property (nonatomic, weak) id<LFNetTraceRouteDelegate> delegate;

/**
 * 初始化
 */
- (LFNetTraceRoute *)initWithMaxTTL:(int)ttl timeout:(int)timeout maxAttempts:(int)attempts port:(int)port;

/**
 * 监控tranceroute 路径
 */
- (Boolean)doTraceRoute:(NSString *)host;

/**
 * 停止traceroute
 */
- (void)stopTrace;
- (bool)isRunning;

@end
