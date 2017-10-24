//
//  RouteHandler.h
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteRequest.h"
#import "RouteBaseController.h"

@interface RouteHandler : NSObject

//即将开始处理request请求，返回值决定是否要继续相应request
- (BOOL)shouldHandleWithRequest:(RouteRequest *)request;
//开始处理request请求
- (BOOL)handleRequest:(RouteRequest *)request error:(NSError *)error;
// 根据request获取目标控制器
- (RouteBaseController *)sourceViewControllerForTransitionWithRequest:(RouteRequest *)request;
//转场一定是从一个视图控制器跳转到另外一个视图控制器，该方法用以获取转场中的源视图控制器
- (RouteBaseController *)targetViewControllerWithRequest:(RouteRequest *)request;
//根据request来返回是否是模态跳转
- (BOOL)preferModalPresentationWithRequest:(RouteRequest *)request;
//方法内根据request、获取的目标和源视图控制器，完成转场逻辑
- (BOOL)transitionWithRequest:(RouteRequest *)request sourceViewController:(UIViewController *)source targetViewController:(UIViewController *)target isPreferModal:(BOOL)isPreferModal error:(NSError *)error;

@end
