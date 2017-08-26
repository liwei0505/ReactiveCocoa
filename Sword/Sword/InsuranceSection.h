//
//  InsuranceSection.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceSection : NSObject

// 分类名称
@property (copy, nonatomic) NSString *sectionName;
// 分类顺序
@property (assign, nonatomic) NSUInteger order;
// 保险列表
@property (strong, nonatomic) NSMutableArray<InsuranceInfo*> *insuranceList;

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj;

@end
