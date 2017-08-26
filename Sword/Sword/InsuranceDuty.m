//
//  InsuranceDuty.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsuranceDuty.h"

@implementation InsuranceDuty

- (instancetype)init {
    if (self = [super init]) {
        _dayFlag = NO;
    }
    return self;
}

- (NSString *)getGuaranteeDesc {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"%.2f元", self.guaranteeAmount.doubleValue];
    if (self.dayFlag) {
        [sb appendString:@"/天"];
    }
    return sb;
}

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj {
    InsuranceDuty *dutyInfo = [[InsuranceDuty alloc] init];
    dutyInfo.dutyId = [jsonObj objectForKey:@"dutyId"];
    dutyInfo.dutyTitle = [jsonObj objectForKey:@"title"];
    dutyInfo.introduction = [jsonObj objectForKey:@"introduction"];
    dutyInfo.guaranteeAmount = [NSDecimalNumber decimalNumberWithString:[jsonObj objectForKey:@"guaranteeAmount"]];
    dutyInfo.dayFlag = [[jsonObj objectForKey:@"dayFlag"] boolValue];
    dutyInfo.order = [[jsonObj objectForKey:@"order"] unsignedIntegerValue];
    return dutyInfo;
}

- (NSString *)description {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class InsuranceDuty \n"];
    [sb appendFormat:@" dutyId: %@ \n", self.dutyId];
    [sb appendFormat:@" dutyTitle: %@ \n", self.dutyTitle];
    [sb appendFormat:@" introduction: %@ \n", self.introduction];
    [sb appendFormat:@" guaranteeAmount: %@ \n", self.guaranteeAmount];
    [sb appendFormat:@" dayFlag: %d \n", self.dayFlag];
    [sb appendFormat:@" order: %lu \n", (unsigned long)self.order];
    [sb appendFormat:@"} \n"];
    return sb;
}

@end
