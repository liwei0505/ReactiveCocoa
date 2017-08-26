//
//  MSMyInvestInfo.m
//  mobip2p
//
//  Created by lee on 16/5/18.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import "InvestInfo.h"

@implementation InvestInfo

- (instancetype)init
{
    if (self = [super init]) {
        _loanInfo = [[LoanInfo alloc] init];
    }
    return self;
}

@end
