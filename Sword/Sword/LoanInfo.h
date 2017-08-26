//
//  MSInvestInfo.h
//  Sword
//
//  Created by haorenjie on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.

//  查询散标投资列表

#import <Foundation/Foundation.h>
#import "MSConsts.h"
#import "TermInfo.h"

@interface LoanInfo : NSObject

@property (assign, nonatomic) int loanId;           // 借款标识
@property (copy, nonatomic) NSString *title;        // 投资标题
@property (assign, nonatomic) double progress;      // 投标进度
@property (assign, nonatomic) double interest;      // 年利率
@property (assign, nonatomic) int startAmount;      // 起投金额
@property (assign, nonatomic) int classify;         // 标的类型 0.普通标 1.新手标，2.优选理财，3.散标
@property (strong, nonatomic) TermInfo *termInfo;   // 融资期限
@property (assign, nonatomic) int status;           // 300:立即投资， 301:即将开始， 500：已完成
@property (copy, nonatomic) NSString *statusName;   // 状态描述
@property (assign, nonatomic) int type;             // 标的类型 0：个人， 1：企业
@property (assign, nonatomic) NSUInteger redEnvelopeTypes;     // 可用红包的类型

@property (assign, nonatomic) double subjectAmount;     // 可投金额
@property (assign, nonatomic) double maxInvestLimit;    // 最高投资限额
@property (assign, nonatomic) NSTimeInterval deadline;  // 截止时间
@property (assign, nonatomic) NSTimeInterval raiseBeginTime;   // 募集开始时间
@property (assign, nonatomic) NSTimeInterval raiseEndTime;     // 募集结束时间

@property (assign, nonatomic) double salesRate;

- (void)merge:(LoanInfo *)loanInfo;

typedef NS_ENUM(NSInteger, LoanClassify) {
    CLASSIFY_NORMAL = 0,     // 普通标
    CLASSIFY_FOR_TIRO = 1,   // 新手标
    CLASSIFY_PREFERABLE = 2, // 优选理财
    CLASSIFY_SAN_MARK = 3,   // 散标
};

typedef NS_ENUM(NSInteger,  LoanStatus) {
    LOAN_STATUS_WILL_START = 301, // 即将开始
    LOAN_STATUS_INVEST_NOW = 300, // 立即投资
    LOAN_STATUS_COMPLETED = 500,  // 已抢光
    LOAN_STATUS_INVEST_END = 550, // 已结束
};

typedef NS_ENUM(NSInteger, LoanType) {
    LOAN_TYPE_PERSONAL = 0,
    LOAN_TYPE_COMPANY = 1,
};

@end

