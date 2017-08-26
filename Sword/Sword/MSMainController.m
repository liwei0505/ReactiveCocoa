//
//  MSMainController.m
//  Sword
//
//  Created by lee on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMainController.h"
#import "MSHomeController.h"
#import "MSInvestController.h"
#import "MSAccountController.h"
#import "MSAppDelegate.h"
#import "MSLoginController.h"
#import "MSStoryboardLoader.h"
#import "MJSNotifications.h"
#import "MSLog.h"
#import "UIColor+StringColor.h"
#import "UIImage+color.h"

@interface MSMainController () <UITabBarControllerDelegate>

@end

@implementation MSMainController

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configElement];
    [self addChildViewController];
    [self pageEvent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.selectedViewController beginAppearanceTransition:YES animated:animated];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [MSNotificationHelper addObserver:self selector:@selector(onUserKickoutNotice:) name:NOTIFY_USER_KICK];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.selectedViewController endAppearanceTransition];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.selectedViewController beginAppearanceTransition:NO animated:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.selectedViewController endAppearanceTransition];
}


#pragma mark - add child controller
- (void)addChildViewController {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tabs.plist" ofType:nil];
    NSArray *tabs = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dict in tabs) {
        [self addChildViewControllerWithDictInfo:dict];
    }
    
}

- (void)addChildViewControllerWithDictInfo:(NSDictionary *)dict {

    if (!dict) {
        return;
    }

    Class child = NSClassFromString(dict[@"controller"]);
    UIViewController *controller = [[child alloc] init];
    controller.title = dict[@"title"];
    controller.tabBarItem.image = [[UIImage imageNamed:dict[@"nor_img"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    controller.tabBarItem.selectedImage = [[UIImage imageNamed:dict[@"sel_img"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self addChildViewController:controller];
    
}

#pragma mark - delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    self.navigationItem.title = [self getNavigationTitle:self.selectedIndex];
    if (tabBarController.selectedIndex == 2 || tabBarController.selectedIndex == 0) {
        [[[MSAppDelegate getInstance] getNavigationController] setNavigationBarHidden:YES animated:NO];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    if ([viewController isKindOfClass:[MSAccountController class]]) {
        BOOL isLogin = [[MSAppDelegate getServiceManager] isLogin];
        if (!isLogin) {
            MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
            MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
            loginVc.loginType = TYPE_ACCOUNT;
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
        return isLogin;
    }
    return YES;
}

#pragma mark - notification

- (void)onUserKickoutNotice:(NSNotification *)notification {

    MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
    MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
    __weak typeof(self)weakSelf = self;
    loginVc.backButtonBlock = ^{
        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        weakSelf.selectedIndex = 0;
    };
    [self.navigationController presentViewController:nav animated:YES completion:nil];
   
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

#pragma mark - Private
- (void)configElement {
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    [self drawShadowWithOffset:CGSizeMake(1, -1) radius:5 color:[UIColor grayColor] opacity:0.4];
    
    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    NSDictionary *attribute = @{NSForegroundColorAttributeName:[UIColor colorWithRed:216/255.0 green:58/255.0 blue:48/255.0 alpha:1.0],NSFontAttributeName:[UIFont systemFontOfSize:12]};
    [tabBarItem setTitleTextAttributes:attribute forState:UIControlStateSelected];
    
    self.delegate = self;
}

- (void)drawShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.tabBar.bounds];
    self.tabBar.layer.shadowPath = path.CGPath;
    self.tabBar.layer.shadowColor = color.CGColor;
    self.tabBar.layer.shadowOffset = offset;
    self.tabBar.layer.shadowRadius = radius;
    self.tabBar.layer.shadowOpacity = opacity;
    
    self.tabBar.clipsToBounds = NO;
}

- (void)setTabBarSelectedIndex:(NSUInteger)index {

    self.selectedIndex = index;
    self.navigationItem.title = [self getNavigationTitle:index];
}

- (NSString *)getNavigationTitle:(NSUInteger)index {

    switch (index) {
        case MSTab_Home: {
            [self eventElementId:43 text:@"首页"];
            return @"";
        }
        case MSTab_Invest: {
            [self eventElementId:44 text:@"理财"];
            return nil;
        }
        case MSTab_Account: {
            [self eventElementId:45 text:@"我的"];
            return @"";
        }
        default:
            return @"";
    }
}

#pragma mark - statistic
- (void)eventElementId:(int)elementId text:(NSString *)text {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 161;
    params.title = @"";
    params.elementId = elementId;
    params.elementText = text;
    [MJSStatistics sendEventParams:params];
    
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 161;
    params.title = @"主页";
    [MJSStatistics sendPageParams:params];
    
}

@end
