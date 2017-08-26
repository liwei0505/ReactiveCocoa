//
//  MSTemporaryCache.m
//  Sword
//
//  Created by msj on 2017/3/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSTemporaryCache.h"
#import "MSSettings.h"
#define TEMPORARY_BIND_BANDCARDINFO                   @"temporary_bind_bandCardInfo"
#define TEMPORARY_RESET_TRADEPASSWORDINFO             @"temporary_reset_tradePasswordInfo"
#define TEMPORARY_RESET_LOGINPASSWORDINFO             @"temporary_reset_loginPasswordInfo"
#define TEMPORARY_REGISTERINFO                        @"temporary_registerInfo"
#define TEMPORARY_UERICON                             @"temporary_userIcon"

@implementation MSTemporaryCache
+ (void)saveTemporaryBindBandCardInfo:(NSMutableDictionary *)dic {
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"saveTemporaryBindBandCardInfo failed, userId is not found!"];
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_BIND_BANDCARDINFO, userId];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *)getTemporaryBindBandCardInfo{
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"getTemporaryBindBandCardInfo failed, userId is not found!"];
        return nil;
    }

    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_BIND_BANDCARDINFO, userId];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)clearTemporaryBindBandCardInfo {
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"clearTemporaryBindBandCardInfo failed, userId is not found!"];
        return;
    }

    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_BIND_BANDCARDINFO, userId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveTemporaryResetTradePasswordInfo:(NSMutableDictionary *)dic{
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"saveTemporaryResetTradePasswordInfo failed, userId is not found!"];
        return;
    }

    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_RESET_TRADEPASSWORDINFO, userId];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *)getTemporaryResetTradePasswordInfo{
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"getTemporaryResetTradePasswordInfo failed, userId is not found!"];
        return nil;
    }

    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_RESET_TRADEPASSWORDINFO, userId];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)clearTemporaryResetTradePasswordInfo {
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"clearTemporaryResetTradePasswordInfo failed, userId is not found!"];
        return;
    }

    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_RESET_TRADEPASSWORDINFO, userId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveTemporaryResetLoginPasswordInfo:(NSMutableDictionary *)dic{
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:TEMPORARY_RESET_LOGINPASSWORDINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *)getTemporaryResetLoginPasswordInfo{
    return [[NSUserDefaults standardUserDefaults] objectForKey:TEMPORARY_RESET_LOGINPASSWORDINFO];
}

+ (void)clearTemporaryResetLoginPasswordInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TEMPORARY_RESET_LOGINPASSWORDINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveTemporaryRegisterInfo:(NSMutableDictionary *)dic {
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:TEMPORARY_REGISTERINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *)getTemporaryRegisterInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:TEMPORARY_REGISTERINFO];
}

+ (void)clearTemporaryRegisterInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TEMPORARY_REGISTERINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveTemporaryUserIcon:(NSString *)userIcon {
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"saveTemporaryUserIcon failed, userId is not found!"];
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_UERICON, userId];
    [[NSUserDefaults standardUserDefaults] setObject:userIcon forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getTemporaryUserIcon {
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"saveTemporaryUserIcon failed, userId is not found!"];
        return nil;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_UERICON, userId];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)clearTemporaryUserIcon {
    NSNumber *userId = [MSSettings getLastLoginInfo].userId;
    if (!userId) {
        [MSLog warning:@"saveTemporaryUserIcon failed, userId is not found!"];
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", TEMPORARY_UERICON, userId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
