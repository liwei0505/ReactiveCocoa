//
//  MSPayService.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSPayService.h"
#import "IMJSProtocol.h"

#pragma mark - MSPayCache
@interface MSPayCache : NSObject
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *rechargeSeqNumber;
@end

#pragma mark - MSPayService
@interface MSPayService : NSObject <IMSPayService>
@property (strong, nonatomic, readonly) MSPayCache *payCache;

- (instancetype)initWithProtocol:(id<IMJSProtocol>) protocol;

@end
