//
//  MSStatsAppInfo.h
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSStatsAppInfo : NSObject

@property (copy, nonatomic) NSString *sessId;
@property (copy, nonatomic) NSString *uuid;
@property (copy, nonatomic) NSString *model;
@property (copy, nonatomic) NSString *osVer;
@property (assign, nonatomic) BOOL root;
@property (copy, nonatomic) NSString *appVer;
@property (assign, nonatomic) UInt64 timestamp;
@property (assign, nonatomic) int netType;
@property (assign, nonatomic) int opType;

- (NSDictionary *)toDictionary;
- (NSString *)toString;

@end
