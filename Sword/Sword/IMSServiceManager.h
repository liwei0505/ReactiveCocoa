//
//  IMSServiceManager.h
//  Sword
//
//  Created by haorenjie on 2017/2/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSServiceFactory.h"

@protocol IMSServiceManager <NSObject>

- (instancetype)initWithServiceFactory:(id<IMSServiceFactory>)serviceFactory;

@end
