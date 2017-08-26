//
//  WithdrawConfig.m
//  Sword
//
//  Created by haorenjie on 2017/7/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "WithdrawConfig.h"

@implementation WithdrawConfig

- (instancetype)init {
    if (self = [super init]) {
        _maxCash = [NSDecimalNumber decimalNumberWithString:@"-1"];
        _minCash = [NSDecimalNumber decimalNumberWithString:@"-1"];
        _dayCanCashAmount = [NSDecimalNumber decimalNumberWithString:@"-1"];
        _monthCanCashAmount = [NSDecimalNumber decimalNumberWithString:@"-1"];
        _dayCashAmountLimit = [NSDecimalNumber decimalNumberWithString:@"-1"];
        _monthCashAmountLimit = [NSDecimalNumber decimalNumberWithString:@"-1"];
    }
    return self;
}

@end
