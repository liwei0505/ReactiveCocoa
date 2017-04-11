//
//  NSObject+Caculator.h
//  RAClearn
//
//  Created by lee on 17/2/20.
//  Copyright © 2017年 mjsfax. All rights reserved.
/*
    链式编程思想：是将多个操作（多行代码）通过点号(.)链接在一起成为一句代码,使代码可读性好。a(1).b(2).c(3)
    链式编程特点：方法的返回值是block,block必须有返回值（本身对象），block参数（需要操作的值）
*/

#import <Foundation/Foundation.h>
#import "CaculatorMaker.h"

@interface NSObject (Caculator)

+ (int)makeCaculators:(void(^)(CaculatorMaker *make))caculatorMaker;

@end
