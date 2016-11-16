//
//  LFNetTimer.h
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFNetTimer : NSObject {
}


/**
 * 返回时间
 */
+ (long)getMicroSeconds;


/**
 * 计算时间间隔
 */
+ (long)computeDurationSince:(long)uTime;
@end
