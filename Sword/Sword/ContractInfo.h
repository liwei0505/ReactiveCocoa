//
//  ContractInfo.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContractInfo : NSObject

@property (copy, nonatomic) NSString *contractName;
@property (copy, nonatomic) NSString *contractURL;
@property (assign, nonatomic) NSUInteger order;

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj;

@end
