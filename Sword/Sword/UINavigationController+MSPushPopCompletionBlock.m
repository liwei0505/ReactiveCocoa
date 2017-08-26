//
//  UINavigationController+MSPushPopCompletionBlock.m
//  Sword
//
//  Created by msj on 2017/8/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "UINavigationController+MSPushPopCompletionBlock.h"

@implementation UINavigationController (MSPushPopCompletionBlock)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion: (void (^ __nullable)(void))completion {
    [CATransaction setCompletionBlock:completion];
    [CATransaction begin];
    [self pushViewController:viewController animated:animated];
    [CATransaction commit];
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated completion: (void (^ __nullable)(void))completion {
    UIViewController *poppedViewController;
    [CATransaction setCompletionBlock:completion];
    [CATransaction begin];
    poppedViewController = [self popViewControllerAnimated:animated];
    [CATransaction commit];
    return poppedViewController;
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController * _Nonnull)viewController animated:(BOOL)animated  completion: (void (^ __nullable)(void))completion{
    NSArray<UIViewController*>* viewControllers;
    [CATransaction setCompletionBlock:completion];
    [CATransaction begin];
    viewControllers = [self popToViewController:viewController animated:animated];
    [CATransaction commit];
    return viewControllers;
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated   completion: (void (^ __nullable)(void))completion {
    NSArray<UIViewController*>* viewControllers;
    [CATransaction setCompletionBlock:completion];
    [CATransaction begin];
    viewControllers = [self popToRootViewControllerAnimated:animated];
    [CATransaction commit];
    return viewControllers;
}

@end
