//
//  MSRechargeThree.m
//  Sword
//
//  Created by msj on 2016/12/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRechargeThree.h"

@implementation MSRechargeThree
- (void)setResult:(NSInteger)result
{
    if (result == 0) {
        [super setResult:MSRechargeThreeModeSuccess];
    }else if (result == 1){
        [super setResult:MSRechargeThreeModeNoParams];
    }else if (result == 2){
        [super setResult:MSRechargeThreeModeFrozen];
    }else if (result == 3){
        [super setResult:MSRechargeThreeModeError];
    }else if (result == 11){
        [super setResult:MSRechargeThreeModeVeriCodeError];
    }else {
        [super setResult:result];
    }
}
@end
