//
//  NSObject+InsuranceProtocol.m
//  Sword
//
//  Created by haorenjie on 2017/8/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "ReactiveCocoa/RACSignal.h"
#import "TimeUtils.h"

#import "PrefixHeader.pch"
#import "MSHttpProxy.h"
#import "ZKSessionManager.h"
#import "ZKProtocol.h"
#import "InsuranceProtocol.h"

@interface InsuranceProtocolTest : XCTestCase
{
    ZKProtocol *_userProtocol;
    InsuranceProtocol *_protocol;
}
@end

typedef void(^loginCallback)(BOOL success);

@implementation InsuranceProtocolTest

- (void)setUp {
    [super setUp];
    MSHttpProxy *httpService = [[MSHttpProxy alloc] initWithHost:NO];
    ZKSessionManager *sessionManager = [[ZKSessionManager alloc] initWithHttpService:httpService];
    _userProtocol =  [[ZKProtocol alloc] initWithSessionManager:sessionManager];
    _protocol = [[InsuranceProtocol alloc] initWithSessionManager:sessionManager];
}

- (void)tearDown {
    _protocol = nil;
    [super tearDown];
}

- (void)testQueryRecommendedList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query recommended insurance list."];

    [[_protocol queryRecommendedList] subscribeNext:^(MSSectionList *recommendedSection) {
        [expectation fulfill];
    } error:^(NSError *error) {
        XCTFail(@"Query recommened insurance list failed: %@", error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTFail(@"Query recommened insurance list timeout.");
    }];
}

- (void)testQuerySectionList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query insurance section list."];

    [[_protocol querySectionList] subscribeNext:^(NSArray *sectionList) {
        [expectation fulfill];
    } error:^(NSError *error) {
        XCTFail(@"Query insurance section list failed: %@", error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTFail(@"Query insurance section list timeout.");
    }];
}

- (void)testQueryInsuranceDetail {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query insurance detail."];

    [[_protocol queryInsuranceDetailWithId:@"1" wholeInfo:YES] subscribeNext:^(id x) {
        [expectation fulfill];
    } error:^(NSError *error) {
        XCTFail(@"Query insurance detail failed: %@", error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTFail(@"Query insurance detail timeout.");
    }];
}

- (void)testQueryInsuranceContent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query insurance content."];

    [[_protocol queryInsuranceContentWithId:@"1" type:INSURACE_CONTENT_TYPE_CLAIM_PROCESS] subscribeNext:^(NSArray *pictureList) {
        [expectation fulfill];
    } error:^(NSError *error) {
        XCTFail(@"Query insurance content failed: %@", error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTFail(@"Query insurance content timeout.");
    }];
}

- (void)testInsurance {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"Login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Insurance"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            InsurantInfo *insurantInfo = [[InsurantInfo alloc] init];
            insurantInfo.name = @"杨石雄";
            insurantInfo.mobile = @"13510001000";
            insurantInfo.certificateId = @"441882199301206013";
            [[_protocol insuranceWithInsuranceId:@"1" productId:@"1" effectiveDate:[TimeUtils currentTimeMillis] copiesCount:1 insurerMail:@"hao@163.com" insurant:insurantInfo] subscribeNext:^(NSString *orderId) {
                [expectation fulfill];
            } error:^(NSError *error) {
                XCTFail(@"Insurance failed: %@", error);
                [expectation fulfill];
            }];
        } else {
            XCTFail(@"Login failed for insurance.");
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTFail(@"Insurance timeout.");
    }];
}

- (void)testCancelInsurance {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"Login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Cancel insurance"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            [[_protocol cancelInsuranceWithOrderId:@"1"] subscribeError:^(NSError *error) {
                XCTFail(@"Cancel insurance failed: %@", error);
                [expectation fulfill];
            } completed:^{
                [expectation fulfill];
            }];
        } else {
            XCTFail(@"Login failed for cancel insurance.");
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTFail(@"Cancel insurance timeout.");
    }];
}

- (void)testQueryPayInfoWithOrderId {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"Login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query pay info for insurance order."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            [[_protocol queryPayInfoWithOrderId:@"1" payType:Pay_Ali] subscribeNext:^(NSDictionary *jsonObj) {
                [expectation fulfill];
            } error:^(NSError *error) {
                XCTFail(@"Query pay info for insurance order failed: %@", error);
                [expectation fulfill];
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTFail(@"Query pay info for insurance order timeout.");
    }];
}

- (void)testQueryPolicyInfo {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"Login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query policy info."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            [[_protocol queryPolicyInfoWithId:@"1"] subscribeNext:^(InsurancePolicy *policyInfo) {
                [expectation fulfill];
            } error:^(NSError *error) {
                XCTFail(@"Query policy info failed: %@", error);
                [expectation fulfill];
            }];
        } else {
            XCTFail(@"Login failed for query policy info.");
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTFail(@"Query policy info timeout.");
    }];
}

- (void)testQueryMyPolicyList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"Login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query my policy list."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            [[_protocol queryMyPolicyListWithStatus:0 lastOrderId:@"1" requestCount:10] subscribeNext:^(NSArray *policyList) {
                [expectation fulfill];
            } error:^(NSError *error) {
                XCTFail(@"Query my policy list failed: %@", error);
                [expectation fulfill];
            }];
        } else {
            XCTFail(@"Login failed for query my policy list.");
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTFail(@"Query my policy list timeout.");
    }];
}

#pragma mark - private

- (void)doLoginWithBlock:(loginCallback)callback {
    [[_userProtocol loginWithUserName:@"13510001000" password:@"VIboRoB6M5c="] subscribeNext:^(MSLoginInfo *loginInfo) {
        callback(YES);
    } error:^(NSError *error) {
        callback(NO);
    }];
}

@end
