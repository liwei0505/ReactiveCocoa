//
//  RouteRequest.h
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteRequest : NSObject<NSCopying>
//外部调用的URL
@property (copy, nonatomic, readonly) NSURL *url;
//URL表达式，比方说调用登录界面的表达式可以为：AppScheme://user/login/138********，那URL的匹配表达式可以是：/login/:phone([0-9]+),路径必须以/login开头，后面接0-9的电话号码数字，当然你也可以直接把电话号码的正则匹配写全
@property(nonatomic,copy)NSString * routeExpression;
//是否消费掉，一个request只能处理一次，该字段反应request是否被处理过
@property (assign, nonatomic) BOOL isConsumed;
@property (copy, nonatomic) void(^targetCallBack)(NSError *error, id response);

- (instancetype)initWithURL:(NSURL *)url routeExpression:(NSString *)routeExpression routeParam:(NSDictionary *)routeParam primitiveParam:(NSDictionary *)primitiveParam targetCallBack:(void(^)(NSError *error, id response))targetCallBack;

@end
