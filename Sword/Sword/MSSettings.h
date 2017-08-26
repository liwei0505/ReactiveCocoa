//
//  MSSettings.h
//  Sword
//
//  Created by haorenjie on 16/7/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSUserLocalConfig.h"

@interface MSSettings : NSObject

+ (NSTimeInterval)appActiveTime;

//patternLock settings
+ (BOOL)shouldShowPatternLockView:(NSNumber *)userId;
+ (BOOL)shouldShowPatternLockSettingView:(NSNumber *)userId;
+ (void)switchPatternLock:(BOOL)open userId:(NSNumber *)userId;
+ (void)handleEnterBackground;
+ (BOOL)isEnterBackgroundTimein;
+ (void)clearCurrentLoginUserId;
+ (void)clearUserPassword;

+ (void)saveLastLoginInfo:(MSLoginInfo *)loginInfo;
+ (MSLoginInfo *)getLastLoginInfo;

+ (MSUserLocalConfig *)getLocalConfig:(NSNumber *)userId;
+ (void)saveLocalConfig:(MSUserLocalConfig *)localConfig;

//red point in more storyboard
+ (void)saveNoticeId:(int)noticeId;
+ (int)getNoticeId;

+ (void)setOldUserHintStatus:(BOOL)status userId:(int)uId;
+ (BOOL)getOldUserHintStatus:(int)uId;

// first time open app
+ (BOOL)isFirstVisit;

@end
