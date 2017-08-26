//
//  InsuranceInfo.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsuranceInfo.h"
#import "MSUrlManager.h"

@implementation InsuranceInfo

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj {
    InsuranceInfo *insuranceInfo = [[InsuranceInfo alloc] init];
    insuranceInfo.insuranceId = [jsonObj objectForKey:@"insuranceId"];
    insuranceInfo.title = [jsonObj objectForKey:@"title"];
    NSString *iconUrl = [jsonObj objectForKey:@"iconUrl"];
    if (iconUrl) {
        insuranceInfo.iconUrl = [NSString stringWithFormat:@"%@%@", [MSUrlManager getImageUrlPrefix], iconUrl];
    }
    insuranceInfo.type = [[jsonObj objectForKey:@"type"] unsignedIntegerValue];
    insuranceInfo.soldCount = [[jsonObj objectForKey:@"soldCount"] unsignedIntegerValue];
    insuranceInfo.startAmount = [NSDecimalNumber decimalNumberWithString:[jsonObj objectForKey:@"startAmount"]];
    insuranceInfo.tags = [jsonObj objectForKey:@"tags"];
    return insuranceInfo;
}

- (NSString *)description {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class InsuranceInfo \n"];
    [sb appendFormat:@" insuranceId: %@ \n", self.insuranceId];
    [sb appendFormat:@" title: %@ \n", self.title];
    [sb appendFormat:@" iconUrl: %@ \n", self.iconUrl];
    [sb appendFormat:@" type: %lu \n", (unsigned long)self.type];
    [sb appendFormat:@" soldCount: %lu \n", (unsigned long)self.soldCount];
    [sb appendFormat:@" startAmount: %@ \n", self.startAmount];
    [sb appendFormat:@" tags: %@ \n", self.tags];
    [sb appendFormat:@"} \n"];
    return sb;
}

@end
