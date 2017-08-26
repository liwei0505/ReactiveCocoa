//
//  MSLoanDetailInfo.h
//  mobip2p
//
//  Created by lw on 16/5/15.
//  Copyright © 2016年 zkbc. All rights reserved.

//  标详情

#import <Foundation/Foundation.h>
#import "LoanInfo.h"
#import "ProjectInfo.h"

typedef NS_ENUM(NSUInteger, LoanLimitType) {
    LOAN_LIMIT_NONE = 0,   // 不限
    LOAN_LIMIT_SINGLE = 1, // 单笔限额
    LOAN_LIMIT_ADD_UP = 2, // 累计限额
};

@interface LoanDetail : NSObject

@property (strong, nonatomic) LoanInfo *baseInfo;       // 基本信息
@property (assign, nonatomic) int borrowId;             // 借款人ID
@property (assign, nonatomic) double totalAmount;       // 标的总额
@property (copy, nonatomic) NSString *safeType;         // 保障方式
@property (copy, nonatomic) NSString *repayType;        // 还款方式
@property (copy, nonatomic) NSString *repayNumber;      // 还款到账日＝止息日＋N,该值为N
@property (copy, nonatomic) NSString *monthlyAmount;    // 月还本息
@property (copy, nonatomic) NSString *prepayment;       // 提前还款费率
@property (assign, nonatomic) long increaseAmount;      // 递增金额
@property (copy, nonatomic) NSString *countdownName;    // 倒计时名称
@property (assign, nonatomic) long countdownNumber;     // 倒计时时间
@property (copy, nonatomic) NSString *interestBeginTime;// 起息日
@property (copy, nonatomic) NSString *interestEndTime;  // 止息日
@property (assign, nonatomic) LoanLimitType loanLimit;  // 投资类型限制

@property (readonly, nonatomic) BOOL hasDetail;
@property (strong, nonatomic) ProductInfo *productInfo;
@property (assign, nonatomic) double rate;

#pragma mark -- 协议中没有返回这些属性

@property (copy, nonatomic) NSString *use;              // 借款用途
@property (copy, nonatomic) NSString *debtCloseDays;    // 转让属性
//@property (assign, nonatomic) int redEnvelopeTypes;     // 可用红包的类型

#pragma mark -- 520之后的版本支持
@property (copy, nonatomic) NSString *contractName;     // 协议名称

//募集完成时间
@property (assign, nonatomic) NSTimeInterval fullTime;
//投资记录总数
@property (assign, nonatomic) NSInteger loanInvestorTotalCount;

- (void)merge:(LoanDetail *)loanDetail;

@end
