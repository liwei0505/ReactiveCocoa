//
//  NSObject+Caculator.m
//  RAClearn
//
//  Created by lee on 17/2/20.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "NSObject+Caculator.h"


@implementation NSObject (Caculator)

+ (int)makeCaculators:(void (^)(CaculatorMaker *))caculatorMaker {

    //创建计算管理者
    CaculatorMaker *make = [[CaculatorMaker alloc] init];
    caculatorMaker(make);
    return make.result;
    
}

@end
