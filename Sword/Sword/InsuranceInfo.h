//
//  InsuranceInfo.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceInfo : NSObject

// 保险编号
@property (copy, nonatomic) NSString *insuranceId;
// 保险标题
@property (copy, nonatomic) NSString *title;
// 图标链接
@property (copy, nonatomic) NSString *iconUrl;
// 保险标签列表
@property (strong, nonatomic) NSArray<NSString *> *tags;
// 起购金额
@property (strong, nonatomic) NSDecimalNumber *startAmount;
// 保险类型
@property (assign, nonatomic) NSUInteger type;
// 售出份数
@property (assign, nonatomic) NSUInteger soldCount;

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj;

@end
