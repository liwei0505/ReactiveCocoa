//
//  RouteMatchResult.h
//  RAClearn
//
//  Created by lee on 2017/10/25.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteMatchResult : NSObject
@property (assign, nonatomic) BOOL match;
@property (strong, nonatomic) NSDictionary *paramProperties;
@end
