//
//  MSSettings.m
//  Sword
//
//  Created by haorenjie on 16/7/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSSettings.h"
#import "MSLog.h"
#import "MSTextUtils.h"

NSString * const KEY_LAST_LOGIN_USERNAME = @"key_last_login_username";
NSString * const KEY_USER_PHONENUMBER = @"key_user_phonenumber";
NSString * const KEY_NOTICE_ID = @"key_notice_id";
NSString * const KEY_LAST_LOGIN_UID = @"k_last_uid";
NSString * const KEY_FIRST_VISIT = @"key_first_visit";

static NSTimeInterval _lastEnterBackgroundTime;
static NSTimeInterval _lastEnterForegroundTime;

@implementation MSSettings

+ (NSTimeInterval)appActiveTime {
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    return now - _lastEnterForegroundTime;
}

+ (BOOL)shouldShowPatternLockSettingView:(NSNumber *)userId {

    MSUserLocalConfig *config = [self getLocalConfig:userId];
    [self saveLocalConfig:config];
    return config.switchStatus && !config.patternLock;

}

+ (BOOL)shouldShowPatternLockView:(NSNumber *)userId {
    
    MSUserLocalConfig *config = [self getLocalConfig:userId];
    MSLoginInfo *info = [self getLoginInfo:userId];
    return [self isEnterBackgroundTimein]? NO : config.switchStatus && (config.patternLock.length >= PATTERNLOCK_PASSWORD_LENGTH) && info.password;

}

+ (BOOL)isEnterBackgroundTimein {
    
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    return now - _lastEnterBackgroundTime < 300.f;
}

+ (void)handleEnterBackground {
    _lastEnterBackgroundTime = [[NSDate date] timeIntervalSince1970];
}

+ (void)switchPatternLock:(BOOL)open userId:(NSNumber *)userId {
    
    MSUserLocalConfig *config = [self getLocalConfig:userId];
    if (!userId || !config) {
        return;
    }
    
    config.switchStatus = open;
    [self saveLocalConfig:config];
}

+ (void)clearCurrentLoginUserId {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:KEY_LAST_LOGIN_UID];
    NSString *userName = [settings objectForKey:KEY_LAST_LOGIN_USERNAME];
    if (userName) {
        [settings removeObjectForKey:KEY_LAST_LOGIN_USERNAME];
        [settings removeObjectForKey:KEY_USER_PHONENUMBER];
        [settings removeObjectForKey:userName];
    }
}

+ (void)clearUserPassword {

    MSLoginInfo *info = [self getLastLoginInfo];
    info.password = nil;
    [self saveLastLoginInfo:info];
}

#pragma mark - login info

+ (void)saveLastLoginInfo:(MSLoginInfo *)loginInfo {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:loginInfo.userId forKey:KEY_LAST_LOGIN_UID];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:loginInfo];
    NSString *key = [NSString stringWithFormat:@"k_%@", loginInfo.userId];
    [settings setObject:data forKey:key];
}

+ (MSLoginInfo *)getLastLoginInfo {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSNumber *uid = [settings objectForKey:KEY_LAST_LOGIN_UID];
    MSLoginInfo *loginInfo = nil;
    if (!uid) {
        NSString *userName = [settings objectForKey:KEY_LAST_LOGIN_USERNAME];
        NSString *phoneNumber = [settings objectForKey:KEY_USER_PHONENUMBER];
        if (!phoneNumber && userName) {
            phoneNumber = [settings objectForKey:userName];
        }

        NSString *password = nil;
        if (![MSTextUtils isEmpty:phoneNumber]) {
            NSString *key = [NSString stringWithFormat:@"PASSWORD_%@", phoneNumber];
            password = [settings objectForKey:key];
        }

        if (![MSTextUtils isEmpty:userName] && ![MSTextUtils isEmpty:password]) {
            loginInfo = [[MSLoginInfo alloc] init];
            loginInfo.userName = userName;
            loginInfo.password = password;
        }
    } else {
        loginInfo = [MSSettings getLoginInfo:uid];
    }

    return loginInfo;
}

#pragma mark - user local config info

+ (void)saveLocalConfig:(MSUserLocalConfig *)localConfig {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:localConfig];
    //local config info key :c_userid
    NSString *key = [NSString stringWithFormat:@"c_%@", localConfig.userId];
    [settings setObject:data forKey:key];
}

+ (MSUserLocalConfig *)getLocalConfig:(NSNumber *)userId {
    
    if (!userId) {
        return nil;
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"c_%@", userId];
    NSData *data = [settings objectForKey:key];
    MSUserLocalConfig *localConfig = (data && [data isKindOfClass:[NSData class]]) ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    if (localConfig) {
        return localConfig;
    }

    NSString *phoneNumber = [settings objectForKey:KEY_USER_PHONENUMBER];
    if ([MSTextUtils isEmpty:phoneNumber]) {
        MSLoginInfo *loginInfo = [self getLoginInfo:userId];
        if (loginInfo && loginInfo.userName) {
            phoneNumber = [settings objectForKey:loginInfo.userName];
        }
    }

    localConfig = [[MSUserLocalConfig alloc] init];
    localConfig.userId = userId;
    if (![MSTextUtils isEmpty:phoneNumber]) {
        localConfig.phoneNumber = phoneNumber;
        localConfig.patternLock = [settings objectForKey:[NSString stringWithFormat:@"LOCK_%@", phoneNumber]];
        localConfig.switchStatus = [[settings objectForKey:[NSString stringWithFormat:@"STATUS_%@", phoneNumber]] boolValue];
    }
    
    return localConfig;
}

#pragma mark - noticeId

+ (void)saveNoticeId:(int)noticeId {
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:@(noticeId) forKey:KEY_NOTICE_ID];
    
}

+ (int)getNoticeId {
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [[settings objectForKey:KEY_NOTICE_ID] intValue];
}

#pragma mark - old user cash hint

+ (void)setOldUserHintStatus:(BOOL)status userId:(int)uId {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:[NSNumber numberWithBool:status] forKey:[NSString stringWithFormat:@"%d",uId]];
}

+ (BOOL)getOldUserHintStatus:(int)uId {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSNumber *oldUSerHasHint = [settings objectForKey:[NSString stringWithFormat:@"%d",uId]];
    if ([oldUSerHasHint isKindOfClass:[NSNumber class]]) {
        return oldUSerHasHint && [oldUSerHasHint boolValue];
    }
    return NO;
}

+ (BOOL)isFirstVisit {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    id value = [settings objectForKey:KEY_FIRST_VISIT];
    if (value) {
        return NO;
    }
    
    [settings setObject:@NO forKey:KEY_FIRST_VISIT];
    return YES;
    
}

#pragma mark - private

+ (MSLoginInfo *)getLoginInfo:(NSNumber *)userId {

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"k_%@", userId];
    NSData *data = [settings objectForKey:key];
    MSLoginInfo *loginInfo =
    (data && [data isKindOfClass:[NSData class]]) ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return loginInfo;
}

@end



