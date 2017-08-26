//
//  MSWXApiResponse.m
//  Sword
//
//  Created by msj on 16/10/19.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSWXApiResponse.h"
#import "MSPayManager.h"

@implementation MSWXApiResponse

#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req{}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        if (resp.errCode == WXSuccess) {
            [MSToast show:@"分享成功"];
        } else if (resp.errCode == WXErrCodeCommon){
            [MSToast show:@"分享失败，请重试"];
        } else if (resp.errCode == WXErrCodeUserCancel){
            [MSToast show:@"取消分享"];
        }
        
    } else if ([resp isKindOfClass:[PayResp class]]){
        [MSPayManager payWxSuccessHandle:(PayResp *)resp];
    }
}
@end
