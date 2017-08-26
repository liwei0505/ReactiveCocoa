//
//  MJSServiceFactory.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSServiceFactory.h"
#import "MSFinanceService.h"
#import "MSCurrentService.h"
#import "MJSInsuranceService.h"
#import "IMJSProtocol.h"

@class ZKSessionManager;

@interface MJSServiceFactory : NSObject <IMSServiceFactory>

- (instancetype)initWithSessionManager:(ZKSessionManager *)sessionManager;
- (MSFinanceService *)createFinanceService; // 定期服务
- (MSCurrentService *)createCurrentService; // 活期服务
- (MJSInsuranceService *)createInsuranceService; // 保险服务

@end
