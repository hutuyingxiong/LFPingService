//
//  ViewController.m
//  LFPingDemo
//
//  Created by 汪潇翔 on 16/11/2016.
//  Copyright © 2016 汪潇翔. All rights reserved.
//

#import "ViewController.h"
#import <LFPing/LFPing.h>

@interface ViewController ()<LFNetPingDelegate>

@property (nonatomic,strong)LFNetPing *ping;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LFNetPing *ping = [[LFNetPing alloc] init];
    ping.delegate = self;
    self.ping = ping;
    
    [ping runWithHostName:@"www.laifeng.com" normalPing:NO];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)appendPingLog:(NSString *)pingLog
{
    NSLog(@"PingLog:%@",pingLog);
}
- (void)netPingDidEnd
{
    
}

@end
