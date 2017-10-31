//
//  RouteRegularExpression.h
//  RAClearn
//
//  Created by lee on 2017/10/25.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteMatchResult.h"

@interface RouteRegularExpression : NSRegularExpression
@property (strong, nonatomic) NSArray *routerParamNamesArr;

- (RouteMatchResult *)matchResultForString:(NSString *)string;
+ (RouteRegularExpression *)expressionWithPattern:(NSString *)pattern;
@end
