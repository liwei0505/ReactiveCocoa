//
//  MSVersionUtils.h
//  Sword
//
//  Created by msj on 16/9/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateInfo.h"


@interface MSVersionUtils : NSObject
+ (void)updateVersion:(UpdateInfo *)info;
+ (BOOL)isShouldUpdate:(UpdateInfo *)info;
+ (BOOL)isAlertViewAlreadyShow;
@end
