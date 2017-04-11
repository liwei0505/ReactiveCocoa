//
//  Caculator.m
//  RAClearn
//
//  Created by lee on 17/2/27.
//  Copyright © 2017年 mjsfax. All rights reserved.


#import "Caculator.h"

@interface Caculator()

@property (assign, nonatomic) int result;

@end

@implementation Caculator

- (Caculator *)caculator:(int (^)(int a))caculator {
    self.result = caculator(0);
    return self;
}

- (Caculator *)equle:(BOOL (^)(int))operation {
    self.isEqule = operation(self.result);
    return self;
}

@end
