//
//  MJSStatisticsImpl.h
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMJSStatisticsProtocol.h"

@interface MJSStatisticsImpl : NSObject

@property (strong, nonatomic) id<IMJSStatisticsProtocol> protocol;
@property (copy, nonatomic) NSString *userID;

+ (MJSStatisticsImpl *)getInstance;
- (void)sendAppInfo;
- (void)sendEvent:(MSStatsEvent *)event;

@end
