//
//  MSBaseViewController.m
//  Sword
//
//  Created by lee on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
#import "MSLoginController.h"
#import "MSStoryboardLoader.h"
#import "MSMainController.h"

@interface MSBaseViewController ()

@end

@implementation MSBaseViewController

- (MSPageStateView *)pageStateView {
    if (!_pageStateView) {
        _pageStateView = [[MSPageStateView alloc] init];
    }
    return _pageStateView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configure];
}

- (void)configure {
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    self.pageStateView.state = MSPageStateMachineType_idle;
}

- (void)showEmptyView {
    if (!_emptyView) {
        _emptyView = [MSEmptyView instance];
    }
    _emptyView.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 44 - 50 - 64);
    [self.view addSubview:_emptyView];
}

- (void)hideEmptyView {
    if (_emptyView) {
        [_emptyView removeFromSuperview];
    }
}

- (void)handleUserNotLogin:(ErrorCode)status {
    if (status == ERR_NOT_LOGIN) {
        MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
        MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)popToPush:(UIViewController *)controller index:(NSInteger)index {
    @weakify(self);
    [self.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (self == obj) {
            UIViewController *vc = self.navigationController.childViewControllers[idx-index];
            [self.navigationController popToViewController:vc animated:NO];
            [[[MSAppDelegate getInstance] getNavigationController] pushViewController:controller animated:YES];
        }
    }];
}

- (void)setTabbarControllerIndex:(NSUInteger)index {

    UITabBarController *controller = [[MSAppDelegate getInstance] getNavigationController].childViewControllers[0];
    if ([controller isKindOfClass:[MSMainController class]]) {
        MSMainController *main = (MSMainController *)controller;
        [main setTabBarSelectedIndex:index];
    }
}

- (void)eventWithName:(NSString *)name elementId:(int)eId title:(NSString *)title pageId:(int)pageId params:(NSDictionary *)dict {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = pageId;
    params.title = title;
    params.elementId = eId;
    params.elementText = name;
    if (dict) {
        params.params = dict;
    }
    [MJSStatistics sendEventParams:params];
}

- (void)pageEventWithTitle:(NSString *)title pageId:(int)pageId params:(NSDictionary *)dict {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = pageId;
    params.title = title;
    if (dict) {
        params.params = dict;
    }
    [MJSStatistics sendPageParams:params];
    
}

@end
