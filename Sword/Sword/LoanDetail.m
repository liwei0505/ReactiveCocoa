//
//  MSLoanDetailInfo.m
//  mobip2p
//
//  Created by lw on 16/5/15.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import "LoanDetail.h"

@implementation LoanDetail

- (LoanInfo *)baseInfo {

    if (_baseInfo == nil) {
        _baseInfo = [LoanInfo new];
    }
    return _baseInfo;
}

- (BOOL)hasDetail
{
    return _borrowId > 0;
}

- (void)merge:(LoanDetail *)loanDetail
{
    if (!loanDetail || self.baseInfo.loanId != loanDetail.baseInfo.loanId) {
        return;
    }

    self.repayType = loanDetail.repayType;
    [self.baseInfo merge:loanDetail.baseInfo];
}

@end
