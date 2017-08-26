//
//  MSMyPoints.h
//  mobip2p
//
//  Created by lee on 16/5/19.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPoint : NSObject

@property (assign, nonatomic) int totalPoints;      // 累计积分
@property (assign, nonatomic) int usedPoints;       // 可用积分
@property (assign, nonatomic) int freezePoints;     // 冻结积分
@property (assign, nonatomic) int expendPoints;     // 已消耗积分


@end
