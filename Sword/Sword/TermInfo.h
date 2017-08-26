//
//  TermInfo.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TermInfo : NSObject

typedef NS_ENUM(NSUInteger, TermUnitType) {
    TERM_UNIT_DAY = 1,
    TERM_UNIT_MONTH = 2,
    TERM_UNIT_YEAR = 3,
    TERM_UNIT_TERM = 4,
};

@property (assign, nonatomic) int termCount;        // 还款期限数量（期数）
@property (assign, nonatomic) TermUnitType unitType;// 期单位
@property (assign, nonatomic) int monthPerTerm;     // 每期月数
@property (assign, nonatomic) int yearRadix;        // 年度天数基线
@property (copy, nonatomic) NSString *term;         // 还款期限

- (void)merge:(TermInfo *)termInfo;
- (int)getTermCount;

@end
