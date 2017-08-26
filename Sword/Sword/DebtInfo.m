//
//  DebtListInfo.m
//  mobip2p
//
//  Created by lw on 16/5/29.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import "DebtInfo.h"

@implementation DebtInfo

- (LoanDetail *)loanInfo {

    if (_loanInfo == nil) {
        _loanInfo = [LoanDetail new];
    }
    return _loanInfo;
}

- (void)merge:(DebtInfo *)debtInfo
{
    if (!debtInfo || self.debtId != debtInfo.debtId) {
        return;
    }

    self.borrowId = debtInfo.borrowId;
    self.annualInterestRate = debtInfo.annualInterestRate;
    self.soldPrice = debtInfo.soldPrice;
    self.nextAmount = debtInfo.nextAmount;
    self.status = debtInfo.status;
    self.fee = debtInfo.fee;
    self.earnings = debtInfo.earnings;
    [self.loanInfo merge:debtInfo.loanInfo];
}

@end
