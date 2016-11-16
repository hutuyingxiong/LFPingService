//
//  DiagnosisManager.h
//  SystemDiagnosis
//
//  Created by 姜淞文 on 16/3/8.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 硬件信息管理
 */
@interface DiagnosisManager : NSObject
+ (instancetype)shareManager;
@property (nonatomic,copy)void(^managerBlock)();
/**
 *  返回诊断时间
 */
-(NSString *)formatterNoSecondsFullDate;
/**
 * 返回硬件版本
 */
- (NSString *)getHardwareVersion;
/**
 * 返回系统版本
 */
- (NSString *)getSystemVersion;
/**
 * 返回软件版本
 */
- (NSString *)getSoftwareVersion;
/**
 * 摄像头权限
 */
- (NSString *)getCameraPermission;
/**
 * 麦克风权限
 */
- (NSString *)getMicrophonePermission;

@end
