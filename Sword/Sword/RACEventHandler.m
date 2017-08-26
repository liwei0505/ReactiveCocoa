//
//  RACEventHandler.m
//  Sword
//
//  Created by haorenjie on 2017/3/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RACEventHandler.h"
#import <objc/runtime.h>

@interface RACEventHandler()

@property (strong, nonatomic) RACSubject *broadcaster;
@property (strong, nonatomic) NSMutableDictionary *publishers;

@end

@implementation RACEventHandler

- (instancetype)init {
    if (self = [super init]) {
        _broadcaster = [RACSubject subject];
        _publishers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (instancetype)getInstance {
    static RACEventHandler *sInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[RACEventHandler alloc] init];
    });

    return sInstance;
}

+ (void)broadcast:(id)event {
    [[RACEventHandler getInstance].broadcaster sendNext:event];
}

+ (RACSignal *)observe:(Class)classType {
    return [[RACEventHandler getInstance].broadcaster filter:^BOOL(id value) {
        return [value isKindOfClass:classType];
    }];
}

+ (void)publish:(id)subject {
    NSString *key = [NSString stringWithUTF8String:object_getClassName(subject)];
    RACBehaviorSubject *publisher = [[RACEventHandler getInstance].publishers objectForKey:key];
    if (!publisher) {
        publisher = [RACBehaviorSubject subject];
        [[RACEventHandler getInstance].publishers setObject:publisher forKey:key];
    }
    [publisher sendNext:subject];
}

+ (RACSignal *)subscribe:(Class)classType {
    NSString *key = [NSString stringWithUTF8String:class_getName(classType)];
    RACBehaviorSubject *publisher = [[RACEventHandler getInstance].publishers objectForKey:key];
    if (!publisher) {
        publisher = [RACBehaviorSubject subject];
        [[RACEventHandler getInstance].publishers setObject:publisher forKey:key];
    }
    return [publisher filter:^BOOL(id value) {
        return [value isKindOfClass:classType];
    }];
}

@end
