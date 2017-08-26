//
//  MSInvestRecordInfo.h
//  mobip2p
//
//  Created by lee on 16/5/17.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvestRecord : NSObject

@property (assign, nonatomic) int inverstorId;          // 投资人ID
@property (copy, nonatomic) NSString *investor;         // 投资人
@property (copy, nonatomic) NSString *createDateTime;   // 投资时间
@property (copy, nonatomic) NSString *amount;           // 投资金额
@property (assign, nonatomic) int loadId;

@end
