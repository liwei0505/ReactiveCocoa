   //
//  RedEnvelope.h
//  Sword
//
//  Created by lee on 16/6/2.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"

@interface RedEnvelope : NSObject

@property (copy, nonatomic) NSString *redId;        // 红包ID
@property (copy, nonatomic) NSString *name;         // 红包名称
@property (assign, nonatomic) double amount;        // 红包金额
@property (copy, nonatomic) NSString *receiveDate;  // 获得时间
@property (copy, nonatomic) NSString *beginDate;    // 生效时间
@property (copy, nonatomic) NSString *endDate;      // 过期时间
@property (assign, nonatomic) double requirement;   // 最小投资额
@property (copy, nonatomic) NSString *usageRange;   // 使用范围
@property (assign, nonatomic) RedEnvelopeType type;  // 红包类型 0 代金劵 1 加息卷 2 体验金
@property (copy, nonatomic) NSString *status;       // 红包状态

@end
