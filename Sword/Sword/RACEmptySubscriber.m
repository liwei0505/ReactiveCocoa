//
//  RACEmptySubscriber.m
//  Sword
//
//  Created by haorenjie on 2017/3/22.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RACEmptySubscriber.h"

@implementation RACEmptySubscriber

+ (instancetype)empty {
    return [[RACEmptySubscriber alloc] init];
}

- (void)sendNext:(id)value {
    NSLog(@"Empty subscriber sendNext:%@", value);
}

- (void)sendError:(NSError *)error {
    NSLog(@"Empty subscriber sendError:%@", error);
}

- (void)sendCompleted {
    NSLog(@"Empty subscriber sendCompleted");
}

- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable {
    NSLog(@"Empty subscriber didSubscribeWithDisposable:%@", disposable);
}

@end
