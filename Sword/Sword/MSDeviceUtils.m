//
//  MSDeviceUtils.m
//  Sword
//
//  Created by haorenjie on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSDeviceUtils.h"

#import <UIKit/UIDevice.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "UIDevice+Add.h"

@implementation MSDeviceUtils

+ (NSString *)getUUID
{
    NSUUID *uuid = [UIDevice currentDevice].identifierForVendor;
    return [uuid UUIDString];
}

+ (NSString *)systemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)model
{
    return [UIDevice currentDevice].model;
}

+ (BOOL)isRoot
{
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"];
}

+ (NetworkType)currentNetwork
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [@"www.baidu.com" UTF8String]);

    NetworkType netType = NETWORK_NONE;
    do {
        SCNetworkReachabilityFlags flags;
        if (!SCNetworkReachabilityGetFlags(reachability, &flags)) {
            break;
        }

        if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
            break;
        }

        if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
            netType = NETWORK_WIFI;
            break;
        }

        if (flags & kSCNetworkReachabilityFlagsIsDirect) {
            netType = NETWORK_WIFI;
        }

        if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand
            || flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) {
            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
                netType = NETWORK_WIFI;
            }
        }

        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != kSCNetworkReachabilityFlagsIsWWAN) {
            break;
        }

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;

            if (currentRadioAccessTechnology) {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                    netType = NETWORK_4G;
                } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                    netType = NETWORK_2G;
                } else {
                    netType = NETWORK_3G;
                }
            }
        } else {
            if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable) {
                if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
                    if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                        netType = NETWORK_2G;
                    } else {
                        netType = NETWORK_3G;
                    }
                }
            }
        }
    } while (false);

    CFRelease(reachability);

    return netType;
}

+ (OperatorType)currentOperator
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];

    if ([carrier.carrierName isEqualToString:NSLocalizedString(@"str_op_cmcc", nil)]) {
        return OP_TYPE_CMCC;
    }

    if ([carrier.carrierName isEqualToString:NSLocalizedString(@"str_op_cucc", nil)]) {
        return OP_TYPE_CUCC;
    }

    if ([carrier.carrierName isEqualToString:NSLocalizedString(@"str_op_ctcc", nil)]) {
        return OP_TYPE_CTCC;
    }

    if ([carrier.carrierName isEqualToString:@"(null)"]) {
        return OP_TYPE_NONE;
    }

    return OP_TYPE_UNKNOWN;
}
+ (NSString *)currentMachineName
{
    return [UIDevice currentDevice].machineModelName;
}
+ (NSString *)appVersion
{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

@end
