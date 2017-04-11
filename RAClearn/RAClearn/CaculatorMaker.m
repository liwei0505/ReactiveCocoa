//
//  CaculatorMaker.m
//  RAClearn
//
//  Created by lee on 17/2/20.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "CaculatorMaker.h"

@implementation CaculatorMaker


- (CaculatorMaker *(^)(int))add {

    return ^CaculatorMaker *(int value) {
    
        _result += value;
        return self;
    };
}

- (CaculatorMaker *(^)(int))sub {

    return ^CaculatorMaker *(int value) {
        _result -= value;
        return self;
    };
}

- (CaculatorMaker *(^)(int))muilt {

    return ^CaculatorMaker *(int value) {
        _result *= value;
        return self;
    };
}

- (CaculatorMaker *(^)(int))divide {

    return ^CaculatorMaker *(int value) {
        _result /= value;
        return self;
    };
}

@end
