//
//  RouteMatcher.h
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteRequest.h"

@interface RouteMatcher : NSObject

//url匹配表达式
@property (copy, nonatomic) NSString *routeExpressionPattern;
//url匹配的正则表达式
@property (copy, nonatomic) NSString *originalRouteExpression;

//传入URL匹配的表达式，获取一个matcher实例
+ (instancetype)matcherWithRouteExpression:(NSString *)expression;

//传入URL，如果能匹配上，则生成WLRRouteRequest对象，同时将各种参数解析好交由RouteRequest携带
- (RouteRequest *)createRequestWithURL:(NSURL *)url primitiveParam:(NSDictionary *)primitiveParam targetCallBack:(void(^)(NSError *, id response))callBack;
@end
