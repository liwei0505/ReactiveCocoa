//
//  MSTemporaryCache.h
//  Sword
//
//  Created by msj on 2017/3/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSTemporaryCache : NSObject
+ (void)saveTemporaryBindBandCardInfo:(NSMutableDictionary *)dic;
+ (NSMutableDictionary *)getTemporaryBindBandCardInfo;
+ (void)clearTemporaryBindBandCardInfo;

+ (void)saveTemporaryResetTradePasswordInfo:(NSMutableDictionary *)dic;
+ (NSMutableDictionary *)getTemporaryResetTradePasswordInfo;
+ (void)clearTemporaryResetTradePasswordInfo;

+ (void)saveTemporaryResetLoginPasswordInfo:(NSMutableDictionary *)dic;
+ (NSMutableDictionary *)getTemporaryResetLoginPasswordInfo;
+ (void)clearTemporaryResetLoginPasswordInfo;

+ (void)saveTemporaryRegisterInfo:(NSMutableDictionary *)dic;
+ (NSMutableDictionary *)getTemporaryRegisterInfo;
+ (void)clearTemporaryRegisterInfo;

+ (void)saveTemporaryUserIcon:(NSString *)userIcon;
+ (NSString *)getTemporaryUserIcon;
+ (void)clearTemporaryUserIcon;
@end
