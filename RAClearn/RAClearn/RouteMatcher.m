//
//  RouteMatcher.m
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RouteMatcher.h"
#import "RouteRegularExpression.h"
#import "RouteMatchResult.h"

@interface RouteMatcher()
@property (copy, nonatomic) NSString *scheme;
@property (strong, nonatomic) RouteRegularExpression *regexMatcher;

@end

@implementation RouteMatcher

- (instancetype)initWithRouteExpression:(NSString *)routeExpression {
    if (![routeExpression length]) {
        return nil;
    }
    if (self = [super init]) {
        //将scheme与path部分分别取出
        NSArray *parts = [routeExpression componentsSeparatedByString:@"://"];
        _scheme = parts.count> 1 ? [parts firstObject] : nil;
        _routeExpressionPattern = [parts lastObject];
        //将path部分当做URL匹配表达式生成RegularExpression实例
        _regexMatcher = [RouteRegularExpression expressionWithPattern:_routeExpressionPattern];
    }
    return self;
}

- (RouteRequest *)createRequestWithURL:(NSURL *)url primitiveParam:(NSDictionary *)primitiveParam targetCallBack:(void (^)(NSError *, id))callBack {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",url.host,url.path];
    if (self.scheme.length && ![self.scheme isEqualToString:url.scheme]) {
        return nil;
    }
    //调用self.regexMatcher将URL传入，获取WLRMatchResult结果，看是否匹配
    RouteMatchResult *result = [self.regexMatcher matchResultForString:urlString];
    if (!result.match) {
        return nil;
    }
    //如果匹配，则将result.paramProperties路径参数传入，初始化一个WLRRouteRequest实例
    RouteRequest *request = [[RouteRequest alloc] initWithURL:url routeExpression:self.routeExpressionPattern routeParam:result.paramProperties primitiveParam:primitiveParam targetCallBack:callBack];
    return request;
}

@end
