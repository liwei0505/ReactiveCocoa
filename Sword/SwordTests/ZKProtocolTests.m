//
//  ZKProtocolTests.m
//  Sword
//
//  Created by haorenjie on 2017/4/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReactiveCocoa/RACSignal.h"

#import "PrefixHeader.pch"
#import "MSHttpProxy.h"
#import "ZKSessionManager.h"
#import "ZKProtocol.h"
#import "MSLoginInfo.h"
#import "CurrentPurchaseConfig.h"
#import "CurrentRedeemConfig.h"
#import "CurrentPurchaseNotice.h"
#import "AssetInfo.h"
#import "CurrentDetail.h"
#import "NSString+Ext.h"
#import "InviteInfo.h"
#import "AccountInfo.h"
#import "BannerInfo.h"
#import "SystemConfigs.h"
#import "InviteCode.h"
#import "RACError.h"
#import "UserPoint.h"
#import "LoanDetail.h"
#import "DebtDetail.h"
#import "MSTextUtils.h"
#import "UpdateInfo.h"
#import "RiskInfo.h"
#import "DebtAgreementInfo.h"

#define TYPE @"type"
#define LIST @"list"
#define TOTALCOUNT @"totalCount"
#define LOANID  @"loanId"
#define CONTENT @"content"
#define STATUS  @"status"

//#define CURRENT_API_TEST

typedef void(^loginCallback)(BOOL success);
typedef void(^queryVerifyCodeCallback)(RACError *error);

@interface ZKProtocolTests : XCTestCase
{
    ZKProtocol *_protocol;
}

@end

@implementation ZKProtocolTests

- (void)setUp {
    [super setUp];
    MSHttpProxy *httpService = [[MSHttpProxy alloc] initWithHost:NO];
    ZKSessionManager *sessionManager = [[ZKSessionManager alloc] initWithHttpService:httpService];
    _protocol =  [[ZKProtocol alloc] initWithSessionManager:sessionManager];
}

- (void)tearDown {
    _protocol = nil;
    [super tearDown];
}

#pragma mark - user auth

- (void)testLogin {
    XCTestExpectation *expectation = [self expectationWithDescription:@"login"];
    [[_protocol loginWithUserName:@"13510001000" password:@"VIboRoB6M5c="] subscribeNext:^(MSLoginInfo *loginInfo) {
        [expectation fulfill];
        XCTAssertNotNil(loginInfo, "Login info is nil.");
        XCTAssertNotNil(loginInfo.userId, "Login user id is nil.");
        XCTAssertNotNil(loginInfo.userName, "Login user name is nil.");
        XCTAssertNotNil(loginInfo.password, "Login password is nil.");
        XCTAssert(loginInfo.riskType >= 0 && loginInfo.riskType < 5, "Risk type is invalid.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Login failed, %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Login timeout: %@", error);
    }];
}

- (void)testRegister {
    XCTestExpectation *vcodeQueryExpactation = [self expectationWithDescription:@"query verify code"];
    XCTestExpectation *registerExpectation = [self expectationWithDescription:@"register"];

    NSString *phoneNumber = @"13540007000";
    [[_protocol queryVerifyCodeByPhoneNumber:phoneNumber aim:AIM_REGISTER] subscribeError:^(NSError *error) {
        [vcodeQueryExpactation fulfill];
        XCTFail(@"Query verify code failed, %@", error);
    } completed:^{
        [vcodeQueryExpactation fulfill];

        [[_protocol registerWithPhoneNumber:phoneNumber password:@"i1ZZbKOk3+g=" verifyCode:@"111111"] subscribeError:^(NSError *error) {
            [registerExpectation fulfill];
            XCTFail(@"Register failed, %@", error);
        } completed:^{
            [registerExpectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Register timeout: %@", error);
    }];
}

- (void)testResetAndChangeLoginPassword {

    XCTestExpectation *expactation = [self expectationWithDescription:@"query verify code"];
    XCTestExpectation *restExpectation = [self expectationWithDescription:@"reset login password"];
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *changeExpectation = [self expectationWithDescription:@"change login password"];

    NSString *origPassword = [NSString desWithKey:@"abcd1234" key:nil];

    [[_protocol queryVerifyCodeByPhoneNumber:@"13510001000" aim:AIM_RESET_LOGIN_PASSWORD] subscribeError:^(NSError *error) {
        [expactation fulfill];
        XCTFail(@"Query verify code failed, %@", error);
    } completed:^{
        [expactation fulfill];

        [[_protocol resetLoginPasswordWithPhoneNumber:@"13510001000" password:[NSString desWithKey:@"abcd1234" key:nil] verifyCode:@"111111"] subscribeError:^(NSError *error) {
            [restExpectation fulfill];
            XCTFail(@"Reset login password failed: %@", error);
        } completed:^{
            [restExpectation fulfill];

            [[_protocol loginWithUserName:@"13510001000" password:origPassword] subscribeNext:^(MSLoginInfo *loginInfo) {
                [loginExpectation fulfill];

                [[_protocol changePasswordWithUserName:@"13510001000" origPassword:origPassword newPassword:[NSString desWithKey:@"abc123" key:nil]] subscribeError:^(NSError *error) {
                    [changeExpectation fulfill];
                    XCTFail(@"Change login password failed: %@", error);
                } completed:^{
                    [changeExpectation fulfill];
                }];
            } error:^(NSError *error) {
                [loginExpectation fulfill];
                XCTFail(@"Login failed for change login password.");
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Reset and change login password timeout: %@", error);
    }];
}

- (void)testQueryMyAccount {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my account."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryMyAccountInfo] subscribeNext:^(AccountInfo *accountInfo) {
                [expectation fulfill];
                XCTAssertNotNil(accountInfo, @"Account info is nil.");
                XCTAssertNotNil(accountInfo.phoneNumber, @"Phone number is nil.");
                XCTAssertNotNil(accountInfo.nickName, @"Nick name is nil.");
                XCTAssert(accountInfo.payStatus >= 0 && accountInfo.payStatus <= 3, @"Unexpected pay status.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my account info failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query my account info timeout: %@", error);
    }];
}

#pragma mark - current

- (void)testQueryMyAsset {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my asset"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryMyAsset] subscribeNext:^(AssetInfo *assetInfo) {
                [expectation fulfill];
                XCTAssertNotNil(assetInfo, @"Asset info is nil.");
                XCTAssertNotNil(assetInfo.balance, @"Balance is nil.");
                XCTAssertNotNil(assetInfo.withdrawFrozenAmount, @"Withdraw frozen amount is nil.");
                XCTAssertNotNil(assetInfo.regularAsset, @"Regular asset is nil.");
                XCTAssertNotNil(assetInfo.regularAsset.tobeReceivedPrincipal, @"Regular to be received principal is nil.");
                XCTAssertNotNil(assetInfo.regularAsset.tobeReceivedInterest, @"Regular to be received interest is nil.");
                XCTAssertNotNil(assetInfo.regularAsset.investFrozenAmount, @"Invest frozen amount is nil.");
                XCTAssertNotNil(assetInfo.currentAsset, @"Current asset is nil.");
                XCTAssertNotNil(assetInfo.currentAsset.investAmount, @"Current invest amount is nil.");
                XCTAssertNotNil(assetInfo.currentAsset.addUpAmount, @"Current addup amount is nil.");
                XCTAssertNotNil(assetInfo.currentAsset.purchaseFrozenAmount, @"Current purchase frozen amount is nil.");
                XCTAssertNotNil(assetInfo.currentAsset.redeemFrozenAmount, @"Current redeem frozen amount is nil.");
                XCTAssertNotNil(assetInfo.currentAsset.historyAddUpAmount, @"Current history addup amount is nil.");
                XCTAssertNotNil(assetInfo.currentAsset.yesterdayEarnings, @"Current yesterday earnings is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"query my asset failed.");
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
}

- (void)testQueryCurrentList {
#ifdef CURRENT_API_TEST
    XCTestExpectation *expectation = [self expectationWithDescription:@"query current list."];
    [[_protocol queryCurrentListWithLastID:[NSNumber numberWithInt:-1] pageSize:10 isRecommended:YES] subscribeNext:^(NSArray *currentList) {
        [expectation fulfill];
        XCTAssertNotNil(currentList, @"Current list is nil.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query current list failed.");
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
#endif
}

- (void)testQueryCurrentDetail {
#ifdef CURRENT_API_TEST
    NSNumber *currentID = [NSNumber numberWithInteger:5];

    XCTestExpectation *expectation = [self expectationWithDescription:@"query current detail."];
    [[_protocol queryCurrentDetail:currentID] subscribeNext:^(CurrentDetail *currentDetail) {
        [expectation fulfill];
        XCTAssertNotNil(currentDetail, @"Current detail is nil.");
        XCTAssertNotNil(currentDetail.earningsPer10000, @"Earnings per 10000 is nil.");
        XCTAssert(currentDetail.maxDisplayInterestRate > 0, @"Max display interest rate is 0.");
        XCTAssert(currentDetail.minDisplayInterestRate > 0, @"Min display interest rate is 0.");
        XCTAssert(currentDetail.intervalRateCount > 0, @"Interval rate count is 0.");
        XCTAssertNotNil(currentDetail.last7DaysInterestRates, @"last 7 days interest rates is nil.");
        XCTAssertNotNil(currentDetail.investRulesURL, @"Invest rules url.");
        XCTAssertNotNil(currentDetail.productInfo, @"Product info is nil.");
        XCTAssertNotNil(currentDetail.productInfo.productManager, @"Product manager is nil.");
        XCTAssertNotNil(currentDetail.productInfo.items, @"Product items is nil.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"query current detail failed.");
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
#endif
}

- (void)testQueryCurrentEarningsHistory {
#ifdef CURRENT_API_TEST
    NSNumber *currentID = [NSNumber numberWithInteger:5];

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query earnings history"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryCurrentEarningsHistoryWithID:currentID lastEarningsDate:-1 pageSize:10] subscribeNext:^(NSArray *earningsHistory) {
                [expectation fulfill];
                XCTAssertNotNil(earningsHistory, @"Earnings history should not be nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query earnings history failed.");
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
#endif
}

- (void)testQueryCurrentPurchaseConfig {
#ifdef CURRENT_API_TEST
    NSNumber *currentID = [NSNumber numberWithInteger:5];

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query current purchase config."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryCurrentPurchaseConfig:currentID] subscribeNext:^(CurrentPurchaseConfig *config) {
                [expectation fulfill];
                XCTAssertNotNil(config, @"Current purchase config is nil.");
                XCTAssert(config.beginInterestDate > 0, @"Begin interest date is 0.");
                XCTAssertNotNil(config.canPurchaseLimit, @"Can purchase limit is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query current purchase config failed.");
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
#endif
}

- (void)testPurchaseCurrent {
#ifdef CURRENT_API_TEST
    NSNumber *currentID = [NSNumber numberWithInteger:5];

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"purchase current"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol purchaseCurrentWithID:currentID amount:[NSDecimalNumber decimalNumberWithString:@"100"] password:[NSString desWithKey:@"123456" key:nil]] subscribeNext:^(CurrentPurchaseNotice *notice) {
                [expectation fulfill];
                XCTAssertNotNil(notice, @"Current purchase notice is nil.");
                XCTAssert(notice.purchaseDate > 0, @"purchase data is 0.");
                XCTAssert(notice.beginInterestDate > 0, @"begin interest date is 0.");
                XCTAssert(notice.earningsReceiveDate > 0, @"earnings receive date is 0.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Purchase current failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
#endif
}

- (void)testQueryCurrentRedeemConfig {
#ifdef CURRENT_API_TEST
    NSNumber *currentID = [NSNumber numberWithInteger:5];

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query current redeem config."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryCurrentRedeemConfig:currentID] subscribeNext:^(CurrentRedeemConfig *config) {
                [expectation fulfill];
                XCTAssertNotNil(config, @"Current redeem config is nil.");
                XCTAssert(config.redeemApplyDate > 0, @"Redeem apply date is 0.");
                XCTAssert(config.earningsReceiveDate > 0, @"Earnings receive date is 0.");
                XCTAssert(config.leftCanRedeemCount >= -1, @"left can redeem count < -1.");
                XCTAssertNotNil(config.leftCanRedeemAmount, @"left can redeem amount is nil.");
                XCTAssertNotNil(config.redeemRulesURL, @"redeem rules url is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query current redeem config failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
#endif
}

- (void)testRedeemCurrent {
#ifdef CURRENT_API_TEST
    NSNumber *currentID = [NSNumber numberWithInteger:5];

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"redeem current"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol redeemCurrentWithID:currentID amount:[NSDecimalNumber decimalNumberWithString:@"100"] password:[NSString desWithKey:@"123456" key:nil]] subscribeNext:^(CurrentRedeemNotice *notice) {
                [expectation fulfill];
                XCTAssertNotNil(notice, "Current redeem notice is nil.");
                XCTAssert(notice.redeemApplyDate > 0, "Current redeem apply date is 0.");
                XCTAssert(notice.earningsToBeReceiveDate > 0, "Current redeem amount to be receive date is 0.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Redeem current failed.");
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
#endif
}

#pragma mark - friend invite
- (void)testQueryMyInviteInfo {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my invite info."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryMyInvitedFriendListWithLastFriendID:@(0) size:0] subscribeNext:^(InviteInfo *inviteInfo) {
                [expectation fulfill];
                XCTAssertNotNil(inviteInfo, "Invite info is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my invite info failed.");
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
}

- (void)testQueryMyInvitedFriendList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"query my invited friend list."];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryMyInvitedFriendListWithLastFriendID:@(0) size:12] subscribeNext:^(NSArray *friendList) {
                [expectation fulfill];
                XCTAssertNotNil(friendList, "Invited friend list is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my invited friend list failed.");
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"%@", error);
    }];
}

#pragma mark - operating service
- (void)testQuerySystemConfig {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQuerySystemConfig"];
    [[_protocol querySystemConfig] subscribeNext:^(SystemConfigs *configs) {
        [expectation fulfill];
        XCTAssertGreaterThanOrEqual(configs.transferFee, 0, @"转让手续费 小于 0");
        XCTAssertGreaterThanOrEqual(configs.maxFee, 0, @"手续费最大值 小于 0");
        XCTAssertGreaterThanOrEqual(configs.minFee, 0, @"手续费最小值 小于 0");
        XCTAssertGreaterThanOrEqual(configs.maxDiscountRate, 0, @"折让率最大值 小于 0");
        XCTAssertGreaterThanOrEqual(configs.minDiscountRate, 0, @"折让率最小值 小于 0");
        XCTAssertGreaterThanOrEqual(configs.minDaysAfterBought, 0, @"购买生效后不低于天数 小于 0");
        XCTAssertGreaterThanOrEqual(configs.minDaysBeforeEndRepay, 0, @"距离还款结束不低于 小于 0");
        XCTAssertGreaterThanOrEqual(configs.beginInvestAmount, 0, @"个人标起投金额 小于 0");
        XCTAssertGreaterThanOrEqual(configs.increaseInvestAmount, 0, @"个人标递增金额 小于 0");
        XCTAssertNotNil(configs.rechargeProtocolUrl, @"充值协议链接 为空");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取SystemConfigs失败 :%@",error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query system config timeout, %@", error);
    }];
}

- (void)testQueryInviteCode {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryInviteCode"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            /*
             SHARE_INVITE = 1, //邀请
             SHARE_INVEST = 2, //分享标的
             */
            [[_protocol queryInviteCode:SHARE_INVITE] subscribeNext:^(InviteCode *inviteCode) {
                [expectation fulfill];
                XCTAssertNotNil(inviteCode.codeLink, @"邀请码链接为空");
                XCTAssertNotNil(inviteCode.desc, @"描述信息 为空");
                XCTAssertNotNil(inviteCode.title, @"分享标题为空");
                XCTAssertNotNil(inviteCode.shareUrl, @"分享图标 为空");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"获取inviteCode失败 :%@",error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query invite code timeout: %@", error);
    }];
}

- (void)testQueryBannerList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryBannerList"];
    [[_protocol queryBannerList] subscribeNext:^(NSArray *bannerList) {
        [expectation fulfill];
        XCTAssertNotNil(bannerList, @"bannerList 为空");
        for (BannerInfo *info in bannerList) {
            XCTAssertNotNil(info.bannerUrl, @"bannerUrl 为空");
        }
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取bannerList失败 :%@",error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query banner list timeout: %@", error);
    }];
}

- (void)testQueryProductList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryProductList"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol queryProductList:1 size:12 requestType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dic) {
                [expectation fulfill];

                NSMutableArray *list = dic[LIST];
                XCTAssertNotNil(dic, @"获取列表失败");
                XCTAssertNotNil(list, @"获取列表失败");
                XCTAssertGreaterThanOrEqual(list.count, 0, @"获取列表失败");

            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"获取列表失败 :%@",error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query product list timeout: %@", error);
    }];
}

- (void)testExchangeGoods {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testExchangeByGoodsId"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"login failed.");

        if (success) {
            [[_protocol exchange:1] subscribeNext:^(RACError *reqResult) {
                [expectation fulfill];
                XCTAssertEqual(reqResult.result, 0, @"兑换失败");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"兑换失败 :%@",error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"exchange goods timeout: %@", error);
    }];
}

- (void)testQueryNewNotice {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query new notice"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login for query new notice failed.");
        if (success) {
            [[_protocol queryNewNoticeList] subscribeNext:^(NSNumber *noticeId) {
                [expectation fulfill];
                XCTAssertNotNil(noticeId, @"Notice id is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query new notice failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query new notice timeout: %@", error);
    }];
}

- (void)testQueryUnreadMessageCount {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query unread message count"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login for query unread message count failed.");
        if (success) {
            [[_protocol queryUnreadMessageCount] subscribeNext:^(NSNumber *unreadMsgCount) {
                [expectation fulfill];
                XCTAssertNotNil(unreadMsgCount, @"Unread message count is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query unread message count failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query unread message count timeout: %@", error);
    }];
}

- (void)testQueryMessageList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query message list"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query message list.");
        if (success) {
            [[_protocol queryMessageList:0 size:10 requestType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                NSArray *list = dict[LIST];
                XCTAssertNotNil(list, @"Message list is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query message list failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query message list timeout: %@", error);
    }];
}

- (void)testReadMessage {
    NSNumber *messageId = @(50924);

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Read message"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for read message.");
        if (success) {
            [[_protocol sendReadMessageId:messageId.intValue] subscribeError:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Read message failed: %@", error);
            } completed:^{
                [expectation fulfill];
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Read message timeout: %@", error);
    }];
}

- (void)testDeleteMessage {
    NSNumber *messageId = @(50924);

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delete message"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for delete message.");
        if (success) {
            [[_protocol sendDeleteMessage:messageId.intValue] subscribeError:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Delete message failed: %@", error);
            } completed:^{
                [expectation fulfill];
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Delete message timeout: %@", error);
    }];
}

- (void)testCheckUpdate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check update"];

    [[_protocol checkUpdate] subscribeNext:^(UpdateInfo *info) {
        [expectation fulfill];
        XCTAssertNotNil(info, @"Update info is nil.");
        XCTAssert(info.flag > 0 && info.flag <= 3, @"Invalid flag: %d", info.flag);
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Check update failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Check update timeout: %@", error);
    }];
}

- (void)testQueryCompanyNotice {
    XCTestExpectation *queryAboutExpectation = [self expectationWithDescription:@"Query about"];
    XCTestExpectation *queryHelpsExpectation = [self expectationWithDescription:@"Query help list"];
    XCTestExpectation *queryNoticesExpectation = [self expectationWithDescription:@"Query company notices"];

    [[_protocol queryCompanyNotice:1 size:10 type:TYPE_ABOUT keywords:nil requestType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
        [queryAboutExpectation fulfill];
        XCTAssertNotNil(dict, @"About dict is nil.");
        NSArray *list = dict[LIST];
        XCTAssertNotNil(list, @"About list is nil.");
        XCTAssert(list.count == 1, @"About list count is not correct: %d", list.count);
    } error:^(NSError *error) {
        [queryAboutExpectation fulfill];
        XCTFail(@"Query about failed: %@", error);
    }];

    [[_protocol queryCompanyNotice:1 size:10 type:TYPE_HELP keywords:nil requestType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
        [queryHelpsExpectation fulfill];
        XCTAssertNotNil(dict, @"Help dict is nil.");
        NSArray *list = dict[LIST];
        XCTAssertNotNil(list, @"Help list is nil.");
    } error:^(NSError *error) {
        [queryHelpsExpectation fulfill];
        XCTFail(@"Query help failed: %@", error);
    }];

    [[_protocol queryCompanyNotice:1 size:10 type:TYPE_NOTICE keywords:nil requestType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
        [queryNoticesExpectation fulfill];
        XCTAssertNotNil(dict, @"Notice dict is nil.");
        NSArray *list = dict[LIST];
        XCTAssertNotNil(list, @"Notice list is nil.");
    } error:^(NSError *error) {
        [queryNoticesExpectation fulfill];
        XCTFail(@"Query company notices failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:15 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query company notice timeout: %@", error);
    }];
}

- (void)testRiskAssessment {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *queryRiskAssessmentExpectation = [self expectationWithDescription:@"Query risk assessment"];
    XCTestExpectation *commitRiskAssessmentExpectation = [self expectationWithDescription:@"Commit risk assessment"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for risk assessment.");
        if (success) {
            [[_protocol queryRiskAssessment] subscribeNext:^(NSArray *riskList) {
                [queryRiskAssessmentExpectation fulfill];
                XCTAssertNotNil(riskList, @"Risk list is nil.");
                XCTAssert(riskList.count > 0, @"Risk list is empty.");
                NSMutableArray *answers = [[NSMutableArray alloc] initWithCapacity:riskList.count];
                for (RiskInfo *riskInfo in riskList) {
                    XCTAssert(riskInfo.riskDetailInfoArr && riskInfo.riskDetailInfoArr.count > 0, @"Risk info (questionid = %@)'s options is empty", riskInfo.questionId);
                    RiskDetailInfo *optionInfo = [riskInfo.riskDetailInfoArr objectAtIndex:0];
                    NSDictionary *answer = @{@"answerId" : optionInfo.answerId, @"questionId" : riskInfo.questionId};
                    [answers addObject:answer];
                }
                [[_protocol commitRiskAssessment:answers] subscribeNext:^(RiskResultInfo *riskType) {
                    [commitRiskAssessmentExpectation fulfill];
                    XCTAssertNotNil(riskType, @"Risk type is nil.");
                    XCTAssert(riskType.type == EVALUATE_OLD, @"Risk assessment result is not correct.");
                } error:^(NSError *error) {
                    [commitRiskAssessmentExpectation fulfill];
                    XCTFail(@"Commit risk assessment failed: %@", error);
                }];
            } error:^(NSError *error) {
                [queryRiskAssessmentExpectation fulfill];
                [commitRiskAssessmentExpectation fulfill];
                XCTFail(@"Query risk assessment failed: %@", error);
            }];
        } else {
            [queryRiskAssessmentExpectation fulfill];
            [commitRiskAssessmentExpectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:15 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Risk assessment timeout: %@", error);
    }];
}

- (void)testQueryRiskTypeInfo {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query risk type info"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query risk type info.");
        if (success) {
            [[_protocol getRiskConfigueWithRiskType:EVALUATE_STEADY] subscribeNext:^(RiskResultInfo *riskType) {
                [expectation fulfill];
                XCTAssertNotNil(riskType, @"Risk type is nil.");
                XCTAssertNotNil(riskType.title, @"Risk type title is nil.");
                XCTAssertNotNil(riskType.icon, @"Risk type icon url is nil.");
                XCTAssertNotNil(riskType.desc, @"Risk type description is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query risk type info failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:15 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query risk type info timeout: %@", error);
    }];
}

#pragma mark - user service
- (void)testQueryMyInvestList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query my invest list"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query my invest list.");

        if (success) {
            [[_protocol queryMyInvestListWithPageIndex:1 pageSize:10 status:STATUS_BACKING type:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                NSArray *list = dict[LIST];
                XCTAssertNotNil(list, @"My invest list is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my invest list failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query my invest list timeout: %@", error);
    }];
}

- (void)testQueryMyDebtList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query my debt list"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query my debt list.");

        if (success) {
            [[_protocol queryMyDebtListWithPageIndex:1 pageSize:10 statuses:STATUS_CAN_BE_TRANSFER type:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                NSArray *list = dict[LIST];
                XCTAssertNotNil(list, @"My debt list is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my debt list failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query my debt list timeout: %@", error);
    }];
}

- (void)testQueryMyFundsFlow {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query my funds flow"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query my funds flow.");

        if (success) {
            [[_protocol queryMyFundsFlowWithPageIndex:1 pageSize:10 recordType:TYPE_ALL timeType:SEVEN_DAYS requestType:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                NSArray *list = dict[LIST];
                XCTAssertNotNil(list, @"My funds flow is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my funds flow failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query my funds flow timeout: %@", error);
    }];
}

- (void)testQueryMyRedEnvelopeList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query my red envelope list"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query my red envelope list.");

        if (success) {
            [[_protocol queryMyRedEnvelopeListWithPageIndex:1 pageSize:10 status:(STATUS_USED & STATUS_EXPIRED) type:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                NSArray *list = dict[LIST];
                XCTAssertNotNil(list, @"My red envelope list is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my red envelope list failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query my red envelope list timeout: %@", error);
    }];
}

- (void)testQueryMyPoints {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query my points"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query my points.");

        if (success) {
            [[_protocol queryMyPoints] subscribeNext:^(UserPoint *userPoint) {
                [expectation fulfill];
                XCTAssertNotNil(userPoint, @"User point is nil.");
                XCTAssertEqual(userPoint.totalPoints, userPoint.usedPoints + userPoint.freezePoints + userPoint.expendPoints, @"User points are not correct.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my points failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query my points timeout: %@", error);
    }];
}

- (void)testQueryMyPointDetailList {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query my point detail list"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query my point detail list.");

        if (success) {
            [[_protocol queryMyPointListWithPageIndex:1 pageSize:10 type:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                NSArray *list = dict[LIST];
                XCTAssertNotNil(list, @"Point detail list is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query my point list failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query my point detail list timeout: %@", error);
    }];
}

#pragma mark - FinanceService

- (void)testQueryRecommendedList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query recommended list"];
    [[_protocol queryRecommendedList] subscribeNext:^(NSArray *list) {
        [expectation fulfill];
        XCTAssertNotNil(list, @"Recommended list is nil.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Query recommended list failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query recommended list timeout: %@", error);
    }];
}

- (void)testQueryLoanList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query loan list"];
    [[_protocol queryInvestList:1 size:10 type:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
        [expectation fulfill];
        NSArray *list = dict[LIST];
        XCTAssertNotNil(list, @"Loan list is nil.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Query loan list failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query loan list timeout: %@", error);
    }];
}

- (void)testQueryLoanDetail {
    NSNumber *loanId = @(528299);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Query loan detail"];
    [[_protocol queryLoanDetail:loanId.intValue] subscribeNext:^(LoanDetail *detail) {
        [expectation fulfill];
        XCTAssertNotNil(detail, @"Loan detail is nil.");
        XCTAssertNotNil(detail.baseInfo, @"Loan detail baseInfo is nil.");
        XCTAssert(detail.baseInfo.loanId == 528299, @"Invalid loan id: %d", detail.baseInfo.loanId);
        XCTAssertNotNil(detail.contractName, @"Loan detail contract name is nil.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Query loan detail failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query loan detail timeout: %@", error);
    }];
}

- (void)testQueryProjectInstruction {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *riskWarningExpectation = [self expectationWithDescription:@"Query risk warning instruction"];
    XCTestExpectation *disclaimerExpectation = [self expectationWithDescription:@"Query disclaimer instruction"];
    XCTestExpectation *tradingManualExpectation = [self expectationWithDescription:@"Query trading manual instruction"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login for query project instruction failed.");

        if (success) {
            [self doQueryProjectInstructionWithExpectation:riskWarningExpectation type:INSTRUCTION_TYPE_RISK_WARNING];
            [self doQueryProjectInstructionWithExpectation:disclaimerExpectation type:INSTRUCTION_TYPE_DISCLAIMER];
            [self doQueryProjectInstructionWithExpectation:tradingManualExpectation type:INSTRUCTION_TYPE_TRADING_MANUAL];
        } else {
            [riskWarningExpectation fulfill];
            [disclaimerExpectation fulfill];
            [tradingManualExpectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query proejct instruction timeout: %@", error);
    }];
}

- (void)testQueryContractTemplate {
    NSNumber *loanId = @(528299);

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query contract template"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query contract template.");

        if (success) {
            [[_protocol queryContractTemplate:loanId.intValue] subscribeNext:^(NSDictionary *dict) {
                [expectation fulfill];
                NSString *content = dict[CONTENT];
                XCTAssertNotNil(content, @"Loan %@ content is nil.", loanId);
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query contract template failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query contract template timeout: %@", error);
    }];
}

- (void)testQueryInvestorList {
    NSNumber *loanId = @(528299);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query investor list"];
    [[_protocol queryInvestRecordList:1 size:10 loanId:loanId.intValue] subscribeNext:^(NSDictionary *dict) {
        [expectation fulfill];
        NSArray *list = dict[LIST];
        XCTAssertNotNil(list, @"Investor list is nil.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Query investor list failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query investor list timeout: %@", error);
    }];
}

- (void)testQueryAvaiableRedEnvelopeListForLoan {
    NSNumber *loanId = @(528299);
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query investor list"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            NSUInteger flag = TYPE_VOUCHERS & TYPE_PLUS_COUPONS & TYPE_EXPERIENS_GOLD;
            [[_protocol queryRedEnvelopeListForLoanId:loanId investAmount:[NSDecimalNumber decimalNumberWithString:@"5000"] flag:flag] subscribeNext:^(NSArray *redEnvelopeList) {
                [expectation fulfill];
                XCTAssertNotNil(redEnvelopeList, @"Red envelope list is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query avaiable red envelope list for loan failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query avaiable red envelope list for loan timeout: %@", error);
    }];
}

- (void)testQueryDebtList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query debt list"];

    [[_protocol queryDebtList:1 size:10 type:LIST_REQUEST_NEW] subscribeNext:^(NSDictionary *dict) {
        [expectation fulfill];
        NSArray *list = dict[LIST];
        XCTAssertNotNil(list, @"Debt list is nil.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Query debt list failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query debt list timeout: %@", error);
    }];
}

- (void)testQueryDebtDetail {
    NSNumber *debtId = @(2428);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Query debt detail"];
    [[_protocol queryDebtDetail:debtId.intValue] subscribeNext:^(DebtDetail *detail) {
        [expectation fulfill];
        XCTAssertNotNil(detail, @"Debt detail is nil.");
        XCTAssertNotNil(detail.baseInfo, @"Debt detail's base info is nil.");
        XCTAssert(detail.baseInfo.debtId == 2428, @"Debt id is not correct.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Query debt detail failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query debt detail timeout: %@", error);
    }];
}

- (void)testSellDebt {
    NSNumber *debtId = @(2428);
    NSNumber *amount = @(10000);

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Sell debt"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login for sell debt failed.");
        if (success) {
            [[_protocol sellDebt:debtId.intValue discount:amount.doubleValue] subscribeError:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Sell debt failed: %@", error);
            } completed:^{
                [expectation fulfill];
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Sell debt timeout: %@", error);
    }];
}

- (void)testUndoDebtSold {
    NSNumber *debtId = @(2428);

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Undo debt sold"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login for undo debt sold failed.");
        if (success) {
            [[_protocol undoDebtSell:debtId.intValue] subscribeError:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Undo debt sold failed: %@", error);
            } completed:^{
                [expectation fulfill];
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Undo debt sold timeout: %@", error);
    }];
}

- (void)testQueryDebtAgreement {
    NSNumber *debtId = @(2428);

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query debt agreement"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for query debt agreement.");
        if (success) {
            [[_protocol queryDebtAgreementInfo:debtId.integerValue] subscribeNext:^(DebtAgreementInfo *agreementInfo) {
                [expectation fulfill];
                XCTAssertNotNil(agreementInfo, @"Debt agreement info is nil.");
                XCTAssertNotNil(agreementInfo.contractTitle, @"Debt agreement info's contract title is nil.");
                XCTAssertNotNil(agreementInfo.url, @"Debt agreement info's url is nil.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query debt agreement failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query debt agreement timeout: %@", error);
    }];
}

#pragma mark - PayService
- (void)testQuerySupportBankList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query support bank list"];
    [[_protocol querySupportBankList:@""] subscribeNext:^(NSArray *bankIdList) {
        [expectation fulfill];
        XCTAssertNotNil(bankIdList, @"Bank id list is nil.");
        XCTAssert(bankIdList.count > 0, @"Bank id list is empty.");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"Query support bank list failed: %@", error);
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query support bank list timeout: %@", error);
    }];
}

- (void)testBindCard {
    NSString *name = @"郝熙华";
    NSString *idcardNumber = @"44090119830816433X";
    NSString *bankId = @"ABC";
    NSString *bankCardNumber = @"6228480402564890018";
    NSString *phoneNumber = @"13510001000";

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *queryVCodeExpectation = [self expectationWithDescription:@"Query verify code"];
    XCTestExpectation *bindCarndExpectation = [self expectationWithDescription:@"Bind card"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login for bind card failed.");
        if (success) {
            [self doQueryVerifyCodeWithPhoneNumber:phoneNumber aim:AIM_BIND_BANK_CARD block:^(RACError *error) {
                [queryVCodeExpectation fulfill];
                XCTAssertNil(error, @"Query verify code failed: %@", error);
                if (error) {
                    [bindCarndExpectation fulfill];
                } else {
                    [[_protocol bindCardRealName:name idCard:idcardNumber bankId:bankId bankCard:bankCardNumber phone:phoneNumber verifyCode:@"111111"] subscribeError:^(NSError *error) {
                        [bindCarndExpectation fulfill];
                        XCTFail(@"Bind card failed: %@", error);
                    } completed:^{
                        [bindCarndExpectation fulfill];
                    }];
                }
            }];
        } else {
            [queryVCodeExpectation fulfill];
            [bindCarndExpectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Bind card timeout: %@", error);
    }];
}

- (void)testSetPayPassword {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Set pay password"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for set pay password.");
        if (success) {
            [[_protocol userSetTradePassword:[NSString desWithKey:@"123456" key:nil]] subscribeError:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Set pay password failed: %@", error);
            } completed:^{
                [expectation fulfill];
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Set pay password timeout: %@", error);
    }];
}

- (void)testResetPayPassword {
    NSString *name = @"郝熙华";
    NSString *idcardNumber = @"44090119830816433X";
    NSString *bankCardNumber = @"6228480402564890018";
    NSString *phoneNumber = @"13510001000";

    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *queryVCodeExpectation = [self expectationWithDescription:@"Query verify code"];
    XCTestExpectation *verifyPhoneExpectation = [self expectationWithDescription:@"Verify phone number"];
    XCTestExpectation *verifyBindInfoExpectation = [self expectationWithDescription:@"Verify bind info"];
    XCTestExpectation *resetPayPasswordExpectation = [self expectationWithDescription:@"Reset pay password"];

    [self doLoginWithBlock:^(BOOL success) {
        XCTAssertTrue(success, @"Login failed for reset pay password.");
        [loginExpectation fulfill];
        if (success) {
            [self doQueryVerifyCodeWithPhoneNumber:phoneNumber aim:AIM_RESET_TRADE_PASSWORD block:^(RACError *error) {
                [queryVCodeExpectation fulfill];
                XCTAssertNil(error, @"Query phone verify code failed: %@", error);
                if (error) {
                    [verifyPhoneExpectation fulfill];
                    [verifyBindInfoExpectation fulfill];
                    [resetPayPasswordExpectation fulfill];
                } else {
                    [[_protocol resetTradePasswordPhone:phoneNumber verifyCode:@"111111"] subscribeNext:^(NSString *token) {
                        [verifyPhoneExpectation fulfill];
                        [[_protocol resetTradePasswordRealName:name idCard:idcardNumber bankCard:bankCardNumber token:token] subscribeNext:^(RACError *response) {
                            [verifyBindInfoExpectation fulfill];
                            XCTAssertNotNil(response, @"Verify bind info response is nil.");
                            if (response.result == ERR_NONE) {
                                [[_protocol userResetTradePassword:[NSString desWithKey:@"123456" key:nil] token:token] subscribeNext:^(RACError *response) {
                                    [resetPayPasswordExpectation fulfill];
                                    XCTAssertNotNil(response, @"Reset pay password response is nil.");
                                    XCTAssertEqual(response.result, ERR_NONE, @"Reset pay password failed: %@", response);
                                }];
                            } else {
                                XCTFail(@"Verify bind info failed: %@", response);
                                [resetPayPasswordExpectation fulfill];
                            }
                        }];
                    } error:^(NSError *error) {
                        [verifyPhoneExpectation fulfill];
                        [verifyBindInfoExpectation fulfill];
                        [resetPayPasswordExpectation fulfill];
                        XCTFail(@"Verify pay bind phonenumber failed: %@", error);
                    }];
                }
            }];
        } else {
            [queryVCodeExpectation fulfill];
            [verifyPhoneExpectation fulfill];
            [verifyBindInfoExpectation fulfill];
            [resetPayPasswordExpectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:15 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, "Reset pay password timeout: %@", error);
    }];
}

- (void)testRecharge {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"Login"];
    XCTestExpectation *verifyPayPasswordExpectation = [self expectationWithDescription:@"Verify pay password"];
    XCTestExpectation *queryVCodeExpectation = [self expectationWithDescription:@"Query recharge verify code"];
    XCTestExpectation *rechargeExpectation = [self expectationWithDescription:@"Recharge"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for recharge.");
        if (success) {
            [[_protocol queryChargeOneStepMoney:@"1000" password:[NSString desWithKey:@"123456" key:nil]] subscribeNext:^(NSDictionary *dict) {
                [verifyPayPasswordExpectation fulfill];
                XCTAssertNotNil(dict, @"Verify pay password response is nil.");
                NSString *rechargeNO = dict[@"rechargeNo"];
                if ([MSTextUtils isEmpty:rechargeNO]) {
                    XCTFail(@"Recharge number is empty");
                    [queryVCodeExpectation fulfill];
                    [rechargeExpectation fulfill];
                } else {
                    [[_protocol queryChargeTwoStepWithRechargeNo:rechargeNO] subscribeError:^(NSError *error) {
                        [queryVCodeExpectation fulfill];
                        [rechargeExpectation fulfill];
                        XCTFail(@"Query recharge verify code failed: %@", error);
                    } completed:^{
                        [queryVCodeExpectation fulfill];
                        [[_protocol queryChargeThreeStepRechargeNo:rechargeNO vCode:@"1234"] subscribeError:^(NSError *error) {
                            [rechargeExpectation fulfill];
                            XCTFail(@"Rechage failed: %@", error);
                        } completed:^{
                            [rechargeExpectation fulfill];
                        }];
                    }];
                }
            } error:^(NSError *error) {
                [verifyPayPasswordExpectation fulfill];
                [queryVCodeExpectation fulfill];
                [rechargeExpectation fulfill];
                XCTFail(@"Verify pay password failed: %@", error);
            }];
        } else {
            [verifyPayPasswordExpectation fulfill];
            [queryVCodeExpectation fulfill];
            [rechargeExpectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:15 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Recharge timeout: %@", error);
    }];
}

- (void)testWithdraw {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *withdrawExpectation = [self expectationWithDescription:@"withdraw"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login for withdraw failed.");
        if (success) {
            [[_protocol queryDrawcash:@"100" password:[NSString desWithKey:@"123456" key:nil]] subscribeNext:^(NSString *message) {
                [withdrawExpectation fulfill];
                XCTAssertFalse([MSTextUtils isEmpty:message], @"Withdraw success message is empty.");
            } error:^(NSError *error) {
                [withdrawExpectation fulfill];
                XCTFail(@"Withdraw failed: %@", error);
            }];
        } else {
            [withdrawExpectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Withdraw timeout: %@", error);
    }];
}

- (void)testInvest {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Invest"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for invest.");
        if (success) {
            [[_protocol queryNewInvestLoadId:@"528299" redBagId:@"" password:[NSString desWithKey:@"123456" key:nil] money:@"1000"] subscribeNext:^(NSString *message) {
                [expectation fulfill];
                XCTAssertFalse([MSTextUtils isEmpty:message], @"Invest success message is empty.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Invest failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Invest timeout: %@", error);
    }];
}

- (void)testBuyDebt {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Buy debt"];

    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        XCTAssertTrue(success, @"Login failed for invest.");
        if (success) {
            [[_protocol queryBuyDebt:@"2428" password:[NSString desWithKey:@"123456" key:nil]] subscribeNext:^(NSString *message) {
                [expectation fulfill];
                XCTAssertFalse([MSTextUtils isEmpty:message], @"Buy debt success message is empty.");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Buy debt failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Buy debt timeout: %@", error);
    }];
}

- (void)testQueryRechargeConfig {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query recharge config"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            [[_protocol queryRechargeConfig] subscribeNext:^(id x) {
                [expectation fulfill];
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query recharge config failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query recharge config timeout: %@", error);
    }];
}

- (void)testQueryWithdrawConfig {
    XCTestExpectation *loginExpectation = [self expectationWithDescription:@"login"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query withdraw config"];
    [self doLoginWithBlock:^(BOOL success) {
        [loginExpectation fulfill];
        if (success) {
            [[_protocol queryWithdrawConfig] subscribeNext:^(id x) {
                [expectation fulfill];
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"Query withdraw config failed: %@", error);
            }];
        } else {
            [expectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"Query withdraw config timeout: %@", error);
    }];
}

#pragma mark - internal methods
//- (void)logout;
//- (NSString *)setSessionForURL:(NSString *)url;
//- (NSString *)getInvestAgreementById:(NSNumber *)debtId;
//- (RACSignal *)reloginForRequest:(NSString *)url;

#pragma mark - private

- (void)doLoginWithBlock:(loginCallback)callback {
    // ZK: ceshi123 Xiji1S3g5ak=
    // TEST: 13510001000 VIboRoB6M5c=
    [[_protocol loginWithUserName:@"ceshi123" password:@"Xiji1S3g5ak="] subscribeNext:^(MSLoginInfo *loginInfo) {
        callback(YES);
    } error:^(NSError *error) {
        callback(NO);
    }];
}

- (void)doQueryProjectInstructionWithExpectation:(XCTestExpectation *)expectation type:(ProjectInstructionType)type {
    NSNumber *loanId = @(528299);

    [[_protocol queryProjectInstruction:loanId.intValue type:type] subscribeNext:^(NSDictionary *dict) {
        [expectation fulfill];
        NSString *content = dict[CONTENT];
        NSArray *fileList = dict[LIST];
        XCTAssert(content || (fileList && fileList.count > 0), @"Both content and file list are empty in project instruction of type %d .", type);
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail("Query project instruction type: %d failed: %@", type, error);
    }];
}

- (void)doQueryVerifyCodeWithPhoneNumber:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim block:(queryVerifyCodeCallback)callback {
    [[_protocol queryVerifyCodeByPhoneNumber:phoneNumber aim:aim] subscribeError:^(NSError *error) {
        callback((RACError *)error);
    } completed:^{
        callback(nil);
    }];
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        XCTAssertTrue(YES, "");
//    }];
//}

@end
