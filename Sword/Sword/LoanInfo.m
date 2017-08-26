//
//  MSInvestInfo.m
//  Sword
//
//  Created by haorenjie on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "LoanInfo.h"
#import "MSTextUtils.h"

@implementation LoanInfo

- (instancetype)init {
    if (self = [super init]) {
        _termInfo = [[TermInfo alloc] init];
    }
    return self;
}

- (int)status
{
    if (_progress == 100) {   
        _status = LOAN_STATUS_COMPLETED;
    }
    return _status;
}

- (void)merge:(LoanInfo *)loanInfo
{
    if (!loanInfo || self.loanId != loanInfo.loanId) {
        return;
    }

    self.type = loanInfo.type;
    self.salesRate = loanInfo.salesRate;
    self.raiseBeginTime = loanInfo.raiseBeginTime;
    self.raiseEndTime = loanInfo.raiseEndTime;
    [self.termInfo merge:loanInfo.termInfo];
}

@end
