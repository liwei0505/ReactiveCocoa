//
//  MSTransitionAnimator.m
//  Sword
//
//  Created by lee on 16/6/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSTransitionAnimator.h"
#import "MSPickerContainerViewController.h"

@interface MSTransitionAnimator() <UIViewControllerAnimatedTransitioning>

@end

@implementation MSTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return ANIMATION_DURATION;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect bounds = containerView.bounds;
    
    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = NO;
        toViewController.view.frame = bounds;
        [containerView addSubview:toViewController.view];
        
        MSPickerContainerViewController *container = (MSPickerContainerViewController*)toViewController;
        [container showWithAnimated:YES completion:^{
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        [containerView addSubview:fromViewController.view];
        MSPickerContainerViewController *container = (MSPickerContainerViewController*)fromViewController;
        [container hideWithAnimated:YES completion:^{
            [transitionContext completeTransition:YES];
        }];
    }
}


@end
