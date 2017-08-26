//
//  MSFinanceService.m
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSFinanceService.h"
#import "InvestRecord.h"
#import "MSConfig.h"
#import "RACError.h"
#import "MSLog.h"
#import "DebtAgreementInfo.h"

@interface MSFinanceService()
{
    id<IMJSProtocol> _protocol;
}

@end

@implementation MSFinanceService

- (instancetype)initWithProtocol:(id<IMJSProtocol>)protocol {
    if (self = [super init]) {
        _protocol = protocol;
        _financeCache = [[MSFinanceCache alloc] init];
    }
    return self;
}

- (RACSignal *)queryRecommendedList {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[_protocol queryRecommendedList] subscribeNext:^(NSArray *list) {
            NSArray *localRecommenedList = [self.financeCache.recommenedList getList];
            for (NSNumber *loanId in localRecommenedList) {
                [self.financeCache.investDict removeObjectForKey:loanId];
            }
            [self.financeCache.recommenedList clear];
            NSMutableArray *loanIdList = [[NSMutableArray alloc] initWithCapacity:list.count];
            for (LoanInfo *loanInfo in list) {
                [self addLoanInfo:loanInfo];
                [loanIdList addObject:@(loanInfo.loanId)];
            }
            [self.financeCache.recommenedList addList:loanIdList];
            
            [subscriber sendNext:list];
        } error:^(NSError *error) {
            RACError *result = (RACError *)error;
            [MSLog error:@"Query Recommended list failed, error:%d, message:%@", result.result, result.message];
            [subscriber sendError:result];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

#pragma mark - loan info
- (RACSignal *)queryLoanListByType:(ListRequestType)type {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        NSInteger pageIndex = 1;
        if (LIST_REQUEST_MORE == type) {
            pageIndex = [self.financeCache.investList getNextPageIndex];
            if (pageIndex < 0) {
                [subscriber sendCompleted];
                return nil;
            }
        }

        [[_protocol queryInvestList:(int)pageIndex size:MS_PAGE_SIZE type:type] subscribeNext:^(NSDictionary *dic) {
            @strongify(self);
            ListRequestType type = [dic[TYPE] intValue];
            NSMutableArray *list = dic[LIST];
            
            if (type == LIST_REQUEST_NEW) {
                NSArray *localIDList = [self.financeCache.investList getList];
                for (NSNumber *loanId in localIDList) {
                    [self.financeCache.investDict removeObjectForKey:loanId];
                }
                [self.financeCache.investList clear];
            }

            NSMutableArray *loanIdList = [[NSMutableArray alloc] initWithCapacity:list.count];
            for (LoanInfo *loanInfo in list) {
                [self addLoanInfo:loanInfo];
                [loanIdList addObject:@(loanInfo.loanId)];
            }
            [self.financeCache.investList addList:loanIdList];
            
            [subscriber sendNext:dic];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (LoanDetail *)getLoanInfo:(NSNumber *)loanId{
    return [self.financeCache.investDict objectForKey:loanId];
}

- (MSInvestRecordList *)getInvestRecords:(NSNumber *)loanId{
    return [self.financeCache.investRecordDict objectForKey:loanId];
}

- (void)queryLoanDetailById_:(NSNumber *)loanId{
    
    [[_protocol queryLoanDetail:loanId.intValue] subscribeNext:^(id x) {
        LoanDetail *loanDetail = (LoanDetail *)x;
        [self addLoanDetail:loanDetail];
    } error:^(NSError *error) {
        
    } completed:^{
        
    }];
    
}

- (RACSignal *)queryLoanDetailById:(NSNumber *)loanId {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       [[_protocol queryLoanDetail:loanId.intValue] subscribeNext:^(id x) {
           LoanDetail *loanDetail = (LoanDetail *)x;
           [self addLoanDetail:loanDetail];
        
           [subscriber sendNext:@(loanDetail.baseInfo.loanId)];
       } error:^(NSError *error) {
           RACError *result = (RACError *)error;
           [MSLog error:@"Query invest detail failed, result: %d", result.result];
           [subscriber sendError:result];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
        return nil;
    }];
}

- (RACSignal *)queryMyInvestedAmount:(NSNumber *)loanId {
    return [_protocol queryMyInvestedAmount:loanId];
}

- (RACSignal *)queryProjectInstructionByType:(ProjectInstructionType)type loanId:(NSNumber *)loanId {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryProjectInstruction:loanId.intValue type:type] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = (NSDictionary *)x;
            int type_ = [dic[TYPE] intValue];
            NSNumber *loanId_ = dic[LOANID];
            NSString *content = dic[CONTENT];
            NSArray *list = dic[LIST];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:loanId_ forKey:KEY_LOAN_ID];
            [params setObject:[NSNumber numberWithInt:type_] forKey:KEY_INSTRUCTION_TYPE];
            
            LoanDetail *loanInfo = [self getLoanInfo:loanId_];
            if (!loanInfo.productInfo) {
                loanInfo.productInfo = [ProductInfo new];
            }
            
            loanInfo.productInfo.productFileArray = list;
            
            if (type_ == INSTRUCTION_TYPE_COMPANY_INTRODUCTION) {
                loanInfo.productInfo.projectInfo.content = content;
            } else if (type_ == INSTRUCTION_TYPE_RISK_WARNING) {
                loanInfo.productInfo.riskDisclosure = content;
            } else if (type_ == INSTRUCTION_TYPE_DISCLAIMER) {
                loanInfo.productInfo.disclaimer = content;
            } else if (type_ == INSTRUCTION_TYPE_TRADING_MANUAL) {
                loanInfo.productInfo.tradingManual = content;
            } else if (type_ == INSTRUCTION_TYPE_INVEST_CONTRACT) {
                [params setObject:content forKey:KEY_CONTRACT_CONTENT];
            } else {
                [MSLog warning:@"Unexpected instruction type: %d", type_];
            }
            
            [subscriber sendNext:params];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryLoanInvestorListByType:(ListRequestType)type loanId:(NSNumber *)loanId {
    MSInvestRecordList *recordList = [self getInvestRecords:loanId];
    int lastInvestorId;
    if (LIST_REQUEST_NEW == type) {
        if (recordList) {
            [recordList reset];
        }
        lastInvestorId = 0;
    } else {
        lastInvestorId = ((InvestRecord *)recordList.records.lastObject).inverstorId;
    }
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryInvestRecordList:lastInvestorId size:MS_PAGE_SIZE loanId:loanId.intValue] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = (NSDictionary *)x;
            NSNumber *loanId_ = dic[LOANID];
            NSMutableArray *investList = dic[LIST];
            
            MSInvestRecordList *investRecordList = [self getInvestRecords:loanId_];
            if (!investRecordList) {
                investRecordList = [MSInvestRecordList new];
                [self.financeCache.investRecordDict setObject:investRecordList forKey:loanId_];
            }
            
            investRecordList.loanId = loanId_;
            investRecordList.hasMore = investList.count >= MS_PAGE_SIZE;
            [investRecordList addRecords:investList];
            
            [subscriber sendNext:loanId_];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryInvestContractByLoanId:(NSNumber *)loanId {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       [[_protocol queryContractTemplate:loanId.intValue] subscribeNext:^(id x) {
           NSDictionary *dic = (NSDictionary *)x;
           int type = [dic[TYPE] intValue];
           NSString *content = dic[CONTENT];
           NSNumber *loanId_ = dic[LOANID];
           
           NSMutableDictionary *params = [NSMutableDictionary new];
           [params setObject:loanId_ forKey:KEY_LOAN_ID];
           [params setObject:@(type) forKey:KEY_INSTRUCTION_TYPE];
           
           LoanDetail *loanInfo = [self getLoanInfo:loanId_];
           if (!loanInfo.productInfo) {
               loanInfo.productInfo = [ProductInfo new];
           }
           
           loanInfo.productInfo.productFileArray = nil;
           
           if (type == INSTRUCTION_TYPE_COMPANY_INTRODUCTION) {
               loanInfo.productInfo.projectInfo.content = content;
           } else if (type == INSTRUCTION_TYPE_RISK_WARNING) {
               loanInfo.productInfo.riskDisclosure = content;
           } else if (type == INSTRUCTION_TYPE_DISCLAIMER) {
               loanInfo.productInfo.disclaimer = content;
           } else if (type == INSTRUCTION_TYPE_TRADING_MANUAL) {
               loanInfo.productInfo.tradingManual = content;
           } else if (type == INSTRUCTION_TYPE_INVEST_CONTRACT) {
               [params setObject:content forKey:KEY_CONTRACT_CONTENT];
           } else {
               [MSLog warning:@"Unexpected instruction type: %d", type];
           }
           
           [subscriber sendNext:params];
       } error:^(NSError *error) {
           [subscriber sendError:error];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
        return nil;
    }];
}

#pragma mark - debt info
- (RACSignal *)queryDebtListByType:(ListRequestType)type {
    int pageIndex;
    if (LIST_REQUEST_NEW == type) {
        pageIndex = 1;
    } else {
        pageIndex = (int)self.financeCache.attornList.count / MS_PAGE_SIZE + 1;
    }
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryDebtList:pageIndex size:MS_PAGE_SIZE type:type] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = (NSDictionary *)x;
            ListRequestType type = [dic[TYPE] intValue];
            int totalCount = [dic[TOTALCOUNT] intValue];
            NSMutableArray *list = dic[LIST];
            
            self.financeCache.totalAttornItemCount = totalCount;
            self.financeCache.hasMoreAttorns = (list.count >= MS_PAGE_SIZE);
            
            if (type == LIST_REQUEST_NEW) {
                for (NSNumber *debtId in self.financeCache.attornList) {
                    [self.financeCache.attornDict removeObjectForKey:debtId];
                }
                [self.financeCache.attornList removeAllObjects];
            }
            
            for (DebtInfo *debtInfo in list) {
                [self addDebtInfo:debtInfo];
                [self.financeCache.attornList addObject:@(debtInfo.debtId)];
            }
            
            [subscriber sendNext:dic];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (BOOL)isShouldQueryDebtList{
    return (self.financeCache.attornList.count > 0) ? NO : YES;
}
- (NSInteger)getDebtListCount{
    return  self.financeCache.attornList.count;
}
- (NSNumber *)getDebtIdWithIndex:(NSInteger)index{
    return self.financeCache.attornList[index];
}
- (BOOL)hasMoreAttorns{
    return [self.financeCache hasMoreAttorns];
}

- (DebtDetail *)getDebtInfo:(NSNumber *)debtId{
    return [self.financeCache.attornDict objectForKey:debtId];
}

- (RACSignal *)queryDebtDetailById:(NSNumber *)debtId {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       [[_protocol queryDebtDetail:debtId.intValue] subscribeNext:^(id x) {

           @strongify(self);
           DebtDetail *debtDetail = (DebtDetail *)x;
           NSNumber *loanId = [NSNumber numberWithInt:debtDetail.baseInfo.loanInfo.baseInfo.loanId];
           LoanDetail *loanInfo = [self getLoanInfo:loanId];
           if (!loanInfo || !loanInfo.hasDetail) {
               [self queryLoanDetailById_:loanId];
           }
           [self addDebtDetail:debtDetail];
           
           [subscriber sendNext:@(debtDetail.baseInfo.debtId)];
       } error:^(NSError *error) {
           [subscriber sendError:error];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
        return nil;
    }];
}

- (RACSignal *)queryDebtAgreementById:(NSNumber *)debtId {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[_protocol queryDebtAgreementInfo:debtId.integerValue] subscribeNext:^(DebtAgreementInfo *debtAgreementInfo) {
            [subscriber sendNext:debtAgreementInfo];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (NSString *)getInvestAgreementById:(NSNumber *)debtId {
    return [_protocol getInvestAgreementById:debtId];
}

- (void)addLoanInfo:(LoanInfo *)loanInfo
{
    LoanDetail *loanDetail = [LoanDetail new];
    loanDetail.baseInfo = loanInfo;
    [self addLoanDetail:loanDetail];
}

#pragma mark - private methods
- (void)addLoanDetail:(LoanDetail *)loanDetail
{
    NSNumber *loanId = [NSNumber numberWithInt:loanDetail.baseInfo.loanId];
    LoanDetail *localLoanDetail = [self.financeCache.investDict objectForKey:loanId];
    if (localLoanDetail) {
        [loanDetail.baseInfo merge:localLoanDetail.baseInfo];
    }
    [self.financeCache.investDict setObject:loanDetail forKey:loanId];
}

- (void)addDebtInfo:(DebtInfo *)debtInfo
{
    DebtDetail *debtDetail = [DebtDetail new];
    debtDetail.baseInfo = debtInfo;
    [self addDebtDetail:debtDetail];
}

- (void)addDebtDetail:(DebtDetail *)debtDetail
{
    NSNumber *debtId = [NSNumber numberWithInt:debtDetail.baseInfo.debtId];
    DebtDetail *localDetail = [self.financeCache.attornDict objectForKey:debtId];
    if (localDetail) {
        [debtDetail.baseInfo merge:localDetail.baseInfo];
    }
    [self.financeCache.attornDict setObject:debtDetail forKey:debtId];
}
@end


#pragma mark - MSFinanceCache
@implementation MSFinanceCache
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.investDict = [NSMutableDictionary dictionary];
        self.recommenedList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
        self.investList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
        
        self.attornDict = [NSMutableDictionary dictionary];
        self.attornList = [NSMutableArray array];
        self.totalAttornItemCount = 0;
        self.hasMoreAttorns = NO;
        
        self.investRecordDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)hasMoreAttorns{
    return _attornList.count < _totalAttornItemCount || _hasMoreAttorns;
}

@end
