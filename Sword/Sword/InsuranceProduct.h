//
//  InsuranceProduct.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceProduct : NSObject

// 产品编号
@property (copy, nonatomic) NSString *productId;
// 产品名称
@property (copy, nonatomic) NSString *productName;
// 保费
@property (strong, nonatomic) NSDecimalNumber *premium;
// 顺序号
@property (assign, nonatomic) NSUInteger order;
// 保险责任列表
@property (strong, nonatomic) NSArray<InsuranceDuty *> *duties;

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj;

@end
