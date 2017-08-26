//
//  MSStatsEvent.h
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSStatsEvent : NSObject

@property (copy, nonatomic) NSString *sessId;
@property (copy, nonatomic) NSString *userId;
@property (assign, nonatomic) int pageId;
@property (assign, nonatomic) int eventId;
@property (assign, nonatomic) int controlId;
@property (assign, nonatomic) UInt64  timestamp ;
@property (strong, nonatomic) NSDictionary *param;

- (NSDictionary *)toDictionary;
- (NSString *)toString;

@end
