//
//  UINavigationController+MSPushPopCompletionBlock.h
//  Sword
//
//  Created by msj on 2017/8/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (MSPushPopCompletionBlock)

- (void)pushViewController:(UIViewController* _Nonnull)viewController animated:(BOOL)animated completion: (void (^ __nullable)(void))completion;

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated completion: (void (^ __nullable)(void))completion;

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController * _Nonnull)viewController animated:(BOOL)animated  completion: (void (^ __nullable)(void))completion;

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated  completion: (void (^ __nullable)(void))completion;

@end
