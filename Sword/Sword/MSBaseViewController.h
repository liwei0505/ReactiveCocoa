//
//  MSBaseViewController.h
//  Sword
//
//  Created by lee on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSAppDelegate.h"
#import "MSNavigationController.h"
#import "UIColor+StringColor.h"
#import "MJSNotifications.h"
#import "MJSStatistics.h"
#import "MSEmptyView.h"
#import "MJRefresh.h"
#import "MSConsts.h"
#import "MSToast.h"
#import "MSAlert.h"
#import "MSLog.h"
#import "MSAlertController.h"
#import "RACError.h"
#import "MSPageStateView.h"

@interface MSBaseViewController : UIViewController
@property (strong, nonatomic) MSPageStateView *pageStateView;
@property (strong, nonatomic) MSEmptyView *emptyView;

- (void)showEmptyView;
- (void)hideEmptyView;
- (void)handleUserNotLogin:(ErrorCode)status;
- (void)setTabbarControllerIndex:(NSUInteger)index;
- (void)popToPush:(UIViewController *)controller index:(NSInteger)index;

- (void)eventWithName:(NSString *)name elementId:(int)eId title:(NSString *)title pageId:(int)pageId params:(NSDictionary *)dict;
- (void)pageEventWithTitle:(NSString *)title pageId:(int)pageId params:(NSDictionary *)dict;

@end
