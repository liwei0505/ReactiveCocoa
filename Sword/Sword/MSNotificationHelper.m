//
//  MSNotificationHelper.m
//  Sword
//
//  Created by haorenjie on 16/5/31.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSNotificationHelper.h"

@implementation MSNotificationHelper

+ (void)notify:(NSString *)name result:(id)result
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:result];
}

+ (void)notify:(NSString *)name result:(id)result userInfo:(NSDictionary *)params
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:result userInfo:params];
}

+ (void)addObserver:(id)observer selector:(SEL)sel name:(NSString *)name
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:sel name:name object:nil];
}

+ (void)addObserver:(id)observer selector:(SEL)sel name:(NSString *)name object:(id)anObject
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:sel name:name object:anObject];
}

+ (void)removeObserver:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

+ (void)removeObserver:(id)observer name:(NSString *)name
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
}

@end
