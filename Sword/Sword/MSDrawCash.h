//
//  MSDrawCash.h
//  Sword
//
//  Created by msj on 2016/12/24.
//  Copyright © 2016年 mjsfax. All rights reserved.      `1` 
//

#import "RACError.h"

typedef NS_ENUM(NSInteger, MSDrawCashMode) {
    MSDrawCashModeSuccess,
    MSDrawCashModeFrozen,
    MSDrawCashModePassWordError,
    MSDrawCashModePassWordMoreThanMax,
    MSDrawCashModeNoBindCard,
    MSDrawCashModeNoSetPassWord,
    MSDrawCashModeNoParams,
    MSDrawCashModeMoneyShouldMoreThanZero,
    MSDrawCashModeNoEnoughBalance,
    MSDrawCashModeCashCountTooMuch,
    MSDrawCashModeCashBeyondDayLimit,
    MSDrawCashModeCashBeyondMonthLimit,
};

@interface MSDrawCash : RACError
@property (assign, nonatomic) int canRetryCount;
@end
