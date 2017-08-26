//
//  ZKProtocol.h
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IMJSProtocol.h"
#import "IMJSStatisticsProtocol.h"


@class MSHttpProxy;
@class ZKSessionManager;

@interface ZKProtocol : NSObject <IMJSProtocol, IMJSStatisticsProtocol>

- (instancetype)initWithSessionManager:(ZKSessionManager *)sessionManager;

@end
