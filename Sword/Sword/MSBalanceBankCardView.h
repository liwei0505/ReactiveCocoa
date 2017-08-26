//
//  MSChargeBankCardView.h
//  Sword
//
//  Created by msj on 2017/6/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BankInfo.h"
#import "AccountInfo.h"
#import "WithdrawConfig.h"

typedef NS_ENUM(NSInteger, MSBalanceBankCardViewStyle) {
    MSBalanceBankCardViewStyle_charge,
    MSBalanceBankCardViewStyle_cash
};

@interface MSBalanceBankCardView : UIView
- (void)updateWithBankInfo:(BankInfo *)bankInfo accountInfo:(AccountInfo *)accountInfo withdrawConfig:(WithdrawConfig *)withdrawConfig;
@property (assign, nonatomic) MSBalanceBankCardViewStyle cardViewStyle;
@end
