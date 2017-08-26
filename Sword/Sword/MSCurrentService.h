//
//  MSCurrentService.h
//  Sword
//
//  Created by haorenjie on 2017/3/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMJSProtocol.h"

@class CurrentDetail;

@interface MSCurrentCache : NSObject

@property (strong, nonatomic) MSListWrapper *recommendedList; // 推荐列表
@property (strong, nonatomic) MSListWrapper *currentList; // 活期列表
@property (strong, nonatomic) NSMutableDictionary *currentDict; // 活期标的详情字典
@property (strong, nonatomic) NSMutableDictionary *earningsHistoryDict;// 累计收益字典
@property (strong, nonatomic) NSMutableDictionary *purchaseConfigDict; // 申购配置字典
@property (strong, nonatomic) NSMutableDictionary *redeemConfigDict;   // 赎回配置字典

@end

@interface MSCurrentService : NSObject

@property (strong, nonatomic) MSCurrentCache *cache;

- (instancetype)initWithProtocol:(id<IMJSProtocol>)protocol;

- (CurrentDetail *)getCurrent:(NSNumber *)currentID;

- (RACSignal *)queryCurrentListByType:(ListRequestType)type isRecommended:(BOOL)isRecommended;
- (RACSignal *)queryCurrentDetail:(NSNumber *)currentID;
- (RACSignal *)queryCurrentEarningsHistoryByType:(ListRequestType)type WithID:(NSNumber *)currentID;
- (RACSignal *)queryCurrentPurchaseConfig:(NSNumber *)currentID;
- (RACSignal *)queryCurrentRedeemConfig:(NSNumber *)currentID;

@end
