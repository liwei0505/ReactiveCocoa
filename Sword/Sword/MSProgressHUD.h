//
//  MSProgressHUD.h
//  Orange
//
//  Created by msj on 2017/7/28.
//  Copyright © 2017年 msf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSProgressHUD : NSObject
+ (void)show;
+ (void)showWithStatus:(NSString*)status;
+ (void)dismiss;
@end
