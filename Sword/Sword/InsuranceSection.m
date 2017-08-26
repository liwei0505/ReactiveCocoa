//
//  InsuranceSection.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsuranceSection.h"

@implementation InsuranceSection

- (instancetype)init {
    if (self = [super init]) {
        _insuranceList = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj {
    InsuranceSection *sectionInfo = [[InsuranceSection alloc] init];
    sectionInfo.sectionName = [jsonObj objectForKey:@"sectionName"];
    sectionInfo.order = [[jsonObj objectForKey:@"order"] unsignedIntegerValue];

    NSArray *jInsuranceList = [jsonObj objectForKey:@"insuranceList"];
    NSMutableArray *insuranceList = [[NSMutableArray alloc] initWithCapacity:jInsuranceList.count];
    for (NSDictionary *jInsurance in jInsuranceList) {
        [insuranceList addObject:[InsuranceInfo parserFromJson:jInsurance]];
    }
    sectionInfo.insuranceList = insuranceList;

    return sectionInfo;
}

- (NSString *)description {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class InsuranceSection \n"];
    [sb appendFormat:@" sectionName: %@ \n", self.sectionName];
    [sb appendFormat:@" order: %lu \n", (unsigned long)self.order];
    [sb appendFormat:@" insuranceList: %@ \n", self.insuranceList];
    [sb appendFormat:@"} \n"];
    return sb;
}

@end
