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
@property(nonatomic,strong)NSMutableDictionary * routeMatchers;
//每一个URL匹配表达式route对应一个WLRRouteHandler实例
@property(nonatomic,strong)NSMutableDictionary * routeHandles;
//每一个URL匹配表达式route对应一个回调的block
@property(nonatomic,strong)NSMutableDictionary * routeblocks;

@end

@implementation Router

@end
