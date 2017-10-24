//
//  RouteRequest.h
//  RAClearn
//
//  Created by lee on 2017/10/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteRequest : NSObject<NSCopying>

- (instancetype)initWithURL:(NSURL *)url routeExpression:(NSString *)routeExpression routeParam:(NSDictionary *)routeParam primitiveParam:(NSDictionary *)primitiveParam targetCallBack:(void(^)(NSError *error, id response))targetCallBack;
@end
