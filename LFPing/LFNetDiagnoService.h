//
//  LFNetDiagnoService.h
//  SystemDiagnosisTool
//
//  Created by 姜淞文 on 16/3/9.
//  Copyright © 2016年 姜淞文. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @protocol 监控网络诊断的过程信息
 *
 */
@protocol LFNetDiagnoServiceDelegate <NSObject>
/**
 * 诊断开始
 */
- (void)netDiagnosisDidStarted;


/**
 * 逐步返回监控信息，
 * 如果需要实时显示诊断数据，实现此接口方法
 */
- (void)netDiagnosisStepInfo:(NSString *)stepInfo;


/**
 * 因为监控过程是一个异步过程，当监控结束后告诉调用者；
 * 在监控结束的时候，对监控字符串进行处理
 */
- (void)netDiagnosisDidEnd:(NSString *)allLogInfo andProgress:(NSInteger )progress;

@end


/**
 * @class 网络诊断服务
 * 通过对指定域名进行ping诊断和traceRoute诊断收集诊断日志
 */
@interface LFNetDiagnoService : NSObject {
}
@property (nonatomic, weak, readwrite)
id<LFNetDiagnoServiceDelegate> delegate;      //向调用者输出诊断信息接口
@property (nonatomic, retain) NSString *dormain;  //接口域名

/**
 * 初始化网络诊断服务
 * theAppCode,theUID, theDormain为必填项
 */
- (id)initWithUserId:(NSString *)userId diagnosisTime:(NSString *)time hardwareVersion:(NSString *)hardware systemVersion:(NSString *)system softwareVersion:(NSString *)software cameraPermission:(NSString *)camera microphonePermission:(NSString *)microphone dormain:(NSArray *)dormain;
/**
 * 开始诊断网络
 */
- (void)startNetDiagnosis;


/**
 * 停止诊断网络
 */
- (void)stopNetDialogsis;


/**
 * 打印整体loginInfo；
 */
- (void)printLogInfo;

@end
