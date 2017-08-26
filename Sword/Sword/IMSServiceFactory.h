//
//  IMSServiceFactory.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSUserService.h"
#import "IMSPayService.h"
#import "IMSOperatingService.h"

@protocol IMSServiceFactory <NSObject>

- (id<IMSUserService>)createUserService;
- (id<IMSPayService>)createPayService;
- (id<IMSOperatingService>)createOperatingService;
- (id)getExtensionFactory;

@end
