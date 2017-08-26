//
//  MSNetworkStatus.h
//  Sword
//
//  Created by haorenjie on 16/5/31.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSNetworkReachabilityStatus) {
    MSNetworkUnknown = -1,
    MSNetworkNotReachable = 0,
    MSNetworkReachableViaWWAN = 1,
    MSNetworkReachableViaWiFi = 2,
};

// end of file