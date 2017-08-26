//
//  CurrentInfo.h
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentInfo : NSObject

typedef NS_ENUM(NSInteger, CurrentStatus) {
    STATUS_SALING = 1,   // 热销中
    STATUS_SALE_OUT = 2, // 已售罄
};

@property (strong, nonatomic) NSNumber *currentID; // 活期ID
@property (copy, nonatomic) NSString *title; // 活期标题
@property (strong, nonatomic) NSNumber *interestRate; // 活期利率
@property (copy, nonatomic) NSString *interestRateDescription; // 活期利率描述
@property (strong, nonatomic) NSDecimalNumber *startAmount; // 起投金额
@property (strong, nonatomic) NSDecimalNumber *inceaseAmount; // 递增金额
@property (strong, nonatomic) NSString *termUnit; // 期单位
@property (assign, nonatomic) CurrentStatus status; // 标的状态
@property (assign, nonatomic) NSUInteger supportedRedEnvelopeTypes; // 支持的红包类型

@end
