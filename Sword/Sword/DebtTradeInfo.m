//
//  MSMyDebtListInfo.m
//  mobip2p
//
//  Created by lee on 16/5/18.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import "DebtTradeInfo.h"

@implementation DebtTradeInfo

- (instancetype)init
{
    if (self = [super init]) {
        _debtInfo = [DebtInfo new];
    }
    return self;
}

@end
