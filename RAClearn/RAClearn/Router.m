//
//  Router.m
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "Router.h"
@interface Router ()
//每一个URL的匹配表达式对应一个matcher实例，放在字典中
@property(nonatomic,strong)NSMutableDictionary *routeMatchers;
//每一个URL匹配表达式route对应一个WLRRouteHandler实例
@property(nonatomic,strong)NSMutableDictionary *routeHandles;
//每一个URL匹配表达式route对应一个回调的block
@property(nonatomic,strong)NSMutableDictionary *routeblocks;

@end

@implementation Router

- (void)registerBlock:(RouteRequest *(^)(RouteRequest *))routeHandlerBlock forRoute:(NSString *)route {
    if (routeHandlerBlock && [route length]) {
        //首先添加一个WLRRouteMatcher实例
        [self.routeMatchers setObject:[RouteMatcher matcherWithRouteExpression:route] forKey:route];
        //删除route对应的handler对象(防止两个初始化方法冲突)
        [self.routeHandles removeObjectForKey:route];
        //将routeHandlerBlock和route存入对应关系的字典中
        self.routeblocks[route] = routeHandlerBlock;
    }
}

- (void)registerHandler:(RouteHandler *)handler forRoute:(NSString *)route {
    if (handler && route.length) {
        //首先生成route对应的WLRRouteMatcher实例
        [self.routeMatchers setObject:[RouteMatcher matcherWithRouteExpression:route] forKey:route];
        //删除route对应的block回调(防止两个初始化方法冲突)
        [self.routeblocks removeObjectForKey:route];
        //设置route对应的handler
        self.routeHandles[route] = handler;
    }
}

- (BOOL)handleURL:(NSURL *)url primitiveParam:(NSDictionary *)primitiveParam targetCallBack:(void (^)(NSError *, id))targetCallBack withCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    if (!url) {
        return NO;
    }
    NSError *error;
    RouteRequest *request;
    __block BOOL isHandled = NO;
    //遍历routeMatchers中的WLRRouteMatcher对象，将URL传入对象，看是否能得到WLRRouteRequest对象
    for (NSString *route in self.routeMatchers.allKeys) {
        RouteMatcher *matcher = [self.routeMatchers objectForKey:route];
        RouteRequest *request = [matcher createRequestWithURL:url primitiveParam:primitiveParam targetCallBack:targetCallBack];
        if (request) {
            //如果得到WLRRouteRequest对象，说明匹配成功，则进行handler的生命周期函数调用或是这block回调
            isHandled = [self handleRouteExpression:route withRequest:request error:&error];
        }
    }
    if (!request) {
        error = [[NSError alloc] init];
//        error = @"not found";
    }
    //在调用完毕block或者是handler的生命周期方法以后，回调完成的completionHandler
    [self completeRouteWithSuccess:isHandled error:error completionHandler:completionBlock];
    return isHandled;
}

/*
 * 此处增加了__autorelease关键字，将指针对象自动入池，这个过程会对指针地址做一些处理，导致拷贝的地址会有偏移），会保留这个指针的地址并在方法内部恢复指针，同时新建NSError实例并取地址给这个指针
 */

//根据request进行handler的生命周期函数调用或者是block回调
- (BOOL)handleRouteExpression:(NSString *)routeExpression withRequest:(RouteRequest *)request error:(NSError *__autoreleasing *)error {
    id handler = [self.routeHandles objectForKey:routeExpression];
    handler = handler ? handler : [self.routeblocks objectForKey:routeExpression];
    if (!handler) {
        return NO;
    }
    if ([handler isKindOfClass:NSClassFromString(@"NSBlock")]) {
        //拿到route对应的block并调用
        RouteRequest *(^block)(RouteRequest *) = handler;
        RouteRequest *backRequest = block(request);
        if (backRequest.isConsumed == NO) {
            if (backRequest.targetCallBack) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    backRequest.targetCallBack(nil, nil);
                });
            }
        }
        return YES;
    } else if ([handler isKindOfClass:[RouteHandler class]]) {
        //拿到url对应的handler对象后，先调用handler的shouldHandleWithRequest方法，如果返回YES，则调用进行转场的transitionWithRequest方法
        RouteHandler *rHandler = (RouteHandler *)handler;
        if (![rHandler shouldHandleWithRequest:request]) {
            return NO;
        }
        return [rHandler transitionWithRequest:request error:error];
    }
    return YES;
}

- (void)completeRouteWithSuccess:(BOOL)isHandled error:(NSError *)error completionHandler:(void(^)(BOOL handled, NSError *error))completionBlock {
    
}

@end
