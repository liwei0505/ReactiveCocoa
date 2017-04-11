//
//  CaculatorMaker.h
//  RAClearn
//
//  Created by lee on 17/2/20.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaculatorMaker : NSObject


@property (assign, nonatomic) int result;

- (CaculatorMaker *(^)(int))add;
- (CaculatorMaker *(^)(int))sub;
- (CaculatorMaker *(^)(int))muilt;
- (CaculatorMaker *(^)(int))divide;

@end
