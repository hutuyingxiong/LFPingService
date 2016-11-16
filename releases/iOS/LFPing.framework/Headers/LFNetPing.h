//
//  LFNetPing.h
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFSimplePing.h"

/*
 * @protocal LFNetPingDelegate监测Ping命令的的输出到日志变量；
 *
 */
@protocol LFNetPingDelegate <NSObject>
- (void)appendPingLog:(NSString *)pingLog;
- (void)netPingDidEnd;
@end


/*
 * @class LFNetPing ping监控
 * 主要是通过模拟shell命令ping的过程，监控目标主机是否连通
 * 连续执行五次，因为每次的速度不一致，可以观察其平均速度来判断网络情况
 */
@protocol LFSimplePingDelegate;
@interface LFNetPing : NSObject <LFSimplePingDelegate> {
}

@property (nonatomic, weak, readwrite) id<LFNetPingDelegate> delegate;


- (void)runWithHostName:(NSString *)hostName normalPing:(BOOL)normalPing;

- (void)stopPing;

@end