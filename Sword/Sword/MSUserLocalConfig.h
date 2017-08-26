//
//  MSUserLocalConfig.h
//  Sword
//
//  Created by lee on 17/3/13.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSUserLocalConfig : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *userId;
@property (copy, nonatomic)   NSString *phoneNumber;
@property (copy, nonatomic)   NSString *patternLock;//手势密码
@property (assign, nonatomic) BOOL switchStatus;//手势开关
@property (assign, nonatomic) int patternLockErrorCount;


@end
