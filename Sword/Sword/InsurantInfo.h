//
//  InsurantInfo.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsurantInfo : NSObject

// 被保人姓名
@property (copy, nonatomic) NSString *name;
// 与投保人关系
@property (assign, nonatomic) NSUInteger relationship;
// 证件类型
@property (assign, nonatomic) NSUInteger certificateType;
// 证件编号
@property (copy, nonatomic) NSString *certificateId;
// 联系方式
@property (copy, nonatomic) NSString *mobile;

- (NSDictionary *)toDictionary;

@end
