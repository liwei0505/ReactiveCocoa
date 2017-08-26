//
//  MSVersionUtils.m
//  Sword
//
//  Created by msj on 16/9/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSVersionUtils.h"
#import "MSAppDelegate.h"
#import "MSAlert.h"

typedef  NS_ENUM(NSInteger, UpdateType) {
    
    UPDATE_NONE = 1,    //不需要更新
    UPDATE_ADVICE = 2,  //建议更新
    UPDATE_FORCE = 3,   //强制更新
};

static BOOL _isAlreadyShow;

@implementation MSVersionUtils
+ (void)updateVersion:(UpdateInfo *)info
{
    int flag = (int)info.flag;

    if (flag == UPDATE_NONE) {
        _isAlreadyShow = NO;
        return;
    }
    else if (flag == UPDATE_ADVICE) {
        _isAlreadyShow = YES;
        [MSAlert showWithTitle:NSLocalizedString(@"str_update_title", @"") message:nil buttonClickBlock:^(NSInteger buttonIndex) {
            _isAlreadyShow = NO;
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/min-jin-suo-fan-hai-kong-gu/id1128649483?mt=8"];
                [[UIApplication sharedApplication]openURL:url];
            }
        } cancelButtonTitle:NSLocalizedString(@"str_update_no", @"") otherButtonTitles:NSLocalizedString(@"str_update_yes", @""), nil];
    }
    else if (flag == UPDATE_FORCE) {
        _isAlreadyShow = YES;
        [MSAlert showWithTitle:NSLocalizedString(@"str_update_title", @"") message:nil buttonClickBlock:^(NSInteger buttonIndex) {
            _isAlreadyShow = NO;
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/min-jin-suo-fan-hai-kong-gu/id1128649483?mt=8"];
            [[UIApplication sharedApplication]openURL:url];
            
        } cancelButtonTitle:NSLocalizedString(@"str_update_yes", @"") otherButtonTitles: nil];
    }
    else {
        _isAlreadyShow = NO;
        NSLog(@"press unexpected index during update version");
    }

}
+ (BOOL)isAlertViewAlreadyShow
{
    return _isAlreadyShow;
}
+ (BOOL)isShouldUpdate:(UpdateInfo *)info
{
    int flag = (int)info.flag;
    
    if (flag == UPDATE_NONE) {
        return NO;
    }
    return YES;
}

@end
