//
//  AssetInfo.h
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RegularAsset;
@class CurrentAsset;

@interface AssetInfo : NSObject

// 账户余额
@property (strong, nonatomic) NSDecimalNumber *balance;
// 提现冻结
@property (strong, nonatomic) NSDecimalNumber *withdrawFrozenAmount;
// 定期资产
@property (strong, nonatomic) RegularAsset *regularAsset;
// 活期资产
@property (strong, nonatomic) CurrentAsset *currentAsset;
// 总资产
@property (strong, nonatomic, readonly) NSDecimalNumber *totalAmount;

@end

@interface RegularAsset : NSObject

// 代收本金
@property (strong, nonatomic) NSDecimalNumber *tobeReceivedPrincipal;
// 代收利息
@property (strong, nonatomic) NSDecimalNumber *tobeReceivedInterest;
// 投资冻结
@property (strong, nonatomic) NSDecimalNumber *investFrozenAmount;
// 累计收益
@property (strong, nonatomic) NSDecimalNumber *totalEarnings;
// 定期总资产
@property (strong, nonatomic, readonly) NSDecimalNumber *totalAmount;

@end

@interface CurrentAsset : NSObject

// 投资金额
@property (strong, nonatomic) NSDecimalNumber *investAmount;
// 累计（未结转）收益
@property (strong, nonatomic) NSDecimalNumber *addUpAmount;
// 申购冻结金额
@property (strong, nonatomic) NSDecimalNumber *purchaseFrozenAmount;
// 赎回冻结金额
@property (strong, nonatomic) NSDecimalNumber *redeemFrozenAmount;
// 活期总资产
@property (strong, nonatomic, readonly) NSDecimalNumber *totalAmount;
// 历史累计收益
@property (strong, nonatomic) NSDecimalNumber *historyAddUpAmount;
// 昨日收益
@property (strong, nonatomic) NSDecimalNumber *yesterdayEarnings;
// 可赎回金额
@property (strong, nonatomic, readonly) NSDecimalNumber *canRedeemAmount;

@end
