//
//  RACEventHandler.h
//  Sword
//
//  Created by haorenjie on 2017/3/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACEventHandler : NSObject

+ (void)broadcast:(id) event;
+ (RACSignal *)observe:(Class)classType;

+ (void)publish:(id)subject;
+ (RACSignal *)subscribe:(Class)classType;

@end
