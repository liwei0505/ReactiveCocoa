//
//  MSLoginInfo.h
//  Sword
//
//  Created by haorenjie on 2017/2/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSLoginInfo : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *userId;
@property (copy, nonatomic)   NSString *userName;
@property (copy, nonatomic)   NSString *password;
@property (assign, nonatomic) RiskType riskType;

@end
