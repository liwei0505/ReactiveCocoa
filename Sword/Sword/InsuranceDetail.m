//
//  InsuranceDetail.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsuranceDetail.h"
#import "MSUrlManager.h"

@implementation InsuranceDetail

- (instancetype)init {
    if (self = [super init]) {
        _needMail = YES;
    }
    return self;
}

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj {
    InsuranceDetail *detailInfo = [[InsuranceDetail alloc] init];
    NSDictionary *jbaseInfo = [jsonObj objectForKey:@"baseInfo"];
    if (jbaseInfo) {
        detailInfo.baseInfo = [InsuranceInfo parserFromJson:jbaseInfo];
    }
    NSString *bannerUrl = [jsonObj objectForKey:@"bannerUrl"];
    if (bannerUrl) {
        detailInfo.bannerUrl = [NSString stringWithFormat:@"%@%@", [MSUrlManager getImageUrlPrefix], bannerUrl];
    }
    detailInfo.introduction = [jsonObj objectForKey:@"introduction"];

    NSArray *jProductList = [jsonObj objectForKey:@"productList"];
    NSMutableArray *productList = [[NSMutableArray alloc] initWithCapacity:jProductList.count];
    for (NSDictionary *jProduct in jProductList) {
        InsuranceProduct *productInfo = [InsuranceProduct parserFromJson:jProduct];
        [productList addObject:productInfo];
    }
    if (productList.count > 1) {
        [productList sortUsingComparator:^NSComparisonResult(InsuranceProduct *o1, InsuranceProduct *o2) {
            return o1.order < o2.order ? -1 : (o1.order > o2.order ? 1 : 0);
        }];
    }
    detailInfo.productList = productList;

    NSArray *jTermList = [jsonObj objectForKey:@"termOptions"];
    NSMutableArray *termList = [[NSMutableArray alloc] initWithCapacity:jTermList.count];
    for (NSDictionary *jTerm in jTermList) {
        TermInfo *termInfo = [[TermInfo alloc] init];
        termInfo.unitType = [[jTerm objectForKey:@"termUnit"] unsignedIntegerValue];
        termInfo.termCount = [[jTerm objectForKey:@"termCount"] intValue];
        [termList addObject:termInfo];
    }
    detailInfo.termOptions = termList;

    detailInfo.copiesLimit = [[jsonObj objectForKey:@"copiesLimit"] unsignedIntegerValue];
    detailInfo.insurantLimit = [jsonObj objectForKey:@"insurantLimit"];
    detailInfo.maxAge = [[jsonObj objectForKey:@"maxAge"] unsignedIntegerValue];
    detailInfo.minAge = [[jsonObj objectForKey:@"minAge"] unsignedIntegerValue];
    detailInfo.genderLimit = [[jsonObj objectForKey:@"genderLimit"] unsignedIntegerValue];
    detailInfo.underwritingBusiness = [jsonObj objectForKey:@"underwritingBusiness"];
    detailInfo.consignmentCompany = [jsonObj objectForKey:@"consignmentCompany"];
    detailInfo.effectiveDate = [[jsonObj objectForKey:@"effectiveDate"] doubleValue];
    detailInfo.specialAgreement = [jsonObj objectForKey:@"specialAgreement"];
    detailInfo.serviceTel = [jsonObj objectForKey:@"serviceTel"];

    NSArray *jContractList = [jsonObj objectForKey:@"contractList"];
    NSMutableArray *contractList = [[NSMutableArray alloc] initWithCapacity:jContractList.count];
    for (NSDictionary *jContract in jContractList) {
        ContractInfo *contractInfo = [ContractInfo parserFromJson:jContract];
        [contractList addObject:contractInfo];
    }
//    if (contractList.count > 1) {
//        [contractList sortUsingComparator:^NSComparisonResult(ContractInfo *o1, ContractInfo *o2) {
//            return o1.order < o2.order ? -1 : (o1.order > o2.order ? 1 : 0);
//        }];
//    }
    detailInfo.contractList = contractList;
    detailInfo.needMail = [[jsonObj objectForKey:@"needEmail"] boolValue];

    return detailInfo;
}

- (NSString *)description {
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class InsuranceDetail \n"];
    [sb appendFormat:@" baseInfo: %@ \n", self.baseInfo];
    [sb appendFormat:@" bannerUrl: %@ \n", self.bannerUrl];
    [sb appendFormat:@" introduction: %@ \n", self.introduction];
    [sb appendFormat:@" productList: %@ \n", self.productList];
    [sb appendFormat:@" termOptions: %@ \n", self.termOptions];
    [sb appendFormat:@" copiesLimit: %lu \n", (unsigned long)self.copiesLimit];
    [sb appendFormat:@" insurantLimit: %@ \n", self.insurantLimit];
    [sb appendFormat:@" maxAge: %lu \n", (unsigned long)self.maxAge];
    [sb appendFormat:@" minAge: %lu \n", (unsigned long)self.minAge];
    [sb appendFormat:@" genderLimit: %lu \n", (unsigned long)self.genderLimit];
    [sb appendFormat:@" underwritingBusiness: %@ \n", self.underwritingBusiness];
    [sb appendFormat:@" consignmentCompany: %@ \n", self.consignmentCompany];
    [sb appendFormat:@" effectiveDate: %f \n", self.effectiveDate];
    [sb appendFormat:@" specialAgreement: %@ \n", self.specialAgreement];
    [sb appendFormat:@" serviceTel: %@ \n", self.serviceTel];
    [sb appendFormat:@" contractList: %@ \n", self.contractList];
    [sb appendFormat:@" needMail: %d \n", self.needMail];
    [sb appendFormat:@"} \n"];
    return sb;
}

@end
