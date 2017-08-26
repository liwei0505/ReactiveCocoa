//
//  MSLoginController.h
//  Sword
//
//  Created by lee on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSBaseViewController.h"

@interface MSLoginController : MSBaseViewController

@property (assign, nonatomic) ControllerJumpType loginType;
@property (strong, nonatomic) UIBarButtonItem *backItem;

@property (copy, nonatomic) void(^backButtonBlock)(void);
@property (copy, nonatomic) void(^userLoginSucceedBlock)(void);

@end
