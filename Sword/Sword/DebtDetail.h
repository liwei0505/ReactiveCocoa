//
//  MSDebtDetailInfo.h
//  mobip2p
//
//  Created by lw on 16/5/18.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DebtInfo.h"

@interface DebtDetail : NSObject

@property (strong, nonatomic) DebtInfo *baseInfo;
@property (assign, nonatomic) double payAmount;         // 认购金额（元）
@property (assign, nonatomic) double expectedRate;      // 债权的原期年化收益
@property (assign, nonatomic) double expectedEarning;   // 债权的预期收益
@property (copy, nonatomic) NSString *investType;       // 收益方式
@property (copy, nonatomic) NSString *releaseDate;      // 原项目发布时间
@property (copy, nonatomic) NSString *repayDate;        // 还款时间
@property (assign, nonatomic) long subscribeLeftTime;   // 认购剩余时间
@property (assign, nonatomic) long deadline;            // 认购截止时间

@property (assign, nonatomic) int investorUserId;      //转让标的人的UserId
@end
