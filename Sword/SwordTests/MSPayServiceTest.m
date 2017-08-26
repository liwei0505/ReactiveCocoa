//
//  MSPayServiceTest.m
//  Sword
//
//  Created by msj on 2017/5/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ReactiveCocoa/RACSignal.h"
#import "ReactiveCocoa/RACSubscriber.h"
#import "PrefixHeader.pch"
#import "MSPayService.h"
#import "ZKProtocol.h"
#import "MSConsts.h"
#import "RACError.h"
#import "BankInfo.h"
#import "MSRechargeOne.h"
#import "MSRechargeTwo.h"
#import "MSRechargeThree.h"
#import "MSDrawCash.h"
#import "MSSubmitInvest.h"
#import "MSBuyDebt.h"
#import "CurrentPurchaseNotice.h"
#import "CurrentRedeemConfig.h"

@interface MSPayServiceTest : XCTestCase
{
    MSPayService *_payServiceMock;
    id _protocolMock;
}
@end

@implementation MSPayServiceTest

#pragma mark - test
- (void)setUp {
    [super setUp];
    _protocolMock = OCMClassMock([ZKProtocol class]);
    _payServiceMock = [[MSPayService alloc] initWithProtocol:_protocolMock];
    
}

- (void)tearDown {
    _protocolMock = nil;
    _payServiceMock = nil;
    [super tearDown];
}

- (void)testBindCard {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testBindCard"];
    RACSignal *bindSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendCompleted];
        return nil;
    }];

    OCMStub([_protocolMock bindCardRealName:OCMOCK_ANY idCard:OCMOCK_ANY bankId:OCMOCK_ANY bankCard:OCMOCK_ANY phone:OCMOCK_ANY verifyCode:OCMOCK_ANY]).andReturn(bindSignal);

    [[_payServiceMock bindCardWithUserName:@"昌子寒" idCardNumber:@"230111198909273320" phoneNumber:@"13552199583" bankId:@"ABC" bankCardNumber:@"6228481405123708018" verifyCode:@"111111"] subscribeError:^(NSError *error) {
        RACError *reqResult = (RACError *)error;
        [expectation fulfill];
        XCTFail(@"绑卡失败 :%@====%d",reqResult.message, reqResult.result);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"绑卡成功");
    }];

    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQuerySupportBankList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQuerySupportBankList"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        BankInfo *bank = [BankInfo new];
        bank.bankId = @"ABC";
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:bank];
        [subscriber sendNext:arr];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock querySupportBankList:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock querySupportBankListByIds:@[@"abc"]] subscribeNext:^(NSArray *bankList) {
        [expectation fulfill];
        XCTAssertNotNil(bankList, @"银行列表为空");
        XCTAssertGreaterThan(bankList.count, 0, @"银行列表为空");
        
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取SupportBankList失败 :%@",error);
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testSetPayPassword {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSetPayPassword"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
//        RACError *result = [RACError createDefaultResult];
//        result.result = ERR_TRADE_PASSWORD_EXIST;
//        result.message = @"交易密码已经存在";
        
        //success test
        RACError *result = [RACError createDefaultResult];
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock userSetTradePassword:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock setPayPassword:@"123456"] subscribeNext:^(RACError *reqResult) {
        [expectation fulfill];
        if (reqResult.result == ERR_NONE) {
            XCTAssert(@"修改支付密码成功");
        } else {
            XCTFail(@"修改支付密码失败 :%@===%d",reqResult.message, reqResult.result);
        }
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testResetPayPasswordOne {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testResetPayPasswordOne"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"8239hhug839$%^&*("];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock resetTradePasswordPhone:OCMOCK_ANY verifyCode:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock verifyPayBoundPhoneNumber:@"13552198435" verifyCode:@"123456"] subscribeNext:^(NSString *token) {
        [expectation fulfill];
        XCTAssertNotNil(token, @"token 为空");
        XCTAssertGreaterThan(token.length, 0, @"token 为空");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"重置交易密码失败，%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testResetPayPasswordTwo {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testResetPayPasswordTwo"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACError *result = [RACError createDefaultResult];
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock resetTradePasswordRealName:OCMOCK_ANY idCard:OCMOCK_ANY bankCard:OCMOCK_ANY token:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock verifyPayBoundUserName:@"刘飞" idCardNumber:@"4342345678987654345678" bankCardNumber:@"2345678909876543456"] subscribeNext:^(RACError *result) {
        [expectation fulfill];
        if (result.result == ERR_NONE) {
            XCTAssert(@"重置支付密码第二步成功");
        } else {
            XCTFail(@"重置支付密码第二步失败 :%@===%d",result.message, result.result);
        }
        
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testResetPayPasswordThree {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testResetPayPasswordThree"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACError *result = [RACError createDefaultResult];
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock userResetTradePassword:OCMOCK_ANY token:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock resetPayPassword:@"123456"] subscribeNext:^(RACError *result) {
        [expectation fulfill];
        if (result.result == ERR_NONE) {
            XCTAssert(@"重置支付密码第三步成功");
        } else {
            XCTFail(@"重置支付密码第三步失败 :%@===%d",result.message, result.result);
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testRechargeOne {
    /*
     MSRechargeOneModeSuccess,
     MSRechargeOneModeError,
     MSRechargeOneModeFrozen,
     MSRechargeOneModePassWordError,
     MSRechargeOneModePassWordMoreThanMax,
     MSRechargeOneModeNoSetPassWord,
     MSRechargeOneModeNoParams
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRechargeOne"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        MSRechargeOne *result = [[MSRechargeOne alloc] init];
        result.result = MSRechargeOneModeSuccess;
        [subscriber sendError:result];
        
        //success test
//        [subscriber sendNext:@{}];
//        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryChargeOneStepMoney:@"100" password:@"123456"]).andReturn(signal);
    [[_payServiceMock verifyRechargeInfoWithAmount:[NSDecimalNumber decimalNumberWithString:@"100"] payPassword:@"123456"] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssert(@"充值第一步成功");
    } error:^(NSError *error) {
        [expectation fulfill];
        MSRechargeOne *result = (MSRechargeOne *)error;
        
        if (result.result < 0) {
            XCTFail(@"充值第一步失败：%@",result);
        }else {
            switch (result.result) {
                case MSRechargeOneModeError:
                case MSRechargeOneModeFrozen:
                case MSRechargeOneModePassWordError:
                case MSRechargeOneModePassWordMoreThanMax:
                case MSRechargeOneModeNoSetPassWord:
                case MSRechargeOneModeNoParams:
                {
                    XCTFail(@"充值第一步失败：%@",result);
                    break;
                }
                case MSRechargeOneModeSuccess:
                {
                    XCTAssert(@"充值第一步成功");
                    break;
                }
                default:
                    break;
            }
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testRechargeTwo {
    /*
     MSRechargeTwoModeSuccess,
     MSRechargeTwoModeError,
     MSRechargeTwoModeGetVeriCodeError,
     MSRechargeTwoModeFrozen,
     MSRechargeTwoModeNoParams,
     MSRechargeTwoModeTooFrequent,
     MSRechargeTwoModeMoreThanRequestMax
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRechargeTwo"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        MSRechargeTwo *result = [[MSRechargeTwo alloc] init];
        result.result = MSRechargeTwoModeSuccess;
        [subscriber sendError:result];
        
        //success test
        //        [subscriber sendNext:@"成功"];
        //        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryChargeTwoStepWithRechargeNo:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock queryRechargeVerifyCode] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssert(@"充值第二步成功");
    } error:^(NSError *error) {
        [expectation fulfill];
        MSRechargeTwo *result = (MSRechargeTwo *)error;
        
        if (result.result < 0) {
            XCTFail(@"充值第二步失败：%@",result);
        }else {
            switch (result.result) {
                case MSRechargeTwoModeError:
                case MSRechargeTwoModeGetVeriCodeError:
                case MSRechargeTwoModeFrozen:
                case MSRechargeTwoModeNoParams:
                case MSRechargeTwoModeTooFrequent:
                case MSRechargeTwoModeMoreThanRequestMax:
                {
                    XCTFail(@"充值第二步失败：%@",result);
                    break;
                }
                case MSRechargeTwoModeSuccess:
                {
                    XCTAssert(@"充值第二步成功");
                    break;
                }
                default:
                    break;
            }
        }
        
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testRechargeThree {
    /*
     MSRechargeThreeModeSuccess,
     MSRechargeThreeModeError,
     MSRechargeThreeModeNoParams,
     MSRechargeThreeModeFrozen,
     MSRechargeThreeModeVeriCodeError
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRechargeThree"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        MSRechargeThree *result = [[MSRechargeThree alloc] init];
        result.result = MSRechargeThreeModeSuccess;
        [subscriber sendError:result];
        
        //success test
        //        [subscriber sendNext:@"成功"];
        //        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryChargeThreeStepRechargeNo:OCMOCK_ANY vCode:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock rechargeByVerifyCode:@"123456"] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssert(@"充值第三步成功");
    } error:^(NSError *error) {
        [expectation fulfill];
        MSRechargeThree *result = (MSRechargeThree *)error;
        
        if (result.result < 0) {
            XCTFail(@"充值第三步失败：%@",result);
        }else {
            switch (result.result) {
                case MSRechargeThreeModeError:
                case MSRechargeThreeModeNoParams:
                case MSRechargeThreeModeFrozen:
                case MSRechargeThreeModeVeriCodeError:
                {
                    XCTFail(@"充值第三步失败：%@",result);
                    break;
                }
                case MSRechargeThreeModeSuccess:
                {
                    XCTAssert(@"充值第三步成功");
                    break;
                }
                default:
                    break;
            }
        }
        
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testCash {
    /*
     MSDrawCashModeSuccess,
     MSDrawCashModeFrozen,
     MSDrawCashModePassWordError,
     MSDrawCashModePassWordMoreThanMax,
     MSDrawCashModeNoBindCard,
     MSDrawCashModeNoSetPassWord,
     MSDrawCashModeNoParams,
     MSDrawCashModeMoneyShouldMoreThanZero,
     MSDrawCashModeNoEnoughBalance,
     MSDrawCashModeCashCountTooMuch,
     MSDrawCashModeCashBeyondDayLimit,
     MSDrawCashModeCashBeyondMonthLimit,
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCash"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        MSDrawCash *result = [[MSDrawCash alloc] init];
        result.result = MSRechargeThreeModeSuccess;
        [subscriber sendError:result];
        
        //success test
        //        [subscriber sendNext:@"成功"];
        //        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryDrawcash:OCMOCK_ANY password:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock withdrawWithAmount:[NSDecimalNumber decimalNumberWithString:@"100"] payPassword:@"123456"] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssert(@"提现成功");
    } error:^(NSError *error) {
        [expectation fulfill];
        MSRechargeThree *result = (MSRechargeThree *)error;
        
        if (result.result < 0) {
            XCTFail(@"提现失败：%@",result);
        }else {
            switch (result.result) {
                case MSDrawCashModeFrozen:
                case MSDrawCashModePassWordError:
                case MSDrawCashModePassWordMoreThanMax:
                case MSDrawCashModeNoBindCard:
                case MSDrawCashModeNoSetPassWord:
                case MSDrawCashModeNoParams:
                case MSDrawCashModeMoneyShouldMoreThanZero:
                case MSDrawCashModeNoEnoughBalance:
                case MSDrawCashModeCashCountTooMuch:
                case MSDrawCashModeCashBeyondDayLimit:
                case MSDrawCashModeCashBeyondMonthLimit:
                {
                    XCTFail(@"提现失败：%@",result);
                    break;
                }
                case MSDrawCashModeSuccess:
                {
                    XCTAssert(@"提现成功");
                    break;
                }
                default:
                    break;
            }
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testInvest {
    /*
     MSSubmitInvestModeSuccess,
     MSSubmitInvestModeError,
     MSSubmitInvestModePassWordError,
     MSSubmitInvestModePassWordMoreThanMax,
     MSSubmitInvestModeNoSetPassWord,
     MSSubmitInvestModeNoParams,
     MSSubmitInvestModeNoEnoughBalance
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testInvest"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        MSSubmitInvest *result = [[MSSubmitInvest alloc] init];
        result.result = MSRechargeThreeModeSuccess;
        [subscriber sendError:result];
        
        //success test
        //        [subscriber sendNext:@"成功"];
        //        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryNewInvestLoadId:OCMOCK_ANY redBagId:OCMOCK_ANY password:OCMOCK_ANY money:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock investWithLoanId:@(23432) redEnvelopeId:nil amount:[NSDecimalNumber decimalNumberWithString:@"10000"] payPassword:@"242312"] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssert(@"投标成功");
    } error:^(NSError *error) {
        [expectation fulfill];
        MSRechargeThree *result = (MSRechargeThree *)error;
        
        if (result.result < 0) {
            XCTFail(@"投标失败：%@",result);
        }else {
            switch (result.result) {
                case MSDrawCashModeFrozen:
                case MSSubmitInvestModePassWordError:
                case MSSubmitInvestModePassWordMoreThanMax:
                case MSSubmitInvestModeNoSetPassWord:
                case MSSubmitInvestModeNoParams:
                case MSSubmitInvestModeNoEnoughBalance:
                {
                    XCTFail(@"投标失败：%@",result);
                    break;
                }
                case MSSubmitInvestModeSuccess:
                {
                    XCTAssert(@"投标成功");
                    break;
                }
                default:
                    break;
            }
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testbuyDebt {
    /*
     MSBuyDebtModeSuccess,
     MSBuyDebtModeError,
     MSBuyDebtModePassWordError,
     MSBuyDebtModePassWordMoreThanMax,
     MSBuyDebtModeNoSetPassWord,
     MSBuyDebtModeNoParams,
     MSBuyDebtModeNoSupport,
     MSBuyDebtModeNoEnoughBalance
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testbuyDebt"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        MSBuyDebt *result = [[MSBuyDebt alloc] init];
        result.result = MSBuyDebtModeSuccess;
        [subscriber sendError:result];
        
        //success test
        //        [subscriber sendNext:@"成功"];
        //        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryBuyDebt:OCMOCK_ANY password:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock buyDebtOfId:@(21424) payPassword:@"123456"] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssert(@"认购成功");
    } error:^(NSError *error) {
        [expectation fulfill];
        MSRechargeThree *result = (MSRechargeThree *)error;
        
        if (result.result < 0) {
            XCTFail(@"认购失败：%@",result);
        }else {
            switch (result.result) {
                case MSBuyDebtModeError:
                case MSBuyDebtModePassWordError:
                case MSBuyDebtModePassWordMoreThanMax:
                case MSBuyDebtModeNoSetPassWord:
                case MSBuyDebtModeNoParams:
                case MSBuyDebtModeNoSupport:
                case MSBuyDebtModeNoEnoughBalance:
                {
                    XCTFail(@"认购失败：%@",result);
                    break;
                }
                case MSBuyDebtModeSuccess:
                {
                    XCTAssert(@"认购成功");
                    break;
                }
                default:
                    break;
            }
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testPurchaseCurrent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testPurchaseCurrent"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
//        RACError *result = [RACError createDefaultResult];
//        result.result = -1;
//        [subscriber sendError:result];
        
        //success test
        CurrentPurchaseNotice *notice = [[CurrentPurchaseNotice alloc] init];
        notice.purchaseDate = 1494204102;
        notice.beginInterestDate = 1494204102;
        notice.earningsReceiveDate = 1494204102;
        [subscriber sendNext:notice];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock purchaseCurrentWithID:OCMOCK_ANY amount:OCMOCK_ANY password:OCMOCK_ANY]).andReturn(signal);
    [[_payServiceMock purchaseCurrentWithID:@(123455) amount:[NSDecimalNumber decimalNumberWithString:@"100"] password:@"123456"] subscribeNext:^(CurrentPurchaseNotice *notice) {
        XCTAssertNotNil(notice, @"活期认购失败");
        XCTAssertGreaterThan(notice.purchaseDate, 0, @"活期认购失败");
        XCTAssertGreaterThan(notice.beginInterestDate, 0, @"活期认购失败");
        XCTAssertGreaterThan(notice.earningsReceiveDate, 0, @"活期认购失败");
    } error:^(NSError *error) {
        XCTFail(@"活期认购失败：%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testRedeemCurrent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRedeemCurrent"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        CurrentRedeemNotice *notice = [[CurrentRedeemNotice alloc] init];
        notice.redeemApplyDate = 1494204102;
        notice.earningsToBeReceiveDate = 1494204102;
        [subscriber sendNext:notice];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock redeemCurrentWithID:@(123456) amount:[NSDecimalNumber decimalNumberWithString:@"100"] password:@"123455"]).andReturn(signal);
    [[_payServiceMock redeemCurrentWithID:@(123456) amount:[NSDecimalNumber decimalNumberWithString:@"100"] password:@"123455"] subscribeNext:^(CurrentRedeemNotice *notice) {
        XCTAssertNotNil(notice, @"活期赎回失败");
        XCTAssertGreaterThan(notice.redeemApplyDate, 0, @"活期赎回失败");
        XCTAssertGreaterThan(notice.earningsToBeReceiveDate, 0, @"活期赎回失败");
    } error:^(NSError *error) {
        XCTFail(@"活期赎回失败：%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}
@end
