//
//  MSSubmitInvest.m
//  Sword
//
//  Created by msj on 2016/12/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSSubmitInvest.h"

@implementation MSSubmitInvest

- (void)setResult:(NSInteger)result
{
    if (result == 0) {
        [super setResult:MSSubmitInvestModeSuccess];
    }else if (result == 3 || result == 2){
        [super setResult:MSSubmitInvestModeError];
    }else if (result == 6){
        [super setResult:MSSubmitInvestModePassWordMoreThanMax];
    }else if (result == 7){
        [super setResult:MSSubmitInvestModePassWordError];
    }else if (result == 1){
        [super setResult:MSSubmitInvestModeNoParams];
    }else if (result == 5){
        [super setResult:MSSubmitInvestModeNoSetPassWord];
    }else if (result == 8){
        [super setResult:MSSubmitInvestModeNoEnoughBalance];
    }else {
        [super setResult:result];
    }
}

@end
