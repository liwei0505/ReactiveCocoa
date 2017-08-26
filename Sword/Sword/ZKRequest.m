//
//  ZKRequest.m
//  Sword
//
//  Created by haorenjie on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "ZKRequest.h"

@implementation ZKRequest

- (NSMutableDictionary *)params
{
    if (!_params) {
        _params = [[NSMutableDictionary alloc] init];
    }
    return _params;
}

@end
