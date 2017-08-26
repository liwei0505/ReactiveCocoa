//
//  MSRechargeTwo.m
//  Sword
//
//  Created by msj on 2016/12/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRechargeTwo.h"

@implementation MSRechargeTwo
- (void)setResult:(NSInteger)result
{
    if (result == 0) {
        [super setResult:MSRechargeTwoModeSuccess];
    }else if (result == 1){
        [super setResult:MSRechargeTwoModeNoParams];
    }else if (result == 2){
        [super setResult:MSRechargeTwoModeFrozen];
    }else if (result == 3){
        [super setResult:MSRechargeTwoModeError];
    }else if (result == 11){
        [super setResult:MSRechargeTwoModeTooFrequent];
    }else if (result == 12){
        [super setResult:MSRechargeTwoModeMoreThanRequestMax];
    }else {
        [super setResult:result];
    }
}
@end
