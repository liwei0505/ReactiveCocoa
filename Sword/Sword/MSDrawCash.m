//
//  MSDrawCash.m
//  Sword
//
//  Created by msj on 2016/12/24.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSDrawCash.h"

@implementation MSDrawCash

- (void)setResult:(NSInteger)result{

    if (result == 0) {
        [super setResult:MSDrawCashModeSuccess];
    }else if (result == 1){
        [super setResult:MSDrawCashModeNoParams];
    }else if (result == 2){
        [super setResult:MSDrawCashModeMoneyShouldMoreThanZero];
    }else if (result == 3){
        [super setResult:MSDrawCashModeFrozen];
    }else if (result == 4){
        [super setResult:MSDrawCashModeNoBindCard];
    }else if (result == 5){
        [super setResult:MSDrawCashModeNoSetPassWord];
    }else if (result == 6){
        [super setResult:MSDrawCashModePassWordMoreThanMax];
    }else if (result == 7){
        [super setResult:MSDrawCashModePassWordError];
    }else if (result == 8){
        [super setResult:MSDrawCashModeNoEnoughBalance];
    }else if (result == 9){
        [super setResult:MSDrawCashModeCashCountTooMuch];
    }else {
        [super setResult:result];
    }
    
}

@end
