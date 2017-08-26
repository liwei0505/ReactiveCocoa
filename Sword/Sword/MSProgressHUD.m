//
//  MSProgressHUD.m
//  Orange
//
//  Created by msj on 2017/7/28.
//  Copyright © 2017年 msf. All rights reserved.
//

#import "MSProgressHUD.h"
#import <SVProgressHUD.h>

@implementation MSProgressHUD
+ (void)show {
    [self showWithStatus:nil];
}

+ (void)showWithStatus:(NSString*)status {
    [self configure];
    [SVProgressHUD showWithStatus:status];
}

+ (void)dismiss {
    [SVProgressHUD dismiss];
}

+ (void)configure {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}
@end
