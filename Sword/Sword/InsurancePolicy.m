//
//  InsurancePolicy.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsurancePolicy.h"

@implementation InsurancePolicy

- (instancetype)init {
    if (self = [super init]) {
        _status = POLICY_STATUS_TOBE_PAID;
    }
    return self;
}

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj {
    InsurancePolicy *policyInfo = [[InsurancePolicy alloc] init];
    policyInfo.orderId = [jsonObj objectForKey:@"orderId"];
    policyInfo.policyId = [jsonObj objectForKey:@"policyId"];
    policyInfo.insuranceId = [jsonObj objectForKey:@"insuranceId"];
    policyInfo.insuranceTitle = [jsonObj objectForKey:@"insuranceTitle"];
    policyInfo.underwritingBusiness = [jsonObj objectForKey:@"underwritingBusiness"];
    policyInfo.consignmentCompany = [jsonObj objectForKey:@"consignmentCompany"];
    policyInfo.insuredDate = [[jsonObj objectForKey:@"insuredDate"] doubleValue];
    policyInfo.status = [[jsonObj objectForKey:@"status"] unsignedIntegerValue];
    policyInfo.insurerName = [jsonObj objectForKey:@"insurerName"];
    policyInfo.insurantName = [jsonObj objectForKey:@"insurantName"];
    policyInfo.premium = [NSDecimalNumber decimalNumberWithString:[jsonObj objectForKey:@"premium"]];
    policyInfo.electronicPolicyUrl = [jsonObj objectForKey:@"electronicPolicyUrl"];
    policyInfo.serviceTel = [jsonObj objectForKey:@"serviceTel"];
    policyInfo.startDate = [[jsonObj objectForKey:@"startDate"] doubleValue];
    policyInfo.endDate = [[jsonObj objectForKey:@"endDate"] doubleValue];
    policyInfo.cancelledDate = [[jsonObj objectForKey:@"cancelledDate"] doubleValue];
    policyInfo.failedReason = [jsonObj objectForKey:@"failedReason"];
    return policyInfo;
}

- (NSString *)description {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class InsurancePolicy \n"];
    [sb appendFormat:@" orderId: %@ \n", self.orderId];
    [sb appendFormat:@" policyId: %@ \n", self.policyId];
    [sb appendFormat:@" insuranceId: %@ \n", self.insuranceId];
    [sb appendFormat:@" insuranceTitle: %@ \n", self.insuranceTitle];
    [sb appendFormat:@" underwritingBusiness: %@ \n", self.underwritingBusiness];
    [sb appendFormat:@" consignmentCompany: %@ \n", self.consignmentCompany];
    [sb appendFormat:@" insuredDate: %f \n", self.insuredDate];
    [sb appendFormat:@" status: %lu \n", (unsigned long)self.status];
    [sb appendFormat:@" insurerName: %@ \n", self.insurerName];
    [sb appendFormat:@" insurantName: %@ \n", self.insurantName];
    [sb appendFormat:@" premium: %@ \n", self.premium];
    [sb appendFormat:@" electronicPolicyUrl: %@ \n", self.electronicPolicyUrl];
    [sb appendFormat:@" serviceTel: %@ \n", self.serviceTel];
    [sb appendFormat:@" startDate: %f \n", self.startDate];
    [sb appendFormat:@" endDate: %f \n", self.endDate];
    [sb appendFormat:@" cancelledDate: %f \n", self.cancelledDate];
    [sb appendFormat:@" failedReason: %@ \n", self.failedReason];
    [sb appendFormat:@"} \n"];
    return sb;
}

@end
