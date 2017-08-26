//
//  MSFinanceService.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMJSProtocol.h"

@class MSListWrapper, LoanDetail, MSInvestRecordList, DebtDetail;
#pragma mark - MSFinanceCache
@interface MSFinanceCache : NSObject
@property (strong, nonatomic) NSMutableDictionary *investDict;
@property (strong, nonatomic) MSListWrapper *recommenedList; // invest ID list
@property (strong, nonatomic) MSListWrapper *investList;     // invest ID list

@property (strong, nonatomic) NSMutableDictionary *attornDict;
@property (strong, nonatomic) NSMutableArray *attornList;     // attorn ID list
@property (assign, nonatomic) NSInteger totalAttornItemCount;
@property (assign, nonatomic) BOOL hasMoreAttorns;
- (BOOL)hasMoreAttorns;

@property (strong, nonatomic) NSMutableDictionary *investRecordDict;

@end

#pragma mark - MSFinanceService
@interface MSFinanceService : NSObject

@property (strong, nonatomic, readonly) MSFinanceCache *financeCache;

- (instancetype)initWithProtocol:(id<IMJSProtocol>) protocol;

//首页推荐列表
- (RACSignal *)queryRecommendedList;
//投资列表
- (RACSignal *)queryLoanListByType:(ListRequestType)type;
- (LoanDetail *)getLoanInfo:(NSNumber *)loanId;

- (RACSignal *)queryLoanDetailById:(NSNumber *)loanId;
- (RACSignal *)queryMyInvestedAmount:(NSNumber *)loanId;
- (RACSignal *)queryProjectInstructionByType:(ProjectInstructionType)type loanId:(NSNumber *)loanId;
- (RACSignal *)queryLoanInvestorListByType:(ListRequestType)type loanId:(NSNumber *)loanId;
- (MSInvestRecordList *)getInvestRecords:(NSNumber *)loanId;
- (RACSignal *)queryInvestContractByLoanId:(NSNumber *)loanId;

// 认购列表
- (RACSignal *)queryDebtListByType:(ListRequestType)type;
- (BOOL)isShouldQueryDebtList;
- (NSInteger)getDebtListCount;
- (NSNumber *)getDebtIdWithIndex:(NSInteger)index;
- (BOOL)hasMoreAttorns;
- (DebtDetail *)getDebtInfo:(NSNumber *)debtId;

- (RACSignal *)queryDebtDetailById:(NSNumber *)debtId;
- (RACSignal *)queryDebtAgreementById:(NSNumber *)debtId;
// Transfer apply protocol
- (NSString *)getInvestAgreementById:(NSNumber *)debtId;

- (void)addLoanInfo:(LoanInfo *)loanInfo;

@end
