//
//  BankInfo.h
//  Sword
//
//  Created by lee on 16/12/24.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BankInfo : NSObject

@property (nonatomic, copy) NSString *bankId;
@property (nonatomic, copy) NSString *bankName;
@property (nonatomic, copy) NSString *bankUrl;
@property (nonatomic, assign) double singleLimit;
@property (nonatomic, assign) double dayLimit;
@property (nonatomic, assign) double monthLimit;

@end
