//
//  AppDelegate.h
//  Sword
//
//  Created by lee on 16/5/3.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNavigationController.h"
#import "MSServiceManager.h"
#import "MSRegistController.h"

@interface MSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (MSAppDelegate *)getInstance;
+ (MSServiceManager *)getServiceManager;
- (MSNavigationController *)getNavigationController;
- (void)popViewControllerAnimated:(BOOL)animated;

@end

