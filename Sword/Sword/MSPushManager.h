//
//  MSPushManager.h
//  Sword
//
//  Created by haorenjie on 2017/3/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSPushManager : NSObject

+ (instancetype)getInstance;
- (void)registerDeviceToken:(NSData *)deviceToken;
- (void)start:(BOOL)distribution;
- (void)resume;
- (void)destroy;
- (void)handleRemoteNotification:(NSDictionary *)userInfo;
- (NSString *)getDeviceToken;

@end
