//
//  MSDeviceUtils.h
//  Sword
//
//  Created by haorenjie on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDeviceUtils : NSObject

typedef NS_ENUM(NSInteger, OperatorType) {
    OP_TYPE_NONE = 0,
    OP_TYPE_CMCC = 1,
    OP_TYPE_CUCC = 2,
    OP_TYPE_CTCC = 3,
    OP_TYPE_UNKNOWN = 4,
};

typedef NS_ENUM(NSInteger, NetworkType) {
    NETWORK_NONE = 0,
    NETWORK_WIFI = 1,
    NETWORK_2G = 2,
    NETWORK_3G = 3,
    NETWORK_4G = 4,
    NETWORK_UNKNOWN = 5,
};

+ (NSString *)getUUID;
+ (NSString *)systemVersion;
+ (NSString *)model;
+ (BOOL)isRoot;
+ (NetworkType)currentNetwork;
+ (OperatorType)currentOperator;
+ (NSString *)currentMachineName;
+ (NSString *)appVersion;

@end
