//
//  MSUrlManager.h
//  mobip2p
//
//  Created by lee on 16/5/23.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"

//typedef NS_ENUM(NSInteger, HOST_TYPE) {
//    HOST_ZK,
//    HOST_TEST,
//    HOST_PERFORMANCE,
//    HOST_PREREALSE,
//    HOST_PRODUCT,
//};

@interface MSUrlManager : NSObject

+ (void)setHost:(HOST_TYPE)hostType;
+ (HOST_TYPE)getHost;
+ (NSString *)getBaseUrl;
+ (NSString *)getUpLoadUrl;
+ (NSString *)getWebSiteUrl:(NSString *)name;
+ (NSString *)getRegistUseTerms;
+ (NSString *)getRegistPrivacyTerms;
+ (NSString *)getFHOLPayUrl;
+ (NSString *)getImageUrlPrefix;

@end
