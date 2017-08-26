//
//  PreferenceUtils.m
//  MJS
//
//  Created by lee on 16/2/16.
//  Copyright © 2016年 lw. All rights reserved.
//

#import "PreferenceUtils.h"

#define UserPhone @"UserPhone"
#define UserPassWord @"UserPassWord"


@implementation PreferenceUtils

//加载用户信息
+ (NSString *)loadUserPhone {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:UserPhone];
}

//如果登录成功，保存用户信息
+ (void)saveUserPhone:(NSString *)phone {
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:phone forKey:UserPhone];
}



@end
