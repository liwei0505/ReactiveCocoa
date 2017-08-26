//
//  MSRechargeOne.m
//  Sword
//
//  Created by msj on 2016/12/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRechargeOne.h"

@implementation MSRechargeOne
- (void)setResult:(NSInteger)result
{
    if (result == 0) {
        [super setResult:MSRechargeOneModeSuccess];
    }else if (result == 2){
        [super setResult:MSRechargeOneModeFrozen];
    }else if (result == 3){
        [super setResult:MSRechargeOneModeError];
    }else if (result == 6){
        [super setResult:MSRechargeOneModePassWordMoreThanMax];
    }else if (result == 7){
        [super setResult:MSRechargeOneModePassWordError];
    }else if (result == 1){
        [super setResult:MSRechargeOneModeNoParams];
    }else if (result == 5){
        [super setResult:MSRechargeOneModeNoSetPassWord];
    }else {
        [super setResult:result];
    }
}
@end
