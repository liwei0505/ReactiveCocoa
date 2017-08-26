//
//  CurrentEarnings.h
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentEarnings : NSObject

@property (assign, nonatomic) long date; // 收益日期
@property (strong, nonatomic) NSDecimalNumber *amount; // 收益金额

@end
