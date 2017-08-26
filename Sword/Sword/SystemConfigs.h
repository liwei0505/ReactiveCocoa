//
//  SystemConfigs.h
//  Sword
//
//  Created by lee on 16/6/2.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemConfigs : NSObject

@property (assign, nonatomic) double transferFee;           // 转让手续费
@property (assign, nonatomic) double maxFee;                // 手续费最大值
@property (assign, nonatomic) double minFee;                // 手续费最小值
@property (assign, nonatomic) double maxDiscountRate;       // 折让率最大值
@property (assign, nonatomic) double minDiscountRate;       // 折让率最小值
@property (assign, nonatomic) int minDaysAfterBought;       // 购买生效后不低于天数
@property (assign, nonatomic) int minDaysBeforeEndRepay;    // 距离还款结束不低于
@property (assign, nonatomic) long beginInvestAmount;       // 个人标起投金额
@property (assign, nonatomic) long increaseInvestAmount;    // 个人标递增金额
@property (copy, nonatomic) NSString *rechargeProtocolUrl;  // 充值协议链接

@end
