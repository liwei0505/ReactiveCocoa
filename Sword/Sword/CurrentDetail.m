//
//  CurrentDetail.m
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "CurrentDetail.h"

@implementation CurrentDetail

- (instancetype)init {
    if (self = [super init]) {
        _baseInfo = [[CurrentInfo alloc] init];
        _last7DaysInterestRates = [[NSArray alloc] init];
        _productInfo = [[CurrentProductInfo alloc] init];
    }
    return self;
}

@end

@implementation DayInterestRate

@end

@implementation CurrentProductInfo

- (instancetype)init {
    if (self = [super init]) {
        _items = [[NSArray alloc] init];
    }
    return self;
}

@end

@implementation CurrentProductItem

@end
