//
//  MSRechargeOne.h
//  Sword
//
//  Created by msj on 2016/12/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//
#import "RACError.h"

typedef NS_ENUM(NSInteger, MSRechargeOneMode) {
    MSRechargeOneModeSuccess,
    MSRechargeOneModeError,
    MSRechargeOneModeFrozen,
    MSRechargeOneModePassWordError,
    MSRechargeOneModePassWordMoreThanMax,
    MSRechargeOneModeNoSetPassWord,
    MSRechargeOneModeNoParams
};

@interface MSRechargeOne : RACError
@property (assign, nonatomic) int canRetryCount;
@property (copy, nonatomic) NSString *rechargeNo;
@end
