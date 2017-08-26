//
//  MSNotificationHelper.h
//  Sword
//
//  Created by haorenjie on 16/5/31.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSNotificationHelper : NSObject

+ (void)notify:(NSString *)name result:(id)result;
+ (void)notify:(NSString *)name result:(id)result userInfo:(NSDictionary *)params;
+ (void)addObserver:(id)observer selector:(SEL)sel name:(NSString *)name;
+ (void)addObserver:(id)observer selector:(SEL)sel name:(NSString *)name object:(id)anObject;
+ (void)removeObserver:(id)observer;
+ (void)removeObserver:(id)observer name:(NSString *)name;

@end
