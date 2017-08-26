//
//  MSWBApiResponse.m
//  Sword
//
//  Created by msj on 16/10/19.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSWBApiResponse.h"

@implementation MSWBApiResponse

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSLog(@"微博返回的statusCode：%ld",(long)response.statusCode);
    if (response.statusCode == 0) {
        if ([response isKindOfClass:WBAuthorizeResponse.class]){
            self.sinaAccessToken = [(WBAuthorizeResponse *)response accessToken];
            self.sinaUserId = [(WBAuthorizeResponse *)response userID];
            
        }else if([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
            [MSToast show:NSLocalizedString(@"hint_share_success", @"")];
        }
    }else if (response.statusCode == -1){
        [MSToast show:@"取消分享"];
    }
}

@end
