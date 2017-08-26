//
//  MSMyPointList.h
//  mobip2p
//
//  Created by lee on 16/5/19.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PointRecord : NSObject

@property (copy, nonatomic) NSString *receivedDate; // 获取积分时间
@property (copy, nonatomic) NSString *pointName;    // 获取积分名称
@property (copy, nonatomic) NSString *status;       // 积分状态
@property (assign, nonatomic) int point;              // 积分额


@end
