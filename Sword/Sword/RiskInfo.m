//
//  RiskInfo.m
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "RiskInfo.h"

@implementation RiskDetailInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isSelected = NO;
        self.order = 'A';
    }
    return self;
}
@end

@implementation RiskInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isCompeleted = NO;
        self.answerId = nil;
        self.riskDetailInfoArr = [NSMutableArray array];
    }
    return self;
}
@end

@implementation RiskResultInfo

@end
