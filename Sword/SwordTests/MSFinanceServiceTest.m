//
//  MSTest.m
//  Sword
//
//  Created by lee on 2017/5/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PrefixHeader.pch"
#import "MSFinanceService.h"
#import "ReactiveCocoa/RACSignal.h"
#import "MSHttpProxy.h"
#import "ZKSessionManager.h"
#import "ZKProtocol.h"
#import "NSString+Ext.h"
#import "RACError.h"
#import "DebtAgreementInfo.h"

@interface MSFinanceServiceTest : XCTestCase {

    MSFinanceService *_financeService;
    ZKProtocol *_protocol;
}

@end

@implementation MSFinanceServiceTest

- (void)setUp {
    [super setUp];
    MSHttpProxy *httpProxy = [[MSHttpProxy alloc] initWithHost:NO];
    ZKSessionManager *sessionManager = [[ZKSessionManager alloc] initWithHttpService:httpProxy];
    _protocol =  [[ZKProtocol alloc] initWithSessionManager:sessionManager];
    _financeService = [[MSFinanceService alloc] initWithProtocol:_protocol];
}

- (void)tearDown {
    _financeService = nil;
    _protocol = nil;
    [super tearDown];
}

- (void)testQueryRecommendedList {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"query recommended list"];
    [[_financeService queryRecommendedList] subscribeNext:^(NSArray *list) {
        [expectation fulfill];
        XCTAssertNotNil(list, @"recommended list is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query recommended failed %@", error);
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryLoanList {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"query loan list"];
    [self doLoginWithBlock:^(BOOL success) {
        if (success) {
            [[_financeService queryLoanListByType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                XCTAssertNotNil(dict[@"list"], @"loan list is nil");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"query loan list failed %@",error);
            }];
        } else {
            [expectation fulfill];
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    
}

- (void)testQueryLoanDetail {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"query loan detail"];
    NSNumber *queryId = @(528298);
    
    [[_financeService queryLoanDetailById:queryId] subscribeNext:^(NSNumber *loanId) {
        [expectation fulfill];
        XCTAssertEqualObjects(loanId, queryId, @"query loan detail id error");
        XCTAssertNotNil([_financeService.financeCache.investDict objectForKey:loanId], @"loan detail is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query loan detail");
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    
}

/*返回内容为空
- (void)testProjectInstruction {

    XCTestExpectation *expectation = [self expectationWithDescription:@"query project instruction"];
    [self doLoginWithBlock:^(BOOL success) {
        if (success) {
            ProjectInstructionType type = INSTRUCTION_TYPE_RISK_WARNING;
            [[_financeService queryProjectInstructionByType:type loanId:@(528298)] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                XCTAssertNotNil(dict[@"list"],@"project instruction is nil");
                XCTAssertEqual(dict[@"type"], @(type), @"project instruction type error");
            } error:^(NSError *error) {
                [expectation fulfill];
                error = (RACError *)error;
                XCTFail(@"query project instruction failed %@",error);
            }];
        } else {
            [expectation fulfill];
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}
*/
- (void)testLoanInvestorList {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"query loan investor list"];
    NSNumber *queryId = @(528298);
    [[_financeService queryLoanInvestorListByType:LIST_REQUEST_NEW loanId:queryId] subscribeNext:^(NSNumber *loanId) {
        [expectation fulfill];
        XCTAssertEqualObjects(queryId, loanId, @"query loan investor list loanId error");
        XCTAssertNotNil(_financeService.financeCache.investList, @"invest list is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query loan investor list failed %@", error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testContractTemplate {

    XCTestExpectation *expectation = [self expectationWithDescription:@"query contract template"];
    [self doLoginWithBlock:^(BOOL success) {
        if (success) {
            [[_financeService queryInvestContractByLoanId:@(528298)] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                XCTAssertNotNil(dict,@"contract template dictionary is nil");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"query contract template failed %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryDebtList {

    XCTestExpectation *expectation = [self expectationWithDescription:@"query debt list"];
    [[_financeService queryDebtListByType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
        [expectation fulfill];
        XCTAssertNotNil(dict[@"list"], @"debt list is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query debt list failed %@", error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryDebtDetail {

    XCTestExpectation *expectation = [self expectationWithDescription:@"query debt detail"];
    NSNumber *queryId = @(2428);
    [[_financeService queryDebtDetailById:queryId] subscribeNext:^(NSNumber *debtId) {
        [expectation fulfill];
        XCTAssertEqualObjects(debtId, queryId, @"query debt detail id error");
        XCTAssertNotNil([_financeService.financeCache.attornDict objectForKey:debtId],@"debt detail is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query debt detail failed %@", error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryDebtAgreement {

    XCTestExpectation *expectation = [self expectationWithDescription:@"query debt agreement"];
    [self doLoginWithBlock:^(BOOL success) {
        if (success) {
            [[_financeService queryDebtAgreementById:@(2428)] subscribeNext:^(DebtAgreementInfo *info) {
                [expectation fulfill];
                XCTAssertNotNil(info, @"debt agreement info is nil");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"quey debt agreement failed %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
    
}

- (void)doLoginWithBlock:(void(^)(BOOL success))completion {
    
    [[_protocol loginWithUserName:@"13112345678" password:[NSString desWithKey:@"a111111" key:nil]] subscribeNext:^(id x) {
        
        completion(YES);
    } error:^(NSError *error) {
        completion(NO);
    }];
}


@end
