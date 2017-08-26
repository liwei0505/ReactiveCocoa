//
//  InsuranceProtocol.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsuranceProtocol.h"
#import "MSUrlManager.h"
#import "TimeUtils.h"

@interface InsuranceProtocol()
{
    ZKSessionManager *_sessionManager;
}

@end

@implementation InsuranceProtocol

- (instancetype)initWithSessionManager:(ZKSessionManager *)sessionManager {
    if (self = [super init]) {
        _sessionManager = sessionManager;
    }
    return self;
}

- (RACSignal *)queryRecommendedList {
    NSString *messageId = @"queryInsuranceRecommendedList";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                NSArray *jInsuranceList = [response objectForKey:@"insurances"];
                NSMutableArray *insuranceList = [[NSMutableArray alloc] initWithCapacity:jInsuranceList.count];
                for (NSDictionary *jInsurance in jInsuranceList) {
                    [insuranceList addObject:[InsuranceInfo parserFromJson:jInsurance]];
                }
                
                MSListWrapper *list = [[MSListWrapper alloc] initWithPageSize:insuranceList.count];
                [list addList:insuranceList];
                MSSectionList *sectionList = [MSSectionList sectionListWithType:MSSectionListTypeInsurance listWrapper:list];
                
                [subscriber sendNext:sectionList];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)querySectionList {
    NSString *messageId = @"queryInsuranceSectionList";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                NSArray *jSectionList = [response objectForKey:@"sections"];
                NSMutableArray *sectionList = [[NSMutableArray alloc] initWithCapacity:jSectionList.count];
                for (NSDictionary *jSection in jSectionList) {
                    [sectionList addObject:[InsuranceSection parserFromJson:jSection]];
                }

                if (sectionList.count > 1) {
                    [sectionList sortUsingComparator:^NSComparisonResult(InsuranceSection *o1, InsuranceSection *o2) {
                        return o1.order < o2.order ? -1 : (o1.order > o2.order ? 1 : 0);
                    }];
                }
                [subscriber sendNext:sectionList];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryInsuranceDetailWithId:(NSString *)insuranceId wholeInfo:(BOOL)wholeInfo {
    NSString *messageId = @"queryInsuranceDetail";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:insuranceId forKey:@"insuranceId"];
    [params setObject:[NSNumber numberWithBool:wholeInfo] forKey:@"wholeInfo"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                NSDictionary *jDetail = [response objectForKey:@"detail"];
                InsuranceDetail *detailInfo = [InsuranceDetail parserFromJson:jDetail];
                [subscriber sendNext:detailInfo];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryInsuranceContentWithId:(NSString *)insuranceId type:(InsuranceContentType)contentType {
    NSString *messageId = @"queryInsuranceContent";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:insuranceId forKey:@"insuranceId"];
    [params setObject:[NSNumber numberWithUnsignedInteger:contentType] forKey:@"contentType"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                NSArray *pictureUrlList = [response objectForKey:@"pictureUrlList"];
                NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:pictureUrlList.count];
                for (NSString *url in pictureUrlList) {
                    [urlList addObject:[NSString stringWithFormat:@"%@%@", [MSUrlManager getImageUrlPrefix], url]];
                }
                [subscriber sendNext:urlList];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)insuranceWithInsuranceId:(NSString *)insuranceId productId:(NSString *)productId effectiveDate:(NSTimeInterval)effectiveDate copiesCount:(NSUInteger)copiesCount insurerMail:(NSString *)insurerMail insurant:(InsurantInfo *)insurantInfo {
    NSString *messageId = @"insurance";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:insuranceId forKey:@"insuranceId"];
    [params setObject:productId forKey:@"productId"];
    [params setObject:[NSNumber numberWithDouble:effectiveDate] forKey:@"effectiveDate"];
    [params setObject:[NSNumber numberWithUnsignedInteger:copiesCount] forKey:@"copiesCount"];
    [params setObject:insurerMail forKey:@"insurerMail"];
    if (insurantInfo) {
        [params setObject:[insurantInfo toDictionary] forKey:@"insurant"];
    }

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                NSString *orderId = [response objectForKey:@"orderId"];
                [subscriber sendNext:orderId];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)cancelInsuranceWithOrderId:(NSString *)orderId {
    NSString *messageId = @"cancelInsurance";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:orderId forKey:@"orderId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryPayInfoWithOrderId:(NSString *)orderId payType:(PayType)payType {
    NSString *messageId = @"queryPolicyPayInfo";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:orderId forKey:@"orderId"];
    [params setObject:[NSNumber numberWithUnsignedInteger:payType] forKey:@"payType"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                NSDictionary *jPayInfo = [response objectForKey:@"payInfo"];
                if (payType == Pay_Ali) {
                    [subscriber sendNext:[jPayInfo objectForKey:@"alipay"]];
                } else {
                    [subscriber sendNext:[jPayInfo objectForKey:@"wxpay"]];
                }
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryFHOnlinePayInfoWithOrderId:(NSString *)orderId {
    NSString *messageId = @"queryFHOnlinePayInfo";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:orderId forKey:@"orderId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                FHOlinePayInfo *payInfo = [[FHOlinePayInfo alloc] init];
                payInfo.orderInfo = [response objectForKey:@"orderInfo"];
                payInfo.channelCode = [response objectForKey:@"channelCode"];
                [subscriber sendNext:payInfo];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryPolicyInfoWithId:(NSString *)orderId {
    NSString *messageId = @"queryPolicyInfo";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:orderId forKey:@"orderId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                InsurancePolicy *policyInfo = [InsurancePolicy parserFromJson:[response objectForKey:@"policyInfo"]];
                [subscriber sendNext:policyInfo];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyPolicyListWithStatus:(NSUInteger)statusFlag lastOrderId:(NSString *)lastOrderId requestCount:(NSUInteger)requestCount {
    NSString *messageId = @"queryMyPolicyList";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithUnsignedInteger:statusFlag] forKey:@"statusFlag"];
    [params setObject:lastOrderId ? lastOrderId : @"" forKey:@"lastOrderId"];
    [params setObject:[NSNumber numberWithUnsignedInteger:requestCount] forKey:@"requestCount"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_sessionManager post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *error = [self getResult:result fromResponse:response];
            if (error.result == ERR_NONE) {
                NSArray *jPolicyList = [response objectForKey:@"policyList"];
                NSMutableArray *policyList = [[NSMutableArray alloc] initWithCapacity:jPolicyList.count];
                for (NSDictionary *jPolicy in jPolicyList) {
                    InsurancePolicy *policyInfo = [InsurancePolicy parserFromJson:jPolicy];
                    [policyList addObject:policyInfo];
                }
                NSArray *sortedList = [policyList sortedArrayUsingComparator:^NSComparisonResult(InsurancePolicy *o1, InsurancePolicy *o2) {
                    return (o1.insuredDate < o2.insuredDate) ? 1 : (o1.insuredDate > o2.insuredDate ? -1 : 0);
                }];
                [subscriber sendNext:sortedList];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];

        return nil;
    }];
}

- (NSString *)getServiceHost {
    switch ([MSUrlManager getHost]) {
        case HOST_TEST:
            return @"http://10.0.110.69:6201/";//功能测试
        case HOST_PERFORMANCE:
        case HOST_PREREALSE:
        case HOST_PRODUCT:
        default:
            return @"http://10.0.110.69:6201/";//功能测试
    }
}

- (NSString *)getHttpUrl:(NSString *)messageId {
    NSString *serviceHost = [self getServiceHost];
    return [NSString stringWithFormat:@"%@%@%@", serviceHost, @"insuranceService/", messageId];
}

- (RACError *)getResult:(int)httpResult fromResponse:(NSDictionary *)response {
    RACError *result = [RACError createDefaultResult];
    NSDictionary *jResult = [response objectForKey:@"result"];
    if (httpResult == ERR_NONE) {
        result.result = [[jResult objectForKey:@"statusCode"] intValue];
        result.message = [jResult objectForKey:@"statusMessage"];
    } else {
        result.result = httpResult;
    }
    return result;
}

- (void)statisticInterface:(NSString *)messageId startTime:(UInt64)start {
    [MSLog verbose:[NSString stringWithFormat:@"[http_test] %@ %llu %llu",messageId,start,[TimeUtils currentTimeMillis]]];
}

@end
