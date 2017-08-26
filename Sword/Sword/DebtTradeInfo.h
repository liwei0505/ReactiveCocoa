//
//  MSMyDebtListInfo.h
//  mobip2p
//
//  Created by lee on 16/5/18.
//  Copyright © 2016年 zkbc. All rights reserved.
//  我的债权

#import <Foundation/Foundation.h>
#import "DebtInfo.h"

@interface DebtTradeInfo : NSObject

@property (strong, nonatomic) DebtInfo *debtInfo;       // 债权信息
@property (copy, nonatomic) NSString *tradeDate;        // 交易时间
@property (copy, nonatomic) NSString *investDate;       // 投资时间
@property (assign, nonatomic) double incomingPrincipal; // 待收本金
@property (assign, nonatomic) double incomingInterest;  // 待收利息
@property (assign, nonatomic) double receivedPrincipal; // 已收本金
@property (assign, nonatomic) double receivedInterest;  // 已收利息

@end

