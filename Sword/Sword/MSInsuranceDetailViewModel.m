//
//  MSInsuranceDetailViewModel.m
//  Sword
//
//  Created by lee on 2017/8/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceDetailViewModel.h"
#import "MSUrlManager.h"
#import "NSString+URLEncoding.h"
#import "MSTextUtils.h"
#import "NSDate+Add.h"
#import "MSSettings.h"

@interface MSInsuranceDetailViewModel() {
    RACDisposable *_accountInfoSubscription;
}
@property (strong, nonatomic) NSMutableDictionary *urlCache;
@property (strong, nonatomic) AccountInfo *accountInfo;
@end

@implementation MSInsuranceDetailViewModel

- (instancetype)init {

    if (self = [super init]) {
        _switchStatus = YES;
        _count = 1;
        @weakify(self);
        _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
            @strongify(self);
            self.accountInfo = accountInfo;
        }];
    }
    return self;
}

- (void)dealloc {

    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
}

- (void)insuranceCompletion:(void(^)(BOOL status, NSString *url))completion {
    
    if (!self.detail.baseInfo.insuranceId || !self.productId || !self.effectiveDate || !self.count) {
        [MSToast show:@"投保信息不能为空"];
        return;
    }
    
    if (self.detail.needMail && !self.mail) {
        [MSToast show:@"投保信息不能为空"];
        return;
    } else if (!self.detail.needMail) {
        self.mail = @"";
    }
    
    if (self.typeOther && self.info.relationship == 1) {
        [MSToast show:@"请确认被投保对象"];
        return;
        
    } else if (self.typeOther && (!self.info.name.length || !self.info.certificateId.length)) {
        [MSToast show:@"被保险人信息不合法"];
        return;
    }
    
    if (self.typeOther) {
        [self checkYear:self.info.certificateId];
    } else {
        [self checkYear:self.accountInfo.idcardNum];
    }
    
    [MSProgressHUD showWithStatus:@"获取订单信息中..."];
    @weakify(self);
    [[[MSAppDelegate getServiceManager] insuranceWithInsuranceId:self.detail.baseInfo.insuranceId productId:self.productId effectiveDate:self.effectiveDate copiesCount:self.count insurerMail:self.mail insurant:self.info] subscribeNext:^(NSString *orderId) {
        @strongify(self);
        self.orderId = orderId;
        [[[MSAppDelegate getServiceManager] queryFHOnlinePayInfoWithOrderId:orderId] subscribeNext:^(FHOlinePayInfo *info) {
            [MSProgressHUD dismiss];
            NSString *url = [NSString stringWithFormat:@"%@?orderInfo=%@&channelCode=%@",[MSUrlManager getFHOLPayUrl],
                             [info.orderInfo URLEncodedString], [info.channelCode URLEncodedString]];
            completion(YES, url);
        } error:^(NSError *error) {
            [MSProgressHUD dismiss];
            RACError *result = (RACError *)error;
            [MSToast show:result.message];
            completion(NO, nil);
        }];
    } error:^(NSError *error) {
        [MSProgressHUD dismiss];
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
        completion(NO, nil);
    }];
}

- (void)queryDetail:(NSString *)insuranceId completion:(void(^)(BOOL status))completion {
    @weakify(self);
    
    [[[MSAppDelegate getServiceManager] queryInsuranceDetailWithId:insuranceId wholeInfo:YES] subscribeNext:^(InsuranceDetail *detail) {
        @strongify(self);
        self.detail = detail;
        completion(YES);

    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
        completion(NO);
    }];
}

- (void)queryContentCompletion:(void(^)(BOOL status, NSDictionary *dict))completion {

    NSString *insuranceId = self.detail.baseInfo.insuranceId;
    if (!insuranceId) {
        return;
    }

    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryInsuranceContentWithId:insuranceId type:INSURACE_CONTENT_TYPE_INTRODUCTION] subscribeNext:^(NSArray *urlList) {
        @strongify(self);
        [self.urlCache setObject:urlList forKey:@(INSURACE_CONTENT_TYPE_INTRODUCTION)];
    } error:^(NSError *error) {

    } completed:^{
        @weakify(self);
        [[[MSAppDelegate getServiceManager] queryInsuranceContentWithId:insuranceId type:INSURACE_CONTENT_TYPE_CLAIM_PROCESS] subscribeNext:^(NSArray *urlList) {
            @strongify(self);
            [self.urlCache setObject:urlList forKey:@(INSURACE_CONTENT_TYPE_CLAIM_PROCESS)];
        } error:^(NSError *error) {
            
        } completed:^{
            @weakify(self);
            [[[MSAppDelegate getServiceManager] queryInsuranceContentWithId:insuranceId type:INSURACE_CONTENT_TYPE_COMMON_PROBLEMS] subscribeNext:^(NSArray *urlList) {
                @strongify(self);
                [self.urlCache setObject:urlList forKey:@(INSURACE_CONTENT_TYPE_COMMON_PROBLEMS)];
                completion(YES, [self.urlCache copy]);
            } error:^(NSError *error) {
                completion(NO, nil);
            } completed:^{
                
            }];

        }];
        
    }];
}

- (void)checkYear:(NSString *)year {

    NSString *string = [year substringWithRange:NSMakeRange(6, 4)];
    NSInteger y = [NSDate date].year - [string integerValue];
    BOOL ok = (y<= _detail.maxAge && y>= _detail.minAge);
    if (!ok) {
        [MSToast show:@"年龄不符"];
        return;
    }

}

- (NSMutableDictionary *)urlCache {
    if (!_urlCache) {
        _urlCache = [NSMutableDictionary dictionary];
    }
    return _urlCache;
}

- (InsurantInfo *)info {
    if (!_info) {
        _info = [[InsurantInfo alloc] init];
        _info.relationship = 1;
        _info.name = @"";
        _info.certificateId = @"";
        _info.mobile = @"";
    }
    return _info;
}

- (NSMutableArray *)scrollHeightArray {
    if (!_scrollHeightArray) {
        _scrollHeightArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0), nil];
    }
    return _scrollHeightArray;
}

@end
