//
//  MSRechargeTwo.h
//  Sword
//
//  Created by msj on 2016/12/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "RACError.h"

typedef NS_ENUM(NSInteger, MSRechargeTwoMode) {
    MSRechargeTwoModeSuccess,
    MSRechargeTwoModeError,
    MSRechargeTwoModeGetVeriCodeError,
    MSRechargeTwoModeFrozen,
    MSRechargeTwoModeNoParams,
    MSRechargeTwoModeTooFrequent,
    MSRechargeTwoModeMoreThanRequestMax
};

@interface MSRechargeTwo : RACError
@end
