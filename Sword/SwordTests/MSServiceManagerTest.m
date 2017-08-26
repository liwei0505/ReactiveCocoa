//
//  MSServiceManagerTest.m
//  Sword
//
//  Created by msj on 2017/5/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ReactiveCocoa/RACSignal.h"
#import "ReactiveCocoa/RACSignal+Operations.h"
#import "ReactiveCocoa/RACSubscriber.h"
#import "ReactiveCocoa/RACEXTScope.h"
#import "PrefixHeader.pch"
#import "MSUserService.h"
#import "MSPayService.h"
#import "MSOperatingService.h"
#import "MSFinanceService.h"
#import "MSCurrentService.h"
#import "MSServiceManager.h"

@interface MSServiceManagerTest : XCTestCase
{
    id _userServiceMock;
    id _payServiceMock;
    id _operatingServiceMock;
    id _financeServiceMock;
    id _currentServiceMock;
    MSServiceManager *_serviceManager;
}
@end

@implementation MSServiceManagerTest

- (void)setUp {
    [super setUp];
    _userServiceMock = OCMClassMock([MSUserService class]);
    _payServiceMock = OCMClassMock([MSPayService class]);
    _operatingServiceMock = OCMClassMock([MSOperatingService class]);
    _financeServiceMock = OCMClassMock([MSFinanceService class]);
    _currentServiceMock = OCMClassMock([MSCurrentService class]);
    
    _serviceManager = [[MSServiceManager alloc] init];
}

- (void)tearDown {
    _userServiceMock = nil;
    _payServiceMock = nil;
    _operatingServiceMock = nil;
    _financeServiceMock = nil;
    _currentServiceMock = nil;
    
    _serviceManager = nil;
    [super tearDown];
}

#pragma mark - MSUserService
- (void)testLogin {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testLogin"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        
        MSLoginInfo *info = [[MSLoginInfo alloc] init];
        info.userId = @(24124);
        info.userName = @"gefwefg";
        info.password = @"fweffw";
        info.riskType = EVALUATE_OLD;
        [subscriber sendNext:info];
        [subscriber sendCompleted];
        
        return nil;
    }] doNext:^(id x) {
        @strongify(self);
        [self queryMyAccountInfo];
        [self queryMyAssetInfo];
    }];
    OCMStub([_userServiceMock loginWithUserName:OCMOCK_ANY password:OCMOCK_ANY]).andReturn(signal);
    [[_serviceManager loginWithUserName:@"13552198435" password:@"lf458649"] subscribeNext:^(MSLoginInfo *loginInfo) {
        [expectation fulfill];
        XCTAssertNotNil(loginInfo, @"获取loginInfo失败");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取SystemConfigs失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}
#pragma mark - MSFinanceService
#pragma mark - MSOperatingService
#pragma mark - MSCurrentService
#pragma mark - MSPayService
- (void)testRechargeByVerifyCode {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRechargeByVerifyCode"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        
        return nil;
    }] doCompleted:^{
        @strongify(self);
        [self queryMyAccountInfo];
        [self queryMyAssetInfo];
    }];
    OCMStub([_payServiceMock rechargeByVerifyCode:OCMOCK_ANY]).andReturn(signal);
    [[_serviceManager rechargeByVerifyCode:@"1234"] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Recharge失败 :%@",error);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"Recharge成功");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testWithdraw {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testWithdraw"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        
        return nil;
    }] doCompleted:^{
        @strongify(self);
        [self queryMyAccountInfo];
        [self queryMyAssetInfo];
    }];
    OCMStub([_payServiceMock withdrawWithAmount:OCMOCK_ANY payPassword:OCMOCK_ANY]).andReturn(signal);
    [[_serviceManager withdrawWithAmount:[NSDecimalNumber decimalNumberWithString:@"1000"] payPassword:@"123433"] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Recharge失败 :%@",error);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"Recharge成功");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testInvest {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInvest"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        
        return nil;
    }] doCompleted:^{
        @strongify(self);
        [self queryMyAccountInfo];
        [self queryMyAssetInfo];
    }];
    OCMStub([_payServiceMock investWithLoanId:OCMOCK_ANY redEnvelopeId:OCMOCK_ANY amount:OCMOCK_ANY payPassword:OCMOCK_ANY]).andReturn(signal);
    [[_serviceManager investWithLoanId:@(1234) redEnvelopeId:nil amount:[NSDecimalNumber decimalNumberWithString:@"1234"] payPassword:@"124124"] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Recharge失败 :%@",error);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"Recharge成功");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testDebt {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testDebt"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        
        return nil;
    }] doCompleted:^{
        @strongify(self);
        [self queryMyAccountInfo];
        [self queryMyAssetInfo];
    }];
    OCMStub([_payServiceMock buyDebtOfId:OCMOCK_ANY payPassword:OCMOCK_ANY]).andReturn(signal);
    [[_serviceManager buyDebtOfId:@(1234) payPassword:@"342323"] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Recharge失败 :%@",error);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"Recharge成功");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testPurchaseCurrent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testPurchaseCurrent"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        
        return nil;
    }] doCompleted:^{
        @strongify(self);
        [self queryMyAccountInfo];
        [self queryMyAssetInfo];
    }];
    OCMStub([_payServiceMock purchaseCurrentWithID:OCMOCK_ANY amount:OCMOCK_ANY password:OCMOCK_ANY]).andReturn(signal);
    [[_serviceManager purchaseCurrentWithID:@(1234) amount:[NSDecimalNumber decimalNumberWithString:@"10000"] password:@"1234"] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Recharge失败 :%@",error);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"Recharge成功");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testRedeemCurrent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRedeemCurrent"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        
        return nil;
    }] doCompleted:^{
        @strongify(self);
        [self queryMyAccountInfo];
        [self queryMyAssetInfo];
    }];
    OCMStub([_payServiceMock redeemCurrentWithID:OCMOCK_ANY amount:OCMOCK_ANY password:OCMOCK_ANY]).andReturn(signal);
    [[_serviceManager redeemCurrentWithID:@(1234) amount:[NSDecimalNumber decimalNumberWithString:@"10000"] password:@"1234"] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Recharge失败 :%@",error);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"Recharge成功");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

#pragma mark - Private
- (void)queryMyAccountInfo {
    XCTestExpectation *expectation = [self expectationWithDescription:@"queryMyInfo"];
    @weakify(self);
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        AccountInfo *accountInfo = [[AccountInfo alloc] init];
        [subscriber sendNext:accountInfo];
        [subscriber sendCompleted];
        
        return nil;
    }] doNext:^(id x) {
        @strongify(self);
        [self querySystemConfigInfo];
    }];
    OCMStub([_userServiceMock queryMyInfo]).andReturn(signal);
    [[_serviceManager queryMyInfo] subscribeNext:^(AccountInfo *accountInfo) {
        [expectation fulfill];
        XCTAssertNotNil(accountInfo, @"获取accountInfo失败");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取SystemConfigs失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)queryMyAssetInfo {}
- (void)querySystemConfigInfo {}

@end
