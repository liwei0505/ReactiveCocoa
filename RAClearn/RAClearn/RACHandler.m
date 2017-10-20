//
//  RACHandler.m
//  RAClearn
//
//  Created by lee on 2017/10/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RACHandler.h"
#import <objc/runtime.h>

@interface RACHandler()
@property (strong, nonatomic) RACSubject *broadcaster;
@property (strong, nonatomic) NSMutableDictionary *publishers;
@end

@implementation RACHandler

- (instancetype)init {
    if (self = [super init]) {
        _broadcaster = [RACSubject subject];
        _publishers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (instancetype)instance {
    static RACHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RACHandler alloc] init];
    });
    return instance;
}

+ (void)broadcast:(id)event {
    [[RACHandler instance].broadcaster sendNext:event];
}

+ (RACSignal *)observe:(Class)classType {
    return [[RACHandler instance].broadcaster filter:^BOOL(id value) {
        return [value isKindOfClass:classType];
    }];
}

+ (void)publish:(id)subject {
    NSString *key = [NSString stringWithUTF8String:object_getClassName(subject)];
    RACBehaviorSubject *publisher = [[RACHandler instance].publishers objectForKey:key];
    if (!publisher) {
        publisher = [RACBehaviorSubject subject];
        [[RACHandler instance].publishers setObject:publisher forKey:key];
    }
    [publisher sendNext:subject];
}

+ (RACSignal *)subscribe:(Class)classType {
    NSString *key = [NSString stringWithUTF8String:class_getName(classType)];
    RACBehaviorSubject *publisher = [[RACHandler instance].publishers objectForKey:key];
    if (!publisher) {
        publisher = [RACBehaviorSubject subject];
        [[RACHandler instance].publishers setObject:publisher forKey:key];
    }
    return [publisher filter:^BOOL(id value) {
        return [value isKindOfClass:classType];
    }];
}

@end
