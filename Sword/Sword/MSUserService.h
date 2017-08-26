//
//  MSUserService.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSUserService.h"
#import "IMJSProtocol.h"
#import "MSLoginInfo.h"
#import "AccountInfo.h"
#import "AssetInfo.h"
#import "MSListWrapper.h"

@class AccountInfo, AssetInfo, MSListWrapper;
#pragma mark - MSUserCache
@interface MSUserCache : NSObject

@property (strong, nonatomic) MSLoginInfo *loginInfo;
@property (assign, nonatomic) MSLoginStatus loginStatus;
@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) AssetInfo *assetInfo;
@property (assign, nonatomic) BOOL isLogin;

//我的理财
@property (strong, nonatomic) NSMutableDictionary *investListDict;

//我的转让
@property (strong, nonatomic) NSMutableDictionary *debtListDict;

//资金流水
@property (strong, nonatomic) NSMutableArray *fundsFlowList;
@property (assign, nonatomic) BOOL hasMoreFundsFlow;
@property (assign, nonatomic) NSInteger totalFundsFlow;
- (BOOL)hasMoreFundsFlow;

//我的红包列表
@property (strong, nonatomic) NSMutableDictionary *redEnvelopeListDict;

//我的积分列表
@property (strong, nonatomic) NSMutableArray *myPointList;
@property (assign, nonatomic) BOOL hasMorePointList;
@property (assign, nonatomic) NSInteger totalPointList;
- (BOOL)hasMorePointList;

//好友
@property (strong, nonatomic) MSListWrapper *invitedFriendList;

- (void)clear;

@end

#pragma mark - MSUserService
@interface MSUserService : NSObject <IMSUserService>

@property (strong, nonatomic, readonly) MSUserCache *userCache;

- (instancetype)initWithProtocol:(id<IMJSProtocol>) protocol;

@end
