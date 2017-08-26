//
//  ZKProtocolStub.m
//  Sword
//
//  Created by haorenjie on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "ZKProtocolStub.h"
#import "TimeUtils.h"

@implementation ZKProtocolStub

- (instancetype)initWithSessionManager:(ZKSessionManager *)sessionManager {
    if (self = [super initWithSessionManager:sessionManager]) {
        // Initialize.
    }
    return self;
}

- (RACSignal *)queryMyAsset {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AssetInfo *assetInfo = [[AssetInfo alloc] init];
        assetInfo.balance = [NSDecimalNumber decimalNumberWithString:@"10000"];
        assetInfo.withdrawFrozenAmount = [NSDecimalNumber decimalNumberWithString:@"1000"];
        assetInfo.regularAsset.tobeReceivedPrincipal = [NSDecimalNumber decimalNumberWithString:@"10000"];
        assetInfo.regularAsset.tobeReceivedInterest = [NSDecimalNumber decimalNumberWithString:@"700"];
        assetInfo.regularAsset.investFrozenAmount = [NSDecimalNumber decimalNumberWithString:@"1000"];
        assetInfo.currentAsset.investAmount = [NSDecimalNumber decimalNumberWithString:@"5000"];
        assetInfo.currentAsset.addUpAmount = [NSDecimalNumber decimalNumberWithString:@"200"];
        assetInfo.currentAsset.purchaseFrozenAmount = [NSDecimalNumber decimalNumberWithString:@"1000"];
        assetInfo.currentAsset.redeemFrozenAmount = [NSDecimalNumber decimalNumberWithString:@"100"];
        assetInfo.currentAsset.historyAddUpAmount = [NSDecimalNumber decimalNumberWithString:@"50"];
        assetInfo.currentAsset.yesterdayEarnings = [NSDecimalNumber decimalNumberWithString:@"10"];
        [subscriber sendNext:assetInfo];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)queryCurrentListWithLastID:(NSNumber *)lastCurrentID pageSize:(NSInteger)pageSize isRecommended:(BOOL)isRecommended {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableArray *currentList = [[NSMutableArray alloc] initWithCapacity:1];

        CurrentInfo *currentInfo = [[CurrentInfo alloc] init];
        currentInfo.currentID = @(5000);
        currentInfo.title = @"民金宝";
        currentInfo.interestRate = @(0.012);
        currentInfo.interestRateDescription = @"当日年化收益率";
        currentInfo.termUnit = @"灵活存取";
        currentInfo.status = STATUS_SALING;
        currentInfo.startAmount = [NSDecimalNumber decimalNumberWithString:@"100"];
        currentInfo.inceaseAmount = [NSDecimalNumber decimalNumberWithString:@"0.01"];
        currentInfo.supportedRedEnvelopeTypes = 0;

        [currentList addObject:currentInfo];
        [subscriber sendNext:currentList];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)queryCurrentDetail:(NSNumber *)currentID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CurrentDetail *currentDetail = [[CurrentDetail alloc] init];
        currentDetail.baseInfo.currentID = currentID;
        currentDetail.bannerURL = @"http://101.200.156.252/h5/util/pic?filePath=/mjs/mbanner/17507488-0474-441c-99e7-abe0fa323d10.jpg";
        currentDetail.earningsPer10000 = [NSDecimalNumber decimalNumberWithString:@"6.2920"];
        currentDetail.maxDisplayInterestRate = @(0.0319);
        currentDetail.minDisplayInterestRate = @(-0.0099);
        currentDetail.intervalRateCount = 4;
        currentDetail.investRulesURL = @"http://www.baidu.com";

        NSMutableArray *last7DaysInterstRates = [[NSMutableArray alloc] initWithCapacity:7];
        for (int i = 0; i < 7; ++i) {
            DayInterestRate *rateInfo = [[DayInterestRate alloc] init];
            rateInfo.interestRate = ((arc4random() % 10000)*1.0/5001 + 1) / 100;
            rateInfo.date = (long)([TimeUtils currentTimeMillis] / 1000L) - 86400 * (7 - i);
            [last7DaysInterstRates addObject:rateInfo];
        }
        currentDetail.last7DaysInterestRates = last7DaysInterstRates;

        currentDetail.productInfo.productManager = @"金融交易所（上海）有限公司";
        NSArray *itemNames = @[@"产品说明书", @"产品认购协议", @"风险揭示书", @"募集说明书"];
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:itemNames.count];
        for (int i = 0; i < itemNames.count; ++i) {
            CurrentProductItem *productItem = [[CurrentProductItem alloc] init];
            productItem.name = itemNames[i];
            productItem.order = i;
            productItem.url = @"http://www.baidu.com";
            [items addObject:productItem];
        }
        currentDetail.productInfo.items = items;

        [subscriber sendNext:currentDetail];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)queryCurrentEarningsHistoryWithID:(NSNumber *)currentID lastEarningsDate:(long)lastDate pageSize:(NSInteger)pageSize {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:[NSArray array]];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)queryCurrentPurchaseConfig:(NSNumber *)currentID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CurrentPurchaseConfig *config = [[CurrentPurchaseConfig alloc] init];
        config.beginInterestDate = (long)([TimeUtils currentTimeMillis] / 1000L);
        config.canPurchaseLimit = [NSDecimalNumber decimalNumberWithString:@"50000"];
        [subscriber sendNext:config];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)purchaseCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CurrentPurchaseNotice *notice = [[CurrentPurchaseNotice alloc] init];
        notice.purchaseDate = (long)([TimeUtils currentTimeMillis] / 1000L);
        notice.beginInterestDate = notice.purchaseDate + 2 * 3600;
        notice.earningsReceiveDate = notice.beginInterestDate + 5 * 3600;
        [subscriber sendNext:notice];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)queryCurrentRedeemConfig:(NSNumber *)currentID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CurrentRedeemConfig *config = [[CurrentRedeemConfig alloc] init];
        config.earningsReceiveDate = (long)([TimeUtils currentTimeMillis] / 1000L) + 2 * 86400;
        config.leftCanRedeemCount = 4;
        config.leftCanRedeemAmount = [NSDecimalNumber decimalNumberWithString:@"40000"];
        config.redeemRulesURL = @"http://www.baidu.com";
        [subscriber sendNext:config];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)redeemCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CurrentRedeemNotice *notice = [[CurrentRedeemNotice alloc] init];
        notice.redeemApplyDate = (long)([TimeUtils currentTimeMillis] / 1000L);
        notice.earningsToBeReceiveDate = notice.redeemApplyDate + 2 * 3600;
        [subscriber sendNext:notice];
        [subscriber sendCompleted];
        return nil;
    }];
}

@end
