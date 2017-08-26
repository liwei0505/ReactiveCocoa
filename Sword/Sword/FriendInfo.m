//
//  FriendInfo.m
//  mobip2p
//
//  Created by lee on 16/6/1.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import "FriendInfo.h"

@implementation FriendInfo

- (instancetype)init {
    if (self = [super init]) {
        _totalReward = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    return self;
}

@end
