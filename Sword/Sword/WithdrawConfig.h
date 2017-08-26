//
//  WithdrawConfig.h
//  Sword
//
//  Created by haorenjie on 2017/7/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WithdrawConfig : NSObject

// 最高可提现金额
@property (strong, nonatomic) NSDecimalNumber *maxCash;
// 最低可提现金额
@property (strong, nonatomic) NSDecimalNumber *minCash;
// 今日可提次数
@property (assign, nonatomic) NSInteger canCashCount;
// 单日提现次数上限
@property (assign, nonatomic) NSInteger dayCashCountLimit;
// 单日剩余可提现的金额
@property (strong, nonatomic) NSDecimalNumber *dayCanCashAmount;
// 单月剩余可提现金额
@property (strong, nonatomic) NSDecimalNumber *monthCanCashAmount;
// 单日提现金额上限
@property (strong, nonatomic) NSDecimalNumber *dayCashAmountLimit;
// 单月提现金额上限
@property (strong, nonatomic) NSDecimalNumber *monthCashAmountLimit;

@end
