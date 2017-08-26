//
//  MSNetworkMonitor.h
//  Sword
//
//  Created by haorenjie on 2017/1/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSNetworkMonitor : NSObject

typedef void(^reachability_change_block_t)(NSInteger status);

+ (instancetype)sharedInstance;
- (void)startMonitor:(reachability_change_block_t)block;
- (void)stopMonitor;
- (BOOL)isNetworkAvailable;

@end
