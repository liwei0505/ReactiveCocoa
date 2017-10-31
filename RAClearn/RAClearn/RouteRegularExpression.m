//
//  RouteRegularExpression.m
//  RAClearn
//
//  Created by lee on 2017/10/25.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RouteRegularExpression.h"

@implementation RouteRegularExpression

- (instancetype)initWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError * _Nullable __autoreleasing *)error {
    
}

//转换为标准的正则表达式和将：后面的key的名字保存到routerParamNamesArr当中
+ (RouteRegularExpression *)expressionWithPattern:(NSString *)pattern {
    return [RouteRegularExpression new];
}

//接受一个Url从而生成匹配结果的对象，匹配结果的对象里存储着路径参数信息和是否匹配的结果。
- (RouteMatchResult *)matchResultForString:(NSString *)string {
    return [RouteMatchResult new];
}

@end
