//
//  MSOperatingService.h
//  Sword
//
//  Created by haorenjie on 2017/2/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSOperatingService.h"
#import "IMJSProtocol.h"

@class RiskResultInfo,SystemConfigs;

#pragma mark - MSOperatingCache
@interface MSOperatingCache : NSObject
- (void)clear;

@property (strong, nonatomic) SystemConfigs *systemConfigs;
@property (strong, nonatomic) UpdateInfo *updateInfo;
@property (strong, nonatomic) RiskResultInfo *resultInfo;

//商品列表相关cache
@property (strong, nonatomic, readonly) NSMutableArray *pointShopList;
@property (assign, nonatomic) BOOL hasMorePointGoods;
@property (assign, nonatomic) int totalPointGoods;
- (BOOL)hasMorePointGoods;

//message列表相关cache
@property (strong, nonatomic, readonly) NSMutableArray *messageList;
@property (strong, nonatomic) NSMutableDictionary *messageIdCache;//存储信息的messageid 用于去重
@property (assign, nonatomic) BOOL hasMoreMessage;
- (BOOL)hasMoreMessageList;

//关于我们，帮助中心，平台公告相关cache
@property (strong, nonatomic, readonly) NSMutableArray *helpList;
@property (assign, nonatomic) NSInteger totalHelpCount;
@property (assign, nonatomic) BOOL hasMoreHelpList;
- (BOOL)hasMoreHelpList;

@property (strong, nonatomic,readonly) NSMutableArray *noticeList;
@property (assign, nonatomic) NSInteger totalNoticeCount;
@property (assign, nonatomic) BOOL hasMoreNoticeList;
- (BOOL)hasMoreNoticeList;

@property (assign, nonatomic) int newNoticeId;

//bannerList
@property (strong, nonatomic) NSArray *bannerList;
@end

#pragma mark - MSOperatingService
@interface MSOperatingService : NSObject <IMSOperatingService>

@property (strong, nonatomic, readonly) MSOperatingCache *operatingCache;

- (instancetype)initWithProtocol:(id<IMJSProtocol>) protocol;

@end
