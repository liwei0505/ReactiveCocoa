//
//  MSBuyDebt.h
//  Sword
//
//  Created by msj on 2016/12/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "RACError.h"

typedef NS_ENUM(NSInteger, MSBuyDebtMode) {
    MSBuyDebtModeSuccess,
    MSBuyDebtModeError,
    MSBuyDebtModePassWordError,
    MSBuyDebtModePassWordMoreThanMax,
    MSBuyDebtModeNoSetPassWord,
    MSBuyDebtModeNoParams,
    MSBuyDebtModeNoSupport,
    MSBuyDebtModeNoEnoughBalance
};

@interface MSBuyDebt : RACError
@property (assign, nonatomic) int canRetryCount;
@end
