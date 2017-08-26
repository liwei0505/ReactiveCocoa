//
//  MSNavigationController.m
//  Sword
//
//  Created by msj on 16/9/12.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSNavigationController.h"
#import "MSDeviceUtils.h"

@interface MSNavigationController ()

@end

@implementation MSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configElement];
}

- (void)configElement {
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTintColor:[UIColor whiteColor]];
    UIImage *oldImage = [UIImage imageNamed:@"ms_bg_image"];
    UIImage *bgImage = [oldImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, oldImage.size.width*0.5 - 1, 0.5, oldImage.size.width*0.5 - 1) resizingMode:UIImageResizingModeStretch];
    [navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    [navigationBar setTranslucent:NO];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]};
    [navigationBar setTitleTextAttributes:attributes];
    
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonOnClick)];
        
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (void)backButtonOnClick {
    [self popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognize {
    return self.childViewControllers.count > 1;
}
@end
