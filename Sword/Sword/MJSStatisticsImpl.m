//
//  MJSStatisticsImpl.m
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MJSStatisticsImpl.h"
#import "TimeUtils.h"
#import "MSDeviceUtils.h"
#import "MSLog.h"

@interface MJSStatisticsImpl()
{
    NSString *_sessionID;
}

@end

@implementation MJSStatisticsImpl

+ (MJSStatisticsImpl *)getInstance
{
    static MJSStatisticsImpl *sInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[MJSStatisticsImpl alloc] init];
    }); 

    return sInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _sessionID = [NSString stringWithFormat:@"%@#%llu", [MSDeviceUtils getUUID], [TimeUtils currentTimeMillis]];
    }
    return self;
}

- (void)sendAppInfo
{
    MSStatsAppInfo *appInfo = [MSStatsAppInfo new];
    appInfo.sessId = _sessionID;
    appInfo.uuid = [MSDeviceUtils getUUID];
    appInfo.model = [MSDeviceUtils currentMachineName];
    appInfo.osVer = [MSDeviceUtils systemVersion];
    appInfo.appVer = [MSDeviceUtils appVersion];
    appInfo.timestamp = [TimeUtils currentTimeMillis];
    appInfo.root = [MSDeviceUtils isRoot];
    appInfo.opType = [MSDeviceUtils currentOperator];
    appInfo.netType = [MSDeviceUtils currentNetwork];
    [self.protocol sendAppInfo:appInfo];
}

- (void)sendEvent:(MSStatsEvent *)event
{
    event.sessId = _sessionID;
    event.userId = self.userID;
    event.timestamp = [TimeUtils currentTimeMillis];
    [self.protocol sendStatsEvent:event];
}

- (NSString *)userID
{
    return _userID ? _userID : @"";
}

@end
