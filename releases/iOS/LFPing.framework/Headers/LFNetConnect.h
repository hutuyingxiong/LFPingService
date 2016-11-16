//
//  LFNetConnect.h
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * @protocal LFNetConnectDelegate监测connect命令的的输出到日志变量；
 *
 */
@protocol LFNetConnectDelegate <NSObject>
- (void)appendSocketLog:(NSString *)socketLog;
- (void)connectDidEnd:(BOOL)success;
@end


/*
 * @class LFNetConnect ping监控
 * 主要是通过建立socket连接的过程，监控目标主机是否连通
 * 连续执行五次，因为每次的速度不一致，可以观察其平均速度来判断网络情况
 */
@interface LFNetConnect : NSObject {
}

@property (nonatomic, weak) id<LFNetConnectDelegate> delegate;
/**
 * 通过hostaddress和port 进行connect诊断
 */
- (void)runWithHostAddress:(NSString *)hostAddress port:(int)port;
- (void)stopConnect;

@end

