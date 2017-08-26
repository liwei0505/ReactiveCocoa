//
//  MSInvestRecordList.h
//  Sword
//
//  Created by haorenjie on 16/6/14.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSInvestRecordList : NSObject

@property (strong, nonatomic) NSNumber *loanId;
@property (strong, nonatomic) NSMutableArray *records;
@property (assign, nonatomic) BOOL hasMore;

- (void)reset;
- (void)addRecords:(NSArray *)investRecords;

@end
