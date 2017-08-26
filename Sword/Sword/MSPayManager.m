//
//  MSPayManager.m
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPayManager.h"
#import <AlipaySDK/AlipaySDK.h>

@interface MSPayManager ()
@property (copy, nonatomic) PaySuccess paySuccess;
@property (copy, nonatomic) RequestError requestError;
@property (copy, nonatomic) NSString * orderId;
@property (assign, nonatomic) PayType payType;
@property (assign, nonatomic) BOOL isNeedCheckSyncResult;
@end

@implementation MSPayManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static MSPayManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - Public
+ (void)payWithOrderId:(NSString *)orderId payType:(PayType)payType isNeedCheckSyncResult:(BOOL)isNeedCheckSyncResult paySuccess:(PaySuccess)paySuccess requestError:(RequestError)requestError {
    
    if (!orderId || orderId.length == 0) {
        [MSToast show:@"订单号不能为空"];
        return;
    }
    
    if (payType != Pay_Ali && payType != Pay_Wx) {
        [MSToast show:@"支付类型错误"];
        return;
    }
    
    [MSPayManager sharedManager].isNeedCheckSyncResult = isNeedCheckSyncResult;
    [MSPayManager sharedManager].requestError = requestError;
    [MSPayManager sharedManager].paySuccess = paySuccess;
    [MSPayManager sharedManager].orderId = orderId;
    [MSPayManager sharedManager].payType = payType;
    [[MSPayManager sharedManager] pay];
}

+ (BOOL)payInterceptorWithUrl:(NSString *)payUrl paySuccess:(PaySuccess)paySuccess {
    
    [MSPayManager sharedManager].paySuccess = paySuccess;
    
    return [[AlipaySDK defaultService] payInterceptorWithUrl:payUrl fromScheme:@"alipaysdkmsjf" callback:^(NSDictionary *resultDic) {
        [MSPayManager payAliSuccessHandle:resultDic];
    }];
}

+ (void)payAliSuccessHandle:(NSDictionary *)dic {
    [[MSPayManager sharedManager] payAliSuccessHandle:dic];
}

+ (void)payWxSuccessHandle:(PayResp *)resp {
    [[MSPayManager sharedManager] payWxSuccessHandle:resp];
}

#pragma mark - query
- (void)pay {
    @weakify(self);
    [MSProgressHUD showWithStatus:@"正在支付中..."];
    [[[MSAppDelegate getServiceManager] queryPayInfoWithOrderId:[MSPayManager sharedManager].orderId payType:[MSPayManager sharedManager].payType] subscribeNext:^(NSDictionary *result) {
        [MSProgressHUD dismiss];
        @strongify(self);
        if ([MSPayManager sharedManager].payType == Pay_Ali) {
            [self aliPay:result];
        } else if ([MSPayManager sharedManager].payType == Pay_Wx) {
            [self wxPay:result];
        }
        
    } error:^(NSError *error) {
        [MSProgressHUD dismiss];
        [MSPayManager sharedManager].requestError(error);
    }];
}

- (void)aliPay:(NSDictionary *)params {
    
    NSString *orderString = params[@"orderString"];
    NSString *appScheme = @"alipaysdkmsjf";
    
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        //支付宝web支付完成回调
        [self payAliSuccessHandle:resultDic];
    }];
}

- (void)wxPay:(NSDictionary *)params {
    
    PayReq *req = [[PayReq alloc] init];
    req.partnerId = params[@"partnerId"];
    req.prepayId = params[@"prepayId"];
    req.nonceStr = params[@"noncestr"];
    req.timeStamp = [params[@"timestamp"] intValue];
    req.package = params[@"package"];
    req.sign = params[@"sign"];
    
    BOOL wxResult = [WXApi sendReq:req];
    
    if (!wxResult) {
        [MSToast show:@"调用微信失败，请重试"];
    }
}

#pragma mark - Private
- (void)payAliSuccessHandle:(NSDictionary *)dic {
    
    NSString *resultStatus = dic[@"resultStatus"];
    
    if (!resultStatus || resultStatus.length == 0) {
        resultStatus = dic[@"resultCode"];
    }
    
    if ([resultStatus isEqualToString:@"9000"]) {
        
        NSString *result = dic[@"result"];
        
        if (result && result.length > 0) {
            
            NSData *dataResult = [dic[@"result"] dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *error = nil;
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:dataResult options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                [MSToast show:@"其它支付错误"];
                [MSPayManager sharedManager].paySuccess(NO,nil);
                NSLog(@"数据解析错误===%@",error);
            } else {
                if ([resultDic[@"code"] isEqualToString:@"10000"] && [resultDic[@"out_trade_no"] isEqualToString:[MSPayManager sharedManager].orderId]) {
                    [MSToast show:@"订单支付成功"];
                    [MSPayManager sharedManager].paySuccess(YES,nil);
                } else {
                    [MSToast show:@"其它支付错误"];
                    [MSPayManager sharedManager].paySuccess(NO,nil);
                }
            }
            
        } else {
            
            [MSToast show:@"订单支付成功"];
            //支付结束后应当跳转的url地址
            NSString *completePageUrl = dic[@"returnUrl"];
            [MSPayManager sharedManager].paySuccess(YES,completePageUrl);
        }
        
    } else if ([resultStatus isEqualToString:@"4000"]) {
        [MSToast show:@"订单支付失败"];
        [MSPayManager sharedManager].paySuccess(NO,nil);
    } else if ([resultStatus isEqualToString:@"6001"]) {
        [MSToast show:@"订单支付取消"];
        [MSPayManager sharedManager].paySuccess(NO,nil);
    } else {
        [MSToast show:@"其它支付错误"];
        [MSPayManager sharedManager].paySuccess(NO,nil);
    }
}

- (void)payWxSuccessHandle:(PayResp *)resp {
    switch (resp.errCode) {
        case WXSuccess:
        {
            [MSToast show:@"订单支付成功"];
            [MSPayManager sharedManager].paySuccess(YES,nil);
            break;
        }
        case WXErrCodeCommon:
        {
            [MSToast show:@"订单支付失败"];
            [MSPayManager sharedManager].paySuccess(NO,nil);
            break;
        }
        case WXErrCodeUserCancel:
        {
            [MSToast show:@"订单支付取消"];
            [MSPayManager sharedManager].paySuccess(NO,nil);
            break;
        }
        default:
        {
            [MSToast show:@"其它支付错误"];
            [MSPayManager sharedManager].paySuccess(NO,nil);
            break;
        }
    }
}

@end
