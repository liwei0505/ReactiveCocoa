//
//  MJSStatistics.h
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorsAnalyticsSDK.h"
#import "IMJSStatisticsProtocol.h"
#import "MSPageParams.h"
#import "MSEventParams.h"

@interface MJSStatistics : NSObject

typedef NS_ENUM(NSInteger, StatsEventType) {
    STATS_EVENT_VIEW_SHOW = 1,
    STATS_EVENT_VIEW_HIDE = 2,
    STATS_EVENT_TOUCH_DOWN = 3,
    STATS_EVENT_TOUCH_UP = 4,
    STATS_EVENT_KEY_DOWN = 5,
    STATS_EVENT_KEY_UP = 6,
};

+ (void)initialize:(id<IMJSStatisticsProtocol>)protocol;
+ (void)sendAppInfo;
+ (void)sendEvent:(int)eventType page:(int)pageID control:(int)controlID params:(NSDictionary *)params;

+ (void)regist;
+ (void)setUserID:(NSString *)userID;
+ (void)setSessionID:(NSString *)sessionID;
+ (void)sendEventParams:(MSEventParams *)params;
+ (void)sendPageParams:(MSPageParams *)params;
+ (void)sendEventName:(NSString *)name params:(NSDictionary *)params;


@end
