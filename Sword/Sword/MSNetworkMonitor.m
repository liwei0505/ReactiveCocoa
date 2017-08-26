//
//  MSNetworkMonitor.m
//  Sword
//
//  Created by haorenjie on 2017/1/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNetworkMonitor.h"
#import "AFHTTPSessionManager.h"
#import "MSNetworkStatus.h"

@interface MSNetworkMonitor()
{
    AFNetworkReachabilityManager *_networkMonitor;
}

@end

@implementation MSNetworkMonitor

+ (instancetype)sharedInstance {
    static MSNetworkMonitor *sInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[MSNetworkMonitor alloc] init];
    });

    return sInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _networkMonitor = [AFNetworkReachabilityManager sharedManager];
    }
    return self;
}

- (void)startMonitor:(reachability_change_block_t)block {
    [_networkMonitor setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSInteger networkStatus = MSNetworkUnknown;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                networkStatus = MSNetworkNotReachable;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                networkStatus = MSNetworkReachableViaWWAN;
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                networkStatus = MSNetworkReachableViaWiFi;
                break;
            }
            default: break;
        }
        block(networkStatus);
    }];
    [_networkMonitor startMonitoring];
}

- (void)stopMonitor {
    [_networkMonitor stopMonitoring];
}

- (BOOL)isNetworkAvailable {
    return _networkMonitor.reachable;
}

@end
