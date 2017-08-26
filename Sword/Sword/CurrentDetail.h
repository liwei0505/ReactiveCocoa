//
//  CurrentDetail.h
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentInfo.h"

@class CurrentProductInfo;
@class DayInterestRate;
@class CurrentProductItem;

@interface CurrentDetail : NSObject

@property (strong, nonatomic) CurrentInfo *baseInfo; // 活期信息
@property (strong, nonatomic) NSDecimalNumber *earningsPer10000; // 万份收益
@property (strong, nonatomic) NSNumber *maxDisplayInterestRate; // 最大可显示收益率
@property (strong, nonatomic) NSNumber *minDisplayInterestRate; // 最小可显示收益率
@property (assign, nonatomic) NSInteger intervalRateCount; // 收益率划分份数
@property (strong, nonatomic) NSArray<DayInterestRate *> *last7DaysInterestRates; // 近7日收益率列表 [DayInterestRate]
@property (copy, nonatomic) NSString *investRulesURL; // 活期申购规则链接
@property (copy, nonatomic) NSString *bannerURL; // 广告图链接
@property (strong, nonatomic) CurrentProductInfo *productInfo; // 产品信息

@end

@interface DayInterestRate : NSObject

@property (assign, nonatomic) double interestRate; // 当日年化收益率
@property (assign, nonatomic) long date; // 收益率日期

@end

@interface CurrentProductInfo : NSObject

@property (copy, nonatomic) NSString *productManager; // 产品管理人
@property (strong, nonatomic) NSArray<CurrentProductItem *> *items; // CurrentProductItem

@end

@interface CurrentProductItem : NSObject

@property (copy, nonatomic) NSString *name; // 名称
@property (assign, nonatomic) NSInteger order; // 次序
@property (copy, nonatomic) NSString *url; // 链接

@end

// end of file
