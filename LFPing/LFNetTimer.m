//
//  LFNetTimer.m
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#include <sys/time.h>
#import "LFNetTimer.h"

@implementation LFNetTimer

/**
 * 返回时间
 */
+ (long)getMicroSeconds
{
    struct timeval time;
    gettimeofday(&time, NULL);
    return time.tv_usec;
}

/**
 * 计算时间间隔
 */
+ (long)computeDurationSince:(long)uTime
{
    long now = [LFNetTimer getMicroSeconds];
    if (now < uTime) {
        return 1000000 - uTime + now;
    }
    return now - uTime;
}


@end
