//
//  InsuranceProtocol.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKSessionManager.h"

@interface InsuranceProtocol : NSObject

- (instancetype)initWithSessionManager:(ZKSessionManager *)sessionManager;

- (RACSignal *)queryRecommendedList;
- (RACSignal *)querySectionList;
- (RACSignal *)queryInsuranceDetailWithId:(NSString *)insuranceId wholeInfo:(BOOL)wholeInfo;
- (RACSignal *)queryInsuranceContentWithId:(NSString *)insuranceId type:(InsuranceContentType)contentType;
- (RACSignal *)insuranceWithInsuranceId:(NSString *)insuranceId productId:(NSString *)productId effectiveDate:(NSTimeInterval)effectiveDate copiesCount:(NSUInteger)copiesCount insurerMail:(NSString *)insurerMail insurant:(InsurantInfo *)insurantInfo;
- (RACSignal *)cancelInsuranceWithOrderId:(NSString *)lastOrderId;
- (RACSignal *)queryPayInfoWithOrderId:(NSString *)orderId payType:(PayType)payType;
- (RACSignal *)queryFHOnlinePayInfoWithOrderId:(NSString *)orderId;
- (RACSignal *)queryPolicyInfoWithId:(NSString *)orderId;
- (RACSignal *)queryMyPolicyListWithStatus:(NSUInteger)statusFlag lastOrderId:(NSString *)lastOrderId requestCount:(NSUInteger)requestCount;

@end
