//
//  RechargeConfig.h
//  Sword
//
//  Created by haorenjie on 2017/7/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RechargeConfig : NSObject

// 单日剩余可充值金额
@property (strong, nonatomic) NSDecimalNumber *dayCanRechargeAmount;
// 单月剩余可充值金额
@property (strong, nonatomic) NSDecimalNumber *monthCanRechargeAmount;

@end
