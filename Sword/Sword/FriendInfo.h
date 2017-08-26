//
//  FriendInfo.h
//  mobip2p
//
//  Created by lee on 16/6/1.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendInfo : NSObject

@property (strong, nonatomic) NSNumber *userID;     // 用户ID
@property (copy, nonatomic) NSString *nickname;     // 昵称
@property (assign, nonatomic) double inviteReward;  // 邀请奖励
@property (assign, nonatomic) UInt64 registerDate; // 注册日期
@property (assign, nonatomic) NSInteger status;     // 用户状态
@property (assign, nonatomic) BOOL rewardValid;     // 是否生效
@property (assign, nonatomic) NSInteger way;        // 奖励类型
@property (assign, nonatomic) NSInteger redEnvelopeCount; // 奖励红包个数
@property (strong, nonatomic) NSDecimalNumber *totalReward; //邀请奖励

@end
