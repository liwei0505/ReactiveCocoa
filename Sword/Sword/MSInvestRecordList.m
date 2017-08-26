//
//  MSInvestRecordList.m
//  Sword
//
//  Created by haorenjie on 16/6/14.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInvestRecordList.h"

@implementation MSInvestRecordList

- (instancetype)init{
    
    if (self = [super init]) {
        _records = [[NSMutableArray alloc] init];
        _hasMore = NO;
        _loanId = nil;
    }
    return self;
}

- (void)reset{
    
    [_records removeAllObjects];
    _hasMore = NO;
    _loanId = nil;
}

- (void)addRecords:(NSArray *)investRecords
{
    [_records addObjectsFromArray:investRecords];
}

@end
