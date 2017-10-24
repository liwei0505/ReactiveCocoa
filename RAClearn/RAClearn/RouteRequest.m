//
//  RouteRequest.m
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
/*
 1 类直接继承自NSObject，无需调用[super copyWithZone:zone]
 2 父类实现了copy协议，子类也实现了copy协议，子类需要调用[super copyWithZone:zone]
 3 父类没有实现copy协议，子类实现了copy协议，子类无需调用[super copyWithZone:zone]
 4、copyWithZone方法中要调用[[[self class] alloc] init]来分配内存
 */

#import "RouteRequest.h"

@interface RouteRequest()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDictionary *queryParam;//url上？以后的键值对参数
@property (strong, nonatomic) NSDictionary *routeParam;//url上匹配的路径参数
@property (strong, nonatomic) NSDictionary *primitiveParam;//原生参数，比方说要传给目标UIImage对象，NSArray对象等等
@property (copy, nonatomic) void(^targetCallBack)(NSError *error, id response);
@property (assign, nonatomic) BOOL isConsumed;//是否消费掉，一个request只能处理一次，该字段反应request是否被处理过
@end

@implementation RouteRequest

- (id)copyWithZone:(NSZone *)zone {
    RouteRequest *request = [[[self class] allocWithZone:zone] init];
    request.url = self.url;
    request.queryParam = self.queryParam;
    request.routeParam = self.routeParam;
    request.primitiveParam = self.primitiveParam;
    //未公开的成员用 ->
    //request-> _a = _a;
    return request;
}

- (instancetype)initWithURL:(NSURL *)url routeExpression:(NSString *)routeExpression routeParam:(NSDictionary *)routeParam primitiveParam:(NSDictionary *)primitiveParam targetCallBack:(void (^)(NSError *, id))targetCallBack {
    if (!url) {
        return nil;
    }
    
    if (self = [super init]) {
        _url = url;
        _queryParam = [self parametersFromQueryString:[_url query]];
        _routeParam = routeParam;
        _primitiveParam = primitiveParam;
        self.targetCallBack = targetCallBack;
    }
    return self;
}

- (NSDictionary *)parametersFromQueryString:(NSString *)query {
    if (!query || !query.length) {
        return nil;
    }
    //query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];去掉左右空格
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *param = [[NSDictionary alloc] init];
    NSArray *paramArray = [query componentsSeparatedByString:@"$"];
    [paramArray enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *array = [string componentsSeparatedByString:@"="];
        [param setValue:[array lastObject] forKey:[array firstObject]];
    }];
    return param;
}

- (void)setTargetCallBack:(void (^)(NSError *, id))targetCallBack {
    __weak RouteRequest *weakRequest = self;
    if (!targetCallBack) {
        return;
    }
    self.isConsumed = NO;
    _targetCallBack = ^(NSError *error, id response) {
        weakRequest.isConsumed = YES;
        targetCallBack(error,response);
    };
}

//默认完成目标的回调:处理响应者没有触发回调，则需要有默认的回调给调用者
- (void)defaultFinishTargetCallBack{
    if (self.targetCallBack && self.isConsumed == NO) {
        self.targetCallBack(nil,@"正常执行回调");
    }
}


@end
