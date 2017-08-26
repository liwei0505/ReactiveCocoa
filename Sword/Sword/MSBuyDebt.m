//
//  MSBuyDebt.m
//  Sword
//
//  Created by msj on 2016/12/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBuyDebt.h"

@implementation MSBuyDebt
- (void)setResult:(NSInteger)result
{
    if (result == 0) {
        [super setResult:MSBuyDebtModeSuccess];
    }else if (result == 2){
        [super setResult:MSBuyDebtModeNoSupport];
    }else if (result == 3){
        [super setResult:MSBuyDebtModeError];
    }else if (result == 6){
        [super setResult:MSBuyDebtModePassWordMoreThanMax];
    }else if (result == 7){
        [super setResult:MSBuyDebtModePassWordError];
    }else if (result == 1){
        [super setResult:MSBuyDebtModeNoParams];
    }else if (result == 5){
        [super setResult:MSBuyDebtModeNoSetPassWord];
    }else if (result == 8){
        [super setResult:MSBuyDebtModeNoEnoughBalance];
    }else {
        [super setResult:result];
    }
}
@end
