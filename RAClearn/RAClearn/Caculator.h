//
//  Caculator.h
//  RAClearn
//
//  Created by lee on 17/2/27.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

/*
 函数式编程思想：是把操作尽量写成一系列嵌套的函数或者方法调用
 函数式编程特点：每个方法必须有返回值（本身对象）,把函数或者Block当做参数,block参数（需要操作的值）block返回值（操作结果）
 
 */

#import <Foundation/Foundation.h>

@interface Caculator : NSObject

@property (assign, nonatomic) BOOL isEqule;

- (Caculator *)caculator:(int(^)(int a))caculator;
- (Caculator *)equle:(BOOL(^)(int b))operation;

@end
