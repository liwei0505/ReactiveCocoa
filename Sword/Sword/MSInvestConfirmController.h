//
//  MSInvestConfirmController.h
//  Sword
//
//  Created by haorenjie on 16/6/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

@interface MSInvestConfirmController : MSBaseViewController
- (void)updateWithLoanId:(NSNumber *)loanId myInvestedAmount:(NSDecimalNumber *)myInvestedAmount;
@end
