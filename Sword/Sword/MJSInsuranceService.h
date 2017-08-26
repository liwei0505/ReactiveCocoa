//
//  MJSInsuranceService.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InsuranceProtocol;

@interface MJSInsuranceService : NSObject

- (instancetype)initWithProtocol:(InsuranceProtocol *)protocol;

- (RACSignal *)queryRecommendedList;
- (RACSignal *)querySectionList;
- (RACSignal *)queryInsuranceDetailWithId:(NSString *)insuranceId wholeInfo:(BOOL)wholeInfo;
- (RACSignal *)queryInsuranceContentWithId:(NSString *)insuranceId type:(InsuranceContentType)contentType;
- (RACSignal *)insuranceWithInsuranceId:(NSString *)insuranceId productId:(NSString *)productId effectiveDate:(NSTimeInterval)effectiveDate copiesCount:(NSUInteger)copiesCount insurerMail:(NSString *)insurerMail insurant:(InsurantInfo *)insurantInfo;
- (RACSignal *)cancelInsuranceWithOrderId:(NSString *)orderId;
- (RACSignal *)queryPayInfoWithOrderId:(NSString *)orderId payType:(PayType)payType;
- (RACSignal *)queryFHOnlinePayInfoWithOrderId:(NSString *)orderId;
- (RACSignal *)queryPolicyInfoWithId:(NSString *)orderId;
- (InsurancePolicy *)getPolicyInfo:(NSString *)orderId;
- (RACSignal *)queryMyPolicyListWithStatus:(NSUInteger)statusFlag reqeustType:(ListRequestType)requestType;

@end
