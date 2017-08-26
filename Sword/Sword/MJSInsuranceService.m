//
//  MJSInsuranceService.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MJSInsuranceService.h"
#import "InsuranceProtocol.h"

@interface MJSInsuranceService()
{
    InsuranceProtocol *_protocol;
}

@property (strong, nonatomic) NSMutableDictionary<NSNumber *, MSListWrapper *> *myOrderIdListDict;
@property (strong, nonatomic) NSMutableDictionary<NSString *, InsurancePolicy *> *insurancePolicyDict;

@end

@implementation MJSInsuranceService

- (instancetype)initWithProtocol:(InsuranceProtocol *)protocol {
    if (self = [super init]) {
        _protocol = protocol;
        _myOrderIdListDict = [[NSMutableDictionary alloc] init];
        _insurancePolicyDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (RACSignal *)queryRecommendedList {
    return [_protocol queryRecommendedList];
}

- (RACSignal *)querySectionList {
    return [_protocol querySectionList];
}

- (RACSignal *)queryInsuranceDetailWithId:(NSString *)insuranceId wholeInfo:(BOOL)wholeInfo {
    return [_protocol queryInsuranceDetailWithId:insuranceId wholeInfo:wholeInfo];
}

- (RACSignal *)queryInsuranceContentWithId:(NSString *)insuranceId type:(InsuranceContentType)contentType {
    return [_protocol queryInsuranceContentWithId:insuranceId type:contentType];
}

- (RACSignal *)insuranceWithInsuranceId:(NSString *)insuranceId productId:(NSString *)productId effectiveDate:(NSTimeInterval)effectiveDate copiesCount:(NSUInteger)copiesCount insurerMail:(NSString *)insurerMail insurant:(InsurantInfo *)insurantInfo {
    return [_protocol insuranceWithInsuranceId:insuranceId productId:productId effectiveDate:effectiveDate copiesCount:copiesCount insurerMail:insurerMail insurant:insurantInfo];
}

- (RACSignal *)cancelInsuranceWithOrderId:(NSString *)orderId {
    return [_protocol cancelInsuranceWithOrderId:orderId];
}

- (RACSignal *)queryPayInfoWithOrderId:(NSString *)orderId payType:(PayType)payType {
    return [_protocol queryPayInfoWithOrderId:orderId payType:payType];
}

- (RACSignal *)queryFHOnlinePayInfoWithOrderId:(NSString *)orderId {
    return [_protocol queryFHOnlinePayInfoWithOrderId:orderId];
}

- (InsurancePolicy *)getPolicyInfo:(NSString *)orderId {
    return [self.insurancePolicyDict objectForKey:orderId];
}

- (RACSignal *)queryPolicyInfoWithId:(NSString *)orderId {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        InsurancePolicy *policyInfo = [self.insurancePolicyDict objectForKey:orderId];
        if (policyInfo) {
            [subscriber sendNext:policyInfo];
        }

        [[_protocol queryPolicyInfoWithId:orderId] subscribeNext:^(InsurancePolicy *policyInfo) {
            [self.insurancePolicyDict setObject:policyInfo forKey:policyInfo.orderId];
            [subscriber sendNext:policyInfo];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyPolicyListWithStatus:(NSUInteger)statusFlag reqeustType:(ListRequestType)requestType {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSNumber *flag = [NSNumber numberWithUnsignedInteger:statusFlag];
        NSString *lastOrderId = @"";
        @strongify(self);
        MSListWrapper *myOrderIdList = [self.myOrderIdListDict objectForKey:flag];
        if (!myOrderIdList) {
            myOrderIdList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
            [self.myOrderIdListDict setObject:myOrderIdList forKey:flag];
        }

        if (requestType == LIST_REQUEST_MORE && myOrderIdList.count > 0) {
            NSString *orderId = [[myOrderIdList getList] valueForKeyPath:@"@max.self"];
            if (orderId) {
                lastOrderId = [orderId copy];
            }
        }

        [[_protocol queryMyPolicyListWithStatus:statusFlag lastOrderId:lastOrderId requestCount:MS_PAGE_SIZE] subscribeNext:^(NSArray<InsurancePolicy *> *policyList) {
            if (requestType == LIST_REQUEST_NEW) {
                [myOrderIdList clear];
            }

            @strongify(self);
            NSMutableArray *orderIdList = [[NSMutableArray alloc] initWithCapacity:policyList.count];
            for (InsurancePolicy *policyInfo in policyList) {
                [orderIdList addObject:policyInfo.orderId];
                [self.insurancePolicyDict setObject:policyInfo forKey:policyInfo.orderId];
            }
            [myOrderIdList addList:orderIdList];
            [subscriber sendNext:myOrderIdList];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

@end
