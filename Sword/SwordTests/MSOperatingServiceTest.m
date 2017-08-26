//
//  MSOperatingServiceTest.m
//  Sword
//
//  Created by msj on 2017/4/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ReactiveCocoa/RACSignal.h"
#import "ReactiveCocoa/RACSubscriber.h"
#import "MSOperatingService.h"
#import "MSConsts.h"
#import "MSConfig.h"
#import "ZKProtocol.h"
#import "InviteCode.h"
#import "RACError.h"
#import "RiskInfo.h"
#import "SystemConfigs.h"
#import "BannerInfo.h"
#import "GoodsInfo.h"
#import "NoticeInfo.h"
#import "MessageInfo.h"

typedef void(^loginCallback)(BOOL success);

@interface MSOperatingServiceTest : XCTestCase
{
    MSOperatingService *_operatingServiceMock;
    id _protocolMock;
}
@end

@implementation MSOperatingServiceTest

#pragma mark - test
- (void)setUp {
    [super setUp];
    _protocolMock = OCMClassMock([ZKProtocol class]);
    _operatingServiceMock = [[MSOperatingService alloc] initWithProtocol:_protocolMock];
}

- (void)tearDown {
    _operatingServiceMock = nil;
    _protocolMock = nil;
    [super tearDown];
}

- (void)testQuerySystemConfig {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQuerySystemConfig"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
//        RACError *result = [RACError createDefaultResult];
//        result.result = -1;
//        [subscriber sendError:result];
//        
        //success test
        SystemConfigs *configs = [[SystemConfigs alloc] init];
        configs.transferFee = 100;
        configs.maxFee = 100;
        configs.minFee = 100;
        configs.maxDiscountRate = 100;
        configs.minDiscountRate = 100;
        configs.minDaysAfterBought = 100;
        configs.minDaysBeforeEndRepay = 100;
        configs.beginInvestAmount = 100;
        configs.increaseInvestAmount = 100;
        configs.rechargeProtocolUrl = @"baidu.com";
        [subscriber sendNext:configs];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock querySystemConfig]).andReturn(signal);
    [[_operatingServiceMock querySystemConfig] subscribeNext:^(SystemConfigs *configs) {
        [expectation fulfill];
        XCTAssertNotNil(configs, @"获取configs失败");
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
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryInviteCode {
    /*
     SHARE_INVITE = 1, //邀请  (要登录)
     SHARE_INVEST = 2, //分享标的   (不需要登录)
     */
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryInviteCode"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
//        RACError *result = [RACError createDefaultResult];
//        result.result = -1;
//        [subscriber sendError:result];
        
        //success test
        InviteCode *inviteCode = [[InviteCode alloc] init];
        inviteCode.codeLink = @"baidu.com";
        inviteCode.desc = @"baidu.com";
        inviteCode.title = @"baidu.com";
        inviteCode.shareUrl = @"baidu.com";
        [subscriber sendNext:inviteCode];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryInviteCode:SHARE_INVITE]).andReturn(signal);
    [[_operatingServiceMock queryInviteCode:SHARE_INVITE] subscribeNext:^(InviteCode *inviteCode) {
        [expectation fulfill];
        XCTAssertNotNil(inviteCode, @"inviteCode 没有值");
        XCTAssertNotNil(inviteCode.codeLink, @"邀请码链接为空");
        XCTAssertNotNil(inviteCode.desc, @"描述信息 为空");
        XCTAssertNotNil(inviteCode.title, @"分享标题为空");
        XCTAssertNotNil(inviteCode.shareUrl, @"分享图标 为空");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取inviteCode失败 :%@",error);
    } completed:^{
        
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryVerifyCode {
    /*
     AIM_REGISTER = 1,         // 注册
     AIM_RESET_LOGIN_PASSWORD, // 重置登录密码
     AIM_BIND_BANK_CARD,       // 绑定银行卡
     AIM_RESET_TRADE_PASSWORD = 5, // 充值交易密码
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryVerifyCode"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryVerifyCodeByPhoneNumber:OCMOCK_ANY aim:AIM_RESET_LOGIN_PASSWORD]).andReturn(signal);
    [[_operatingServiceMock queryVerifyCodeByPhoneNumber:@"13552198435" aim:AIM_RESET_LOGIN_PASSWORD] subscribeError:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取短信验证码失败 :%@",error);
    } completed:^{
        [expectation fulfill];
        XCTAssert(@"获取短信验证码成功");
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryBannerList {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQuerySystemConfig"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        NSMutableArray *arr = [NSMutableArray array];
        BannerInfo *bannerInfo = [[BannerInfo alloc] init];
        bannerInfo.bannerUrl = @"baidu.com";
        bannerInfo.link = @"baidu.com";
        [arr addObject:bannerInfo];
        [subscriber sendNext:arr];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryBannerList]).andReturn(signal);
    [[_operatingServiceMock queryBannerList] subscribeNext:^(NSArray *arr) {
        [expectation fulfill];
        XCTAssertNotNil(arr, @"没有banner");
        XCTAssertGreaterThan(arr.count, 0, @"没有banner");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取SystemConfigs失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryGoodsList {
    /*
     LIST_REQUEST_NEW,  //重新请求
     LIST_REQUEST_MORE, //请求更多
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryGoodsList"];
    
    __block NSInteger pageIndex = 1;
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        NSMutableArray *list = [NSMutableArray array];
        for (int i = 0; i < 12; i++) {
            GoodsInfo *info = [[GoodsInfo alloc] init];
            [list addObject:info];
        }
        
        ListRequestType type = (pageIndex == 1) ? LIST_REQUEST_NEW : LIST_REQUEST_MORE;
        
        NSDictionary *dic = @{TOTALCOUNT : @(25), LIST : list, TYPE : @(type)};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryProductList:pageIndex size:MS_PAGE_SIZE requestType:LIST_REQUEST_NEW]).andReturn(signal);
    [[_operatingServiceMock queryGoodsListByType:LIST_REQUEST_NEW] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssertEqual(_operatingServiceMock.operatingCache.pointShopList.count, 12, @"服务器返回数据不正确");
        XCTAssertEqual(_operatingServiceMock.operatingCache.totalPointGoods, 25, @"服务器返回数据不正确");
        XCTAssertTrue([_operatingServiceMock.operatingCache hasMorePointGoods], @"operatingService 逻辑错误");
        
        if ([_operatingServiceMock.operatingCache hasMorePointGoods]) {
            pageIndex = 2;
            OCMStub([_protocolMock queryProductList:pageIndex size:MS_PAGE_SIZE requestType:LIST_REQUEST_MORE]).andReturn(signal);
            [[_operatingServiceMock queryGoodsListByType:LIST_REQUEST_MORE] subscribeNext:^(id x) {
                XCTAssertEqual(_operatingServiceMock.operatingCache.pointShopList.count, 24, @"服务器返回数据不正确");
                XCTAssertEqual(_operatingServiceMock.operatingCache.totalPointGoods, 25, @"服务器返回数据不正确");
                XCTAssertTrue([_operatingServiceMock.operatingCache hasMorePointGoods], @"operatingService 逻辑错误");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"获取GoodsList失败 :%@",error);
            }];
        }
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取GoodsList失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryAbout {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryAbout"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        NoticeInfo *info = [[NoticeInfo alloc] init];
        info.content = @"彩票中大奖";
        info.noticeId = 20000;
        info.title = @"头条";
        info.datetime = @"2017.5.5";
        
        NSDictionary *dic = @{LIST : @[info]};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryCompanyNotice:1 size:1 type:TYPE_ABOUT keywords:nil requestType:LIST_REQUEST_NEW]).andReturn(signal);
    [[_operatingServiceMock queryAbout] subscribeNext:^(NoticeInfo *info) {
        [expectation fulfill];
        XCTAssertNotNil(info, @"NoticeInfo 为空");
        XCTAssertGreaterThan(info.content.length, 0, @"contnet 为空");
        XCTAssertGreaterThan(info.title.length, 0, @"title 为空");
        XCTAssertGreaterThan(info.datetime.length, 0, @"datetime 为空");
        XCTAssertGreaterThan(info.noticeId, 0, @"noticeId 数据错误");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取testQueryAbout失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryHelpList {
    /*
     LIST_REQUEST_NEW,  //重新请求
     LIST_REQUEST_MORE, //请求更多
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryHelpList"];
    
    __block NSInteger pageIndex = 1;
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        NSMutableArray *list = [NSMutableArray array];
        for (int i = 0; i < 9; i++) {
            NoticeInfo *info = [[NoticeInfo alloc] init];
            [list addObject:info];
        }
        ListRequestType type = (pageIndex == 1) ? LIST_REQUEST_NEW : LIST_REQUEST_MORE;
        NSDictionary *dic = @{TOTALCOUNT : @(9), LIST : list, TYPE : @(type)};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryCompanyNotice:1 size:MS_PAGE_SIZE type:TYPE_HELP keywords:nil requestType:LIST_REQUEST_NEW]).andReturn(signal);
    [[_operatingServiceMock queryHelpListByType:LIST_REQUEST_NEW] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssertEqual(_operatingServiceMock.operatingCache.helpList.count, 9, @"服务器返回数据不正确");
        XCTAssertEqual(_operatingServiceMock.operatingCache.totalHelpCount, 9, @"服务器返回数据不正确");
        XCTAssertFalse([_operatingServiceMock.operatingCache hasMoreHelpList], @"operatingService 逻辑错误");
        
        if ([_operatingServiceMock.operatingCache hasMoreHelpList]) {
            pageIndex = 2;
            OCMStub([_protocolMock queryCompanyNotice:pageIndex size:MS_PAGE_SIZE type:TYPE_HELP keywords:nil requestType:LIST_REQUEST_MORE]).andReturn(signal);
            [[_operatingServiceMock queryHelpListByType:LIST_REQUEST_MORE] subscribeNext:^(id x) {
                XCTAssertEqual(_operatingServiceMock.operatingCache.helpList.count, 24, @"服务器返回数据不正确");
                XCTAssertEqual(_operatingServiceMock.operatingCache.totalHelpCount, 25, @"服务器返回数据不正确");
                XCTAssertTrue([_operatingServiceMock.operatingCache hasMoreHelpList], @"operatingService 逻辑错误");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"获取HelpList失败 :%@",error);
            }];
        }
        
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取HelpList失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryNoticeList {
    /*
     LIST_REQUEST_NEW,  //重新请求
     LIST_REQUEST_MORE, //请求更多
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryNoticeList"];
    
    __block NSInteger pageIndex = 1;
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        NSMutableArray *list = [NSMutableArray array];
        for (int i = 0; i < 12; i++) {
            NoticeInfo *info = [[NoticeInfo alloc] init];
            [list addObject:info];
        }
        ListRequestType type = (pageIndex == 1) ? LIST_REQUEST_NEW : LIST_REQUEST_MORE;
        NSDictionary *dic = @{TOTALCOUNT : @(25), LIST : list, TYPE : @(type)};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryCompanyNotice:pageIndex size:MS_PAGE_SIZE type:TYPE_NOTICE keywords:nil requestType:LIST_REQUEST_NEW]).andReturn(signal);
    [[_operatingServiceMock queryNoticeListByType:LIST_REQUEST_NEW] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssertEqual(_operatingServiceMock.operatingCache.noticeList.count, 12, @"服务器返回数据不正确");
        XCTAssertEqual(_operatingServiceMock.operatingCache.totalNoticeCount, 25, @"服务器返回数据不正确");
        XCTAssertTrue([_operatingServiceMock.operatingCache hasMoreNoticeList], @"operatingService 逻辑错误");
        
        if ([_operatingServiceMock.operatingCache hasMoreNoticeList]) {
            pageIndex = 2;
            OCMStub([_protocolMock queryCompanyNotice:pageIndex size:MS_PAGE_SIZE type:TYPE_NOTICE keywords:nil requestType:LIST_REQUEST_MORE]).andReturn(signal);
            [[_operatingServiceMock queryNoticeListByType:LIST_REQUEST_MORE] subscribeNext:^(id x) {
                XCTAssertEqual(_operatingServiceMock.operatingCache.noticeList.count, 24, @"服务器返回数据不正确");
                XCTAssertEqual(_operatingServiceMock.operatingCache.totalNoticeCount, 25, @"服务器返回数据不正确");
                XCTAssertTrue([_operatingServiceMock.operatingCache hasMoreNoticeList], @"operatingService 逻辑错误");
            } error:^(NSError *error) {
                [expectation fulfill];
                XCTFail(@"获取noticeList失败 :%@",error);
            }];
        }
        
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取noticeList失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryLatestNoticeId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryLatestNoticeId"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:@(1000)];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryNewNoticeList]).andReturn(signal);
    [[_operatingServiceMock queryLatestNoticeId] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssertGreaterThan(_operatingServiceMock.operatingCache.newNoticeId, 0, @"LatestNoticeId数据不对");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取LatestNoticeId失败 :%@",error);
    } completed:^{
        
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryUnreadMessageCount {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryUnreadMessageCount"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        [subscriber sendNext:@(1000)];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryUnreadMessageCount]).andReturn(signal);
    [[_operatingServiceMock queryUnreadMessageCount] subscribeNext:^(NSNumber *messageCount) {
        [expectation fulfill];
        XCTAssertGreaterThanOrEqual(messageCount.integerValue, 0, @"UnreadMessageCount数据不对");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取UnreadMessageCount失败 :%@",error);
    } completed:^{
        
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryMessageList {
    /*
     LIST_REQUEST_NEW,  //重新请求
     LIST_REQUEST_MORE, //请求更多
     */
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryMessageList"];
    
    __block NSInteger pageIndex = 1;
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        NSMutableArray *list = [NSMutableArray array];
        for (int i = 0; i < 12; i++) {
            MessageInfo *info = [[MessageInfo alloc] init];
            [list addObject:info];
        }
        ListRequestType type = (pageIndex == 1) ? LIST_REQUEST_NEW : LIST_REQUEST_MORE;
        NSDictionary *dic = @{TOTALCOUNT : @(25), LIST : list, TYPE : @(type)};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
        return nil;
    }];
    OCMStub([_protocolMock queryCompanyNotice:pageIndex size:MS_PAGE_SIZE type:TYPE_NOTICE keywords:nil requestType:LIST_REQUEST_NEW]).andReturn(signal);
    [[_operatingServiceMock queryMessageListByType:LIST_REQUEST_NEW] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssertEqual(_operatingServiceMock.operatingCache.messageList.count, 12, @"服务器返回数据不正确");
        XCTAssertTrue([_operatingServiceMock.operatingCache hasMoreNoticeList], @"operatingService 逻辑错误");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取MessageList失败 :%@",error);
    } completed:^{
        
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testReadMessageId {
    NSNumber *messageId = @(43452);  //messageId可能已经不存在
    XCTestExpectation *expectation = [self expectationWithDescription:@"testReadMessageId"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        RACError *result = [RACError createDefaultResult];
        result.result = ERR_NONE;
        [subscriber sendNext:result];
        [subscriber sendCompleted];

        return nil;
    }];
    OCMStub([_protocolMock sendReadMessageId:43452]).andReturn(signal);
    [[_operatingServiceMock readMessageWithId:messageId] subscribeNext:^(RACError *error) {
        [expectation fulfill];
        if (error.result == ERR_NONE) {
            XCTAssert(@"ReadMessageId成功");
        }else{
            XCTFail(@"Send read message id failed, error:%ld, message:%@",(long)error.result,error.message);
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testDeleteMessage {
    NSNumber *messageId = @(43458);  //messageId可能已经不存在
    XCTestExpectation *expectation = [self expectationWithDescription:@"DeleteMessage"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        RACError *result = [RACError createDefaultResult];
        result.result = ERR_NONE;
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        
        return nil;
    }];
    OCMStub([_protocolMock sendDeleteMessage:43452]).andReturn(signal);
    [[_operatingServiceMock deleteMessageWithId:messageId] subscribeNext:^(RACError *error) {
        [expectation fulfill];
        if (error.result == ERR_NONE) {
            XCTAssert(@"DeleteMessage成功");
        }else{
            XCTFail(@"delete message id failed, error:%ld, message:%@",(long)error.result,error.message);
        }
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testCheckUpdate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCheckUpdate"];
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
//        RACError *result = [RACError createDefaultResult];
//        result.result = -1;
//        [subscriber sendError:result];
        
        //success test
        UpdateInfo *info = [[UpdateInfo alloc] init];
        info.flag = 2;
        [subscriber sendNext:info];
        [subscriber sendCompleted];
        
        return nil;
    }];
    OCMStub([_protocolMock checkUpdate]).andReturn(signal);
    
    [[_operatingServiceMock checkUpdate] subscribeNext:^(id x) {
        [expectation fulfill];
        XCTAssertNotNil(_operatingServiceMock.operatingCache.updateInfo,@"updateInfo 为空");
        XCTAssertGreaterThan(_operatingServiceMock.operatingCache.updateInfo.flag, 0, @"flag  值不对");
        XCTAssertLessThan(_operatingServiceMock.operatingCache.updateInfo.flag, 4, @"flag  值不对");
        
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取CheckUpdate失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryRiskAssessment {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryRiskAssessment"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < 9; i++) {
            RiskInfo *info = [[RiskInfo alloc] init];
            for (int j = 0; j < 4; j++) {
                RiskDetailInfo *detailInfo = [[RiskDetailInfo alloc] init];
                [info.riskDetailInfoArr addObject:detailInfo];
            }
            [arr addObject:info];
        }
        [subscriber sendNext:arr];
        [subscriber sendCompleted];
        
        return nil;
    }];
    OCMStub([_protocolMock queryRiskAssessment]).andReturn(signal);
    [[_operatingServiceMock queryRiskAssessment] subscribeNext:^(NSMutableArray *arr) {
        [expectation fulfill];
       
        XCTAssertNotNil(arr, @"风险测评数据为空");
        XCTAssertGreaterThan(arr.count, 0, @"风险测评数据为空");
         RiskInfo *info = (RiskInfo *)[arr firstObject];
        XCTAssertGreaterThan(info.riskDetailInfoArr.count, 0, @"风险测评数据为空");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"获取QueryRiskAssessment失败 :%@",error);
    }];
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testCommitRiskAssessmentWithAnswers {
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 1; i <= 9; i++) {
        NSDictionary *dic = @{@"answerId" : [NSString stringWithFormat:@"%d",i * 4], @"questionId" : [NSString stringWithFormat:@"%d",i]};
        [arr addObject:dic];
    }
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCommitRiskAssessmentWithAnswers"];
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        RiskResultInfo *resultInfo = [[RiskResultInfo alloc] init];
        resultInfo.desc = @"保守型";
        resultInfo.icon = @"保守型";
        resultInfo.title = @"保守型";
        resultInfo.type = EVALUATE_OLD;
        if (resultInfo.type == EVALUATE_UNKNOWN) {
            resultInfo.title = @"未知型";
            resultInfo.desc = @"本版本暂不支持该类型";
        }
        
        [subscriber sendNext:resultInfo];
        [subscriber sendCompleted];
        
        return nil;
    }];
    OCMStub([_protocolMock commitRiskAssessment:OCMOCK_ANY]).andReturn(signal);
    
    [[_operatingServiceMock commitRiskAssessmentWithAnswers:arr] subscribeNext:^(RiskResultInfo *resultInfo) {
        [expectation fulfill];
        XCTAssertNotNil(_operatingServiceMock.operatingCache.resultInfo, @"提交测评结果失败");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"testCommitRiskAssessmentWithAnswers失败 :%@",error);
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}

- (void)testQueryRiskInfo {
    /*
     EVALUATE_NOT = 0,       //未评测
     EVALUATE_UNKNOWN = 1,   //未知型
     EVALUATE_OLD = 2,       //保守型
     EVALUATE_STEADY = 3,    //稳重型
     EVALUATE_RISK = 4,      //积极型
     */
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testQueryRiskInfo"];
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //error test
        //        RACError *result = [RACError createDefaultResult];
        //        result.result = -1;
        //        [subscriber sendError:result];
        
        //success test
        RiskResultInfo *resultInfo = [[RiskResultInfo alloc] init];
        resultInfo.desc = @"保守型";
        resultInfo.icon = @"保守型";
        resultInfo.title = @"保守型";
        resultInfo.type = EVALUATE_OLD;
        if (resultInfo.type == EVALUATE_UNKNOWN) {
            resultInfo.title = @"未知型";
            resultInfo.desc = @"本版本暂不支持该类型";
        }
        
        [subscriber sendNext:resultInfo];
        [subscriber sendCompleted];
        
        return nil;
    }];
    OCMStub([_protocolMock getRiskConfigueWithRiskType:EVALUATE_OLD]).andReturn(signal);
    
    [[_operatingServiceMock queryRiskInfoByType:EVALUATE_OLD] subscribeNext:^(RiskResultInfo *resultInfo) {
        [expectation fulfill];
        XCTAssertNotNil(_operatingServiceMock.operatingCache.resultInfo, @"获取测评结果失败");
    } error:^(NSError *error) {
        [expectation fulfill];
        XCTFail(@"testQueryRiskInfo失败 :%@",error);
    }];
    
    [XCTWaiter waitForExpectations:@[expectation] timeout:5];
}
@end
