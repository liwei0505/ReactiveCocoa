//
//  RechargeConfig.m
//  Sword
//
//  Created by haorenjie on 2017/7/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RechargeConfig.h"

@implementation RechargeConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dayCanRechargeAmount = [NSDecimalNumber decimalNumberWithString:@"0"];
        self.monthCanRechargeAmount = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    return self;
}
@end
