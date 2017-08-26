//
//  MSMyInvestInfo.h
//  mobip2p
//
//  Created by lee on 16/5/18.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoanDetail.h"

@interface InvestInfo : NSObject

@property (assign, nonatomic) int investId;             // 投标标识
@property (assign, nonatomic) double investAmount;      // 投资金额
@property (copy, nonatomic) NSString *investDate;       // 投资日期
@property (copy, nonatomic) NSString *endDate;          // 结束时间
@property (assign, nonatomic) double netIncome;         // 净收益
@property (assign, nonatomic) double nextAmount;        // 待还本息
@property (assign, nonatomic) double repayedAmount;     // 已还本息
@property (copy, nonatomic) NSString *productType;      // 产品类型
@property (copy, nonatomic) NSString *nextRepayDate;    // 下一还款日
@property (assign, nonatomic) NSTimeInterval repayDate; // 还款日期
@property (strong, nonatomic) LoanInfo *loanInfo;       // 借款信息


@end

