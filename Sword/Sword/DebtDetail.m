//
//  MSDebtDetailInfo.m
//  mobip2p
//
//  Created by lw on 16/5/18.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import "DebtDetail.h"

@implementation DebtDetail

- (instancetype)init
{
    if (self = [super init]) {
        _baseInfo = [DebtInfo new];
    }
    return self;
}
@end
