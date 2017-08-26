//
//  DebtListInfo.h
//  mobip2p
//
//  Created by lw on 16/5/29.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"
#import "LoanDetail.h"

@interface DebtInfo : NSObject

@property (assign, nonatomic) int debtId;                   // 债权标识
@property (assign, nonatomic) int borrowId;                 // 借款人标识
@property (copy, nonatomic) NSString *annualInterestRate;   // 年化利率
@property (assign, nonatomic) int leftTermCount;            // 剩余期限(数字)
@property (copy, nonatomic) NSString *termCount;            // 年化利率(字符串)
@property (copy, nonatomic) NSString *soldPrice;            // 转让价格
@property (copy, nonatomic) NSString *nextRepayDate;        // 期还款日
@property (copy, nonatomic) NSString *value;                // 债权价值
@property (copy, nonatomic) NSString *nextAmount;           // 下期还款金额
@property (assign, nonatomic) DebtStatus status;            // 转让状态 1:转让中 2:已结束
@property (assign, nonatomic) double earnings;              // 待收本息
@property (copy, nonatomic) NSString *fee;                  // 手续费
@property (assign, nonatomic) int canBeTrasfer;             // 是否可以转让 0：不可以 1：可以
@property (strong, nonatomic) LoanDetail *loanInfo;           // 借款信息

- (void)merge:(DebtInfo *)debtInfo;

@end
