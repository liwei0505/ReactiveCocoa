//
//  MSRechargeThree.h
//  Sword
//
//  Created by msj on 2016/12/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "RACError.h"

typedef NS_ENUM(NSInteger, MSRechargeThreeMode) {
    MSRechargeThreeModeSuccess,
    MSRechargeThreeModeError,
    MSRechargeThreeModeNoParams,
    MSRechargeThreeModeFrozen,
    MSRechargeThreeModeVeriCodeError
};

@interface MSRechargeThree : RACError
@end
