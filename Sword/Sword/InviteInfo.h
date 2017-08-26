//
//  InviteInfo.h
//  mobip2p
//
//  Created by lee on 16/6/1.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InviteInfo : NSObject

@property (assign, nonatomic) int inviteCount;       //邀请人数
@property (assign, nonatomic) double inviteReward;   //邀请获得的奖励
@property (copy, nonatomic) NSString *inviteBanner;  //邀请页头部banner
@property (copy, nonatomic) NSString *inviteTitle;   //邀请页title
@property (copy, nonatomic) NSString *inviteContent; //邀请页content
@property (copy, nonatomic) NSString *bannerLink;    //h5

@end
