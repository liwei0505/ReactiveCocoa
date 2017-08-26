//
//  MSUserServiceTest.m
//  Sword
//
//  Created by lee on 17/4/27.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ReactiveCocoa/RACSignal.h"
#import "ReactiveCocoa/RACSubscriber.h"
#import "PrefixHeader.pch"
#import "MSUserService.h"
#import "MSHttpProxy.h"
#import "ZKSessionManager.h"
#import "ZKProtocol.h"
#import "NSString+Ext.h"
#import "RACError.h"
#import "MSOperatingService.h"
#import "UserPoint.h"
#import "InviteInfo.h"

const NSTimeInterval TIMEOUT = 5;

@class RACSignal;
@interface MSUserServiceTest : XCTestCase {

    MSUserService *_userService;
    MSOperatingService *_operatingService;
    id _mockProtocol;
}
@end

@implementation MSUserServiceTest

NSString *PHONENUMBER = @"13112345678";
NSString *PASSWORD = @"a111111";
NSString *CODE = @"111111";

- (void)setUp {
    [super setUp];
    MSHttpProxy *httpService = [[MSHttpProxy alloc] initWithHost:NO];
    ZKSessionManager *sessionManager = [[ZKSessionManager alloc] initWithHttpService:httpService];
    ZKProtocol *protocol =  [[ZKProtocol alloc] initWithSessionManager:sessionManager];
    _mockProtocol = OCMClassMock([ZKProtocol class]);
    _userService = [[MSUserService alloc] initWithProtocol:_mockProtocol];
    _operatingService = [[MSOperatingService alloc] initWithProtocol:protocol];
}

- (void)tearDown {
    _userService = nil;
    _operatingService = nil;
    [super tearDown];
}

- (void)testUserRegist {

    XCTestExpectation *expectation = [self expectationWithDescription:@"user regist"];
    XCTestExpectation *code = [self expectationWithDescription:@"code"];
    NSString *phoneNumber = @"13112341335";
    [[_operatingService queryVerifyCodeByPhoneNumber:phoneNumber aim:AIM_REGISTER] subscribeNext:^(id x) {
    } error:^(NSError *error) {
        [code fulfill];
        XCTFail(@"get verify code error during user regist");
    } completed:^{
        [code fulfill];
    }];
    [XCTWaiter waitForExpectations:@[code] timeout:TIMEOUT];
    
    [[_userService registerWithPhoneNumber:phoneNumber password:PASSWORD verifyCode:CODE] subscribeNext:^(id x) {
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"user regist failed %@", error);
    } completed:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"user regist timeout %@",error);
    }];
    
}

- (void)testUserResetPassword {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"user reset"];
    XCTestExpectation *code = [self expectationWithDescription:@"code"];
    
    [[_operatingService queryVerifyCodeByPhoneNumber:PHONENUMBER aim:AIM_RESET_LOGIN_PASSWORD] subscribeError:^(NSError *error) {
        [code fulfill];
        XCTFail(@"get verify code error during user reset password%@",error);
    } completed:^{
        [code fulfill];
    }];
    [XCTWaiter waitForExpectations:@[code] timeout:TIMEOUT];
    
    [[_userService resetLoginPasswordWithPhoneNumber:PHONENUMBER password:[NSString desWithKey:PASSWORD key:nil] verifyCode:CODE] subscribeNext:^(id x) {
    } error:^(NSError *error) {
        [expectation fulfill];
        error = (RACError *)error;
        XCTFail(@"user reset password failed %@", error);
    } completed:^{
        [expectation fulfill];
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
    
}

- (void)testUserLogin {

    XCTestExpectation *expectation = [self expectationWithDescription:@"user login"];
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        MSLoginInfo *info = [[MSLoginInfo alloc] init];
        info.userId = @(5000);
        info.userName = @"lee";
        info.password = @"a111111";
        info.riskType = EVALUATE_STEADY;
        [subscriber sendNext:info];
        [subscriber sendCompleted];
        return nil;
    }];
    
    
    OCMStub([_mockProtocol loginWithUserName:[OCMArg any] password:[OCMArg any]]).andReturn(signal);
    
    [[_userService loginWithUserName:PHONENUMBER password:[NSString desWithKey:PASSWORD key:nil]] subscribeNext:^(MSLoginInfo *loginInfo) {
        [expectation fulfill];
        XCTAssertNotNil(loginInfo,@"login info is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"user reset password failed %@", error);
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
    
//    OCMVerify([protocol loginWithUserName:[OCMArg any] password:[OCMArg any]]);
}

- (void)testChangePassword {
    
    [self testUserLogin];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"user change password"];
    [[_userService changeOrignalPassword:[NSString desWithKey:PASSWORD key:nil] toPassword:[NSString desWithKey:@"a111111" key:nil]] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"user change password failed %@", error);
    } completed:^{
        [expectation fulfill];
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
}

- (void)testQueryMyInfo {

    [self testUserLogin];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my info"];
    [[_userService queryMyInfo] subscribeNext:^(AccountInfo *accountInfo) {
        [expectation fulfill];
        XCTAssertNotNil(accountInfo, @"account info is nil");
    
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my info failed %@",error);
    } completed:^{
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
    
}

- (void)testQueryMyAsset {

    [self testUserLogin];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my asset"];
    [[_userService queryMyAsset] subscribeNext:^(AssetInfo *assetInfo) {
        [expectation fulfill];
        XCTAssertNotNil(assetInfo, @"asset info is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my asset failed %@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
    
}

- (void)testQueryMyInvestList {

    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my invest list"];
    
    [[_userService queryMyInvestListByType:LIST_REQUEST_NEW status:STATUS_ALL] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my invest list failed %@",error);
    } completed:^{
        [expectation fulfill];
        MSListWrapper *listWrapper = _userService.userCache.investListDict[@(STATUS_ALL)];
        XCTAssertNotNil(listWrapper,@"my invest list is nil");
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
    
}

- (void)testQueryMyRedEnvelope {
    
    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my redenvelope"];
    [[_userService queryMyRedEnvelopeListByType:LIST_REQUEST_NEW status:STATUS_NONE] subscribeNext:^(NSDictionary *dict) {
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my red envelope failed %@",error);
    } completed:^{
        [expectation fulfill];
        MSListWrapper *listWrapper = _userService.userCache.redEnvelopeListDict[@(STATUS_NONE)];
        XCTAssertNotNil(listWrapper.getList,@"my red envelope is nil");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
}

- (void)testQueryRedEnvelopeForInvest {
    
    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my redenvelope list for loan id"];
    NSNumber *loanId = @(528298);
    [[_userService queryRedEnvelopeListForLoanId:loanId investAmount:[NSDecimalNumber decimalNumberWithString:@"1000"] flag:0] subscribeNext:^(NSDictionary *dict) {
        [expectation fulfill];
        XCTAssertEqual(dict[@"key_loanid"], loanId, @"red envelope loan id error");
        XCTAssertNotNil(dict[@"red_envelop_list"], @"red envelope list is nil of loanId");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query red envelope for invest failed %@", error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
    
}

- (void)testQueryMyFundsFlow {

    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my fundsflow list"];
    [[_userService queryMyFundsFlowByType:LIST_REQUEST_NEW typeCategory:TYPE_ALL timeCategory:ALL] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my fundsflow failed %@", error);
        
    } completed:^{
        [expectation fulfill];
        XCTAssertNotNil(_userService.userCache.fundsFlowList, @"my fundsflow is nil");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
}

- (void)testQueryMyInviteInfo {
    
    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my invite info"];
    [[_userService queryMyInviteInfo] subscribeNext:^(InviteInfo *info) {
        [expectation fulfill];
        XCTAssertNotNil(info, @"invite info is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my invite info failed %@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
}

- (void)testQueryMyInviteFriendList {

    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my invite friend list"];
    [[_userService queryMyInvitedFriendListByType:LIST_REQUEST_NEW] subscribeNext:^(NSArray *friendList) {
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my invite friend list failed %@", error);
    } completed:^{
        [expectation fulfill];
        XCTAssertNotNil(_userService.userCache.invitedFriendList, @"my invite friend list is nil");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
}

- (void)testQueryMyPoints {

    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my points"];
    [[_userService queryMyPoints] subscribeNext:^(UserPoint *point) {
        [expectation fulfill];
        XCTAssertNotNil(point, @"user point is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my points failed %@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
    
}

- (void)testQueryMyPointDetails {

    [self testUserLogin];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my point details"];
    [[_userService queryMyPointDetailsByType:LIST_REQUEST_NEW] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssertNotNil(_userService.userCache.myPointList, @"my point list is nil");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query my point details failed %@", error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:TIMEOUT];
}


@end
