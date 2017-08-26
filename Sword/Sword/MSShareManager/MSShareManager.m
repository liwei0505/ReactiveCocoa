//
//  MSShareManager.m
//  Sword
//
//  Created by lee on 16/7/12.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSShareManager.h"
#import "MSShareView.h"
#import "MSInviteView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "MSPayManager.h"

@interface MSShareManager ()
@property (strong, nonatomic, readwrite) MSQQApiResponse *qqApiResponse;
@property (strong, nonatomic, readwrite) MSWXApiResponse *wxApiResponse;
@property (strong, nonatomic, readwrite) MSWBApiResponse *wbApiResponse;
@end

@implementation MSShareManager
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static MSShareManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.qqApiResponse = [[MSQQApiResponse alloc] init];
        self.wxApiResponse = [[MSWXApiResponse alloc] init];
        self.wbApiResponse = [[MSWBApiResponse alloc] init];
    }
    return self;
}

- (void)ms_registerThirdShareSDK
{
    [self registerWX];
    [self registerQQ];
    [self registerSinaWeiBo];
}

#pragma mark - 注册三方SDK
-(void)registerWX
{
    [WXApi registerApp:@"wxf4103a4b13aeed8a"];
}
-(void)registerQQ
{
    [MSShareManager sharedManager].qqApiResponse.tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1105388370" andDelegate:[MSShareManager sharedManager].qqApiResponse];
}
-(void)registerSinaWeiBo
{
    if ([WeiboSDK isWeiboAppInstalled]) {
        [WeiboSDK enableDebugMode:YES];
        [WeiboSDK registerApp:@"2414355908"];
    }
}

#pragma mark - 回调代理设置
- (BOOL)ms_application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *host = url.host;
    if([@"platformId=wechat" isEqualToString:host]){
        return [WXApi handleOpenURL:url delegate:[MSShareManager sharedManager].wxApiResponse];
    } else if ([@"response_from_qq" isEqualToString:host]){
        [QQApiInterface handleOpenURL:url delegate:[MSShareManager sharedManager].qqApiResponse];
        return [TencentOAuth HandleOpenURL:url];
    } else if ([@"response" isEqualToString:host]){
        return [WeiboSDK handleOpenURL:url delegate:[MSShareManager sharedManager].wbApiResponse];
    } else if ([@"safepay" isEqualToString:host]){
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [MSPayManager payAliSuccessHandle:resultDic];
        }];
    }
    return NO;
}
- (BOOL)ms_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([@"com.tencent.xin" isEqualToString:sourceApplication]){
        return [WXApi handleOpenURL:url delegate:[MSShareManager sharedManager].wxApiResponse];
    } else if ([@"com.tencent.mqq" isEqualToString:sourceApplication]){
        [QQApiInterface handleOpenURL:url delegate:[MSShareManager sharedManager].qqApiResponse];
        return [TencentOAuth HandleOpenURL:url];
    } else if ([@"com.sina.weibo" isEqualToString:sourceApplication]){
        return [WeiboSDK handleOpenURL:url delegate:[MSShareManager sharedManager].wbApiResponse];
    } else if ([@"com.alipay.iphoneclient" isEqualToString:sourceApplication]){
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [MSPayManager payAliSuccessHandle:resultDic];
        }];
    }
    return NO;
}

#pragma mark - UI界面
- (void)ms_setShareUrl:(NSString *)shareUrl shareTitle:(NSString *)title shareContent:(NSString *)content shareIcon:(NSString *)iconUrl shareId:(NSString *)shareId shareType:(MSShareManagerType)shareType
{
    
    switch (shareType) {
        case MSShareManager_share:
        {
            MSInviteView *inviteView = [[MSInviteView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            if (self.selectedShareType) {
                inviteView.selectedShareType = self.selectedShareType;
            }
            [inviteView setShareUrl:shareUrl shareTitle:title shareContent:content shareIcon:iconUrl shareId:shareId];
            [[[UIApplication sharedApplication].delegate window] addSubview:inviteView];
            break;
        }
        case MSShareManager_invite:
        {
            MSInviteView *inviteView = [[MSInviteView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            if (self.selectedShareType) {
                inviteView.selectedShareType = self.selectedShareType;
            }
            [inviteView setShareUrl:shareUrl shareTitle:title shareContent:content shareIcon:iconUrl shareId:shareId];
            [[[UIApplication sharedApplication].delegate window] addSubview:inviteView];
            break;
        }
        default:
            break;
    }
}

@end
