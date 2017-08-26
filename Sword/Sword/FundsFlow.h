//
//  MSMyFundsFlow.h
//  mobip2p
//
//  Created by lee on 16/5/18.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"

@interface FundsFlow : NSObject

@property (assign, nonatomic) FlowType type;        // 流水类型
@property (copy, nonatomic) NSString *typeName;     // 流水类型名称
@property (copy, nonatomic) NSString *target;       // 流水目标
@property (copy, nonatomic) NSString *tradeDate;    // 交易时间
@property (assign, nonatomic) double tradeAmount;   // 交易金额


@end

