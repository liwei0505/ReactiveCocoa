//
//  MSSubmitInvest.h
//  Sword
//
//  Created by msj on 2016/12/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "RACError.h"

typedef NS_ENUM(NSInteger, MSSubmitInvestMode) {
    MSSubmitInvestModeSuccess,
    MSSubmitInvestModeError,
    MSSubmitInvestModePassWordError,
    MSSubmitInvestModePassWordMoreThanMax,
    MSSubmitInvestModeNoSetPassWord,
    MSSubmitInvestModeNoParams,
    MSSubmitInvestModeNoEnoughBalance
};

@interface MSSubmitInvest : RACError
@property (assign, nonatomic) int canRetryCount;
@end
