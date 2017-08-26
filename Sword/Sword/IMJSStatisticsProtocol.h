//
//  IMJSStatisticsProtocol.h
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#ifndef IMJSStatisticsProtocol_h
#define IMJSStatisticsProtocol_h

#import <Foundation/Foundation.h>
#import "MSStatsAppInfo.h"
#import "MSStatsEvent.h"

@protocol IMJSStatisticsProtocol <NSObject>

- (void)sendAppInfo:(MSStatsAppInfo *)appInfo;
- (void)sendStatsEvent:(MSStatsEvent *)event;

@end

#endif /* IMJSStatisticsProtocol_h */
