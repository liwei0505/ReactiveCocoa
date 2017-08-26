//
//  TermInfo.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "TermInfo.h"
#import "MSTextUtils.h"

@implementation TermInfo

- (instancetype)init {
    if (self = [super init]) {
        _yearRadix = 365;
        _unitType = TERM_UNIT_DAY;
    }
    return self;
}

- (NSString *)term {
    if (![MSTextUtils isEmpty:_term]) {
        return _term;
    }

    switch (self.unitType) {
        case TERM_UNIT_DAY:
            return NSLocalizedString(@"str_term_day", @"");
        case TERM_UNIT_MONTH:
            return NSLocalizedString(@"str_term_month", @"");
        case TERM_UNIT_YEAR:
            return NSLocalizedString(@"str_term_year", @"");
        default:
            return NSLocalizedString(@"str_term_term", @"");
    }
}

- (int)getTermCount {
    return (self.unitType == TERM_UNIT_DAY) ? _termCount : _termCount * self.monthPerTerm;
}

- (void)merge:(TermInfo *)termInfo {
    self.termCount = termInfo.termCount;
    self.unitType = termInfo.unitType;
    self.yearRadix = termInfo.yearRadix;
    self.monthPerTerm = termInfo.monthPerTerm;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d%@", self.termCount, self.term];
}

@end
