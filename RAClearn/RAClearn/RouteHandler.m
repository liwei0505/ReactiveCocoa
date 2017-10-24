//
//  RouteHandler.m
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RouteHandler.h"

@implementation RouteHandler

//子类可以覆写这个方法，实现一些参数检查或者当然App状态检查的工作
- (BOOL)shouldHandleWithRequest:(RouteRequest *)request {
    return YES;
}

- (BOOL)handleRequest:(RouteRequest *)request error:(NSError *)error {
    RouteBaseController *source = [self sourceViewControllerForTransitionWithRequest:request];
    RouteBaseController *target = [self targetViewControllerWithRequest:request];
    if (![source isKindOfClass:[RouteBaseController class]] || ![target isKindOfClass:[RouteBaseController class]]) {
        //*error.code =
        return NO;
    }
    
    target.request = request;
    BOOL isPreferModal = [self preferModalPresentationWithRequest:request];
    return [self transitionWithRequest:request sourceViewController:source targetViewController:target isPreferModal:isPreferModal error:error];
}

// 根据request获取目标控制器
- (RouteBaseController *)sourceViewControllerForTransitionWithRequest:(RouteRequest *)request {
    return [RouteBaseController new];
}

//转场一定是从一个视图控制器跳转到另外一个视图控制器，该方法用以获取转场中的源视图控制器
- (RouteBaseController *)targetViewControllerWithRequest:(RouteRequest *)request {
    return [RouteBaseController new];
}

//根据request来返回是否是模态跳转
- (BOOL)preferModalPresentationWithRequest:(RouteRequest *)request {
    return YES;
}

//方法内根据request、获取的目标和源视图控制器，完成转场逻辑
- (BOOL)transitionWithRequest:(RouteRequest *)request sourceViewController:(UIViewController *)source targetViewController:(UIViewController *)target isPreferModal:(BOOL)isPreferModal error:(NSError *)error {
    if (isPreferModal || ![source isKindOfClass:[UINavigationController class]]) {
        [source presentViewController:target animated:YES completion:nil];
    } else if ([source isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)source;
        [nav pushViewController:target animated:YES];
    }
    return YES;
}
@end
