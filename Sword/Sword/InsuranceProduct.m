//
//  InsuranceProduct.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsuranceProduct.h"

@implementation InsuranceProduct

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj{
    InsuranceProduct *productInfo = [[InsuranceProduct alloc] init];

    productInfo.productId = [jsonObj objectForKey:@"productId"];
    productInfo.productName = [jsonObj objectForKey:@"name"];
    productInfo.premium = [NSDecimalNumber decimalNumberWithString:[jsonObj objectForKey:@"premium"]];
    productInfo.order = [[jsonObj objectForKey:@"order"] unsignedIntegerValue];

    NSArray *jdutyList = [jsonObj objectForKey:@"duties"];
    NSMutableArray  *dutyList = [[NSMutableArray alloc] initWithCapacity:jdutyList.count];
    for (NSDictionary *jduty in jdutyList) {
        [dutyList addObject:[InsuranceDuty parserFromJson:jduty]];
    }
    productInfo.duties = dutyList;

    return productInfo;
}

- (NSString *)description {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class InsuranceProduct \n"];
    [sb appendFormat:@" productId: %@ \n", self.productId];
    [sb appendFormat:@" productName: %@ \n", self.productName];
    [sb appendFormat:@" premium: %@ \n", self.premium];
    [sb appendFormat:@" order: %lu \n", (unsigned long)self.order];
    [sb appendFormat:@" duties: %@ \n", self.duties];
    [sb appendFormat:@"} \n"];
    return sb;
}

@end
