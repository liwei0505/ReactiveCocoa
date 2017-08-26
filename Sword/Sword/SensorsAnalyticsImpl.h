//
//  SensorsAnalyticsImpl.h
//  Sword
//
//  Created by lee on 16/11/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

/**
 SensorsAnalyticsSDK.m中 1095 @"lib": libProperties 此属性去掉
 SensorsAnalyticsSDK.m中 1409 [self libVersion] 替换成 @"1.0.0"
 */

#import <Foundation/Foundation.h>
#import "MSPageParams.h"
#import "MSEventParams.h"

@interface SensorsAnalyticsImpl : NSObject

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *sessionID;

+ (SensorsAnalyticsImpl *)getInstance;
- (void)sendEventParams:(MSEventParams *)params;
- (void)sendPageParams:(MSPageParams *)params;
- (void)sendEventName:(NSString *)name params:(NSDictionary *)params;

@end
