//
//  MSQQApiResponse.m
//  Sword
//
//  Created by msj on 16/10/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSQQApiResponse.h"

@implementation MSQQApiResponse

#pragma mark － QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
    NSLog(@"%s",__func__);
}

- (void)onResp:(QQBaseResp *)resp
{
    NSLog(@"%s",__func__);
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            NSLog(@"QQ返回的result: %@",resp.result);
            if([@"0" isEqualToString:resp.result]){
                [MSToast show:NSLocalizedString(@"hint_share_success", @"")];
            }else if([@"-1" isEqualToString:resp.result]){
                [MSToast show:[NSString stringWithFormat:@"%@",resp.errorDescription]];
            }else if([@"-4" isEqualToString:resp.result]){
                [MSToast show:@"取消分享"];
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response
{
    NSLog(@"%s",__func__);
}


#pragma mark － TencentSessionDelegate
- (void)tencentDidLogin
{
    NSLog(@"%s",__func__);
}


-(void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"%s",__func__);
}

-(void)tencentDidNotNetWork
{
    NSLog(@"%s",__func__);
}

- (void)getUserInfoResponse:(APIResponse*) response
{
    NSLog(@"%s",__func__);
}
@end
