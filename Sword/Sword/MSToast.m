//
//  MSToast.m
//  Sword
//
//  Created by haorenjie on 16/6/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSToast.h"
#import "UIView+Toast.h"

@implementation MSToast

+ (void)show:(NSString *)message
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window makeToast:message duration:1.25f position:CSToastPositionCenter];
}


@end
