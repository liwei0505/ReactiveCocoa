//
//  RACService.m
//  RAClearn
//
//  Created by lee on 2017/10/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RACService.h"
#import "RACProtocol.h"

@interface RACService()
@property (strong, nonatomic) RACProtocol *protocol;
@end

@implementation RACService

+ (instancetype)instance {
    static RACService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RACService alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _protocol = [[RACProtocol alloc] init];
    }
    return self;
}

- (void)qurey {
    [_protocol protocol];
}

@end
