//
//  RiskInfo.h
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"

@interface RiskDetailInfo : NSObject
@property (copy, nonatomic) NSString *answerId;
@property (copy, nonatomic) NSString *answer;
@property (assign, nonatomic) char order;

//自定义属性
@property (assign, nonatomic) BOOL isSelected;
@end

@interface RiskInfo : NSObject
@property (copy, nonatomic) NSString *questionId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *icon;
@property (strong, nonatomic) NSMutableArray *riskDetailInfoArr;

//自定义属性
@property (assign, nonatomic)BOOL isCompeleted;
@property (copy, nonatomic) NSString *answerId;
@end

@interface RiskResultInfo : NSObject
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *icon;
@property (assign, nonatomic) RiskType type;
@property (copy, nonatomic) NSString *title;
@end
