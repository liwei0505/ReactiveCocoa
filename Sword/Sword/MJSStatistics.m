//
//  MJSStatistics.m
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MJSStatistics.h"
#import "MJSStatisticsImpl.h"
#import "SensorsAnalyticsImpl.h"
#import "MSConfig.h"
#import "MSUrlManager.h"

/**
 SensorsAnalyticsSDK.m中 902 @"lib": libProperties 此属性去掉
 SensorsAnalyticsSDK.m中 1211 [self libVersion] 替换成 @"1.0.0"
*/

@implementation MJSStatistics

+ (void)initialize:(id<IMJSStatisticsProtocol>)protocol {
    [MJSStatisticsImpl getInstance].protocol = protocol;
    [self sendAppInfo];
}

+ (void)sendAppInfo {
    [[MJSStatisticsImpl getInstance] sendAppInfo];
}

+ (void)setUserID:(NSString *)userID {
    [MJSStatisticsImpl getInstance].userID = userID;
    
    [SensorsAnalyticsImpl getInstance].userID = userID;
    [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:@{@"userId":[SensorsAnalyticsImpl getInstance].userID}];
}

+ (void)regist {
  
    NSString *server;
    NSString *configure;
    if ([MSUrlManager getHost] == HOST_PRODUCT) {
        server = @"https://transactor.minshengjf.com:6109/transactor/mjsfax_app_ios/mtrack";//数据接收
        configure = @"https://transactor.minshengjf.com:6109/transactor/mjsfax_app_ios/app_config";//配置分发url
    } else if ([MSUrlManager getHost] == HOST_PREREALSE) {
        server = @"https://mjsytc.minshengjf.com:6507/transactor/mjsfax_app_ios/mtrack";
        configure = @"https://mjsytc.minshengjf.com:6507/transactor/mjsfax_app_ios/app_config";
    } else if ([MSUrlManager getHost] == HOST_TEST) {
        server = @"http://10.0.110.46:8080/transactor/mjsfax_app_ios/mtrack";
        configure = @"http://10.0.110.46:8080/transactor/mjsfax_app_ios/app_config";
    } else {
        [MSLog error:@"SensorsAnalyticsSDK config info error!"];
        return;
    }
    //SensorsAnalyticsDebugAndTrack   SensorsAnalyticsDebugOnly
    [SensorsAnalyticsSDK sharedInstanceWithServerURL:server andConfigureURL:configure andDebugMode:SensorsAnalyticsDebugOff];
    //[[SensorsAnalyticsSDK sharedInstance] enableAutoTrack];
    //设置事件公共属性
    [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:@{@"userId":[SensorsAnalyticsImpl getInstance].userID,@"channel":@"AppleStore",}];
}

+ (void)setSessionID:(NSString *)sessionID {
    [SensorsAnalyticsImpl getInstance].sessionID = sessionID;
}

+ (void)sendEventParams:(MSEventParams *)params {
    [[SensorsAnalyticsImpl getInstance] sendEventParams:params];
}

+ (void)sendPageParams:(MSPageParams *)params {
    [[SensorsAnalyticsImpl getInstance] sendPageParams:params];
}

+ (void)sendEventName:(NSString *)name params:(NSDictionary *)params {
    [[SensorsAnalyticsImpl getInstance] sendEventName:name params:params];
}

+ (void)sendEvent:(int)eventType page:(int)pageID control:(int)controlID params:(NSDictionary *)params {
    
    MSStatsEvent *event = [MSStatsEvent new];
    event.eventId = eventType;
    event.pageId = pageID;
    event.controlId = controlID;
    event.param = params;
    [[MJSStatisticsImpl getInstance] sendEvent:event];
    
}

@end
