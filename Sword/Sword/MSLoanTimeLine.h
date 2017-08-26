//
//  MSLoanTimeLine.h
//  Sword
//
//  Created by msj on 2017/6/12.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSLoanTimeLine : UIView
@property (strong, nonatomic) LoanDetail *loanDetail;
@property (copy, nonatomic) void (^countdownTimeoutBlock)(void);
@end
