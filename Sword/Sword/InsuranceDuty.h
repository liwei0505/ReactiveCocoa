//
//  InsuranceDuty.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceDuty : NSObject

// 保险责任编号
@property (copy, nonatomic) NSString *dutyId;
// 标题
@property (copy, nonatomic) NSString *dutyTitle;
// 内容介绍
@property (copy, nonatomic) NSString *introduction;
// 保障金额
@property (strong, nonatomic) NSDecimalNumber *guaranteeAmount;
// 保障金额是否按天计算
@property (assign, nonatomic) BOOL dayFlag;
// 顺序号
@property (assign, nonatomic) NSUInteger order;

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj;

- (NSString *)getGuaranteeDesc;

@end
