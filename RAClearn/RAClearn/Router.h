//
//  Router.h
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
/*
 * 路由实体对象
 * 可以完成对URL的拦截和处理并返回结果
 * 内部存在Machter对象和Handler对象一一对应的关系
 * 注册Url表达式对应到Handler的功能
 * 传入Url和参数就能匹配到Handler的功能
 * 检测Url是否能有对应Handler处理的功能
 */

#import <Foundation/Foundation.h>
#import "RouteRequest.h"
#import "RouteHandler.h"
#import "RouteMatcher.h"

@interface Router : NSObject

/**
 注册一个route表达式并与一个block处理相关联
 @param routeHandlerBlock block用以处理匹配route表达式的url的请求
 @param route url的路由表达式，支持正则表达式的分组，例如app://login/:phone({0,9+})是一个表达式，:phone代表该路径值对应的key,可以在RouteRequest对象中的routeParameters中获取
 */
- (void)registerBlock:(RouteRequest *(^)(RouteRequest *request))routeHandlerBlock forRoute:(NSString *)route;
- (void)registerHandler:(RouteHandler *)handler forRoute:(NSString *)route;

/**
 检测url是否能够被处理，不包含中间件的检查
 @param url 请求的url
 @return 是否可以handle
 */
- (BOOL)canHandleWithURL:(NSURL *)url;

/**
 *处理url请求
 *@param url 调用的url
 @param primitiveParam 携带的原生对象
 @param targetCallBack 传给目标对象的回调block
 @param completionBlock 完成路由中转的block
 @return 是否能够handle
 */
- (BOOL)handleURL:(NSURL *)url primitiveParam:(NSDictionary *)primitiveParam targetCallBack:(void(^)(NSError *error,id response))targetCallBack withCompletionBlock:(void(^)(BOOL handled, NSError *error))completionBlock;
@end
