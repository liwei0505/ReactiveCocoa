//
//  LoanList.h
//  Sword
//
//  Created by haorenjie on 2017/3/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSectionList.h"

@interface LoanList : NSObject

@property (strong, nonatomic, readonly) NSArray *sections;
@property (assign, nonatomic, readonly) BOOL hasMore;
- (instancetype)initWithType:(BOOL)recommended;
- (BOOL)shouldRefresh;
- (void)setList:(MSListWrapper *)list;
- (MSSectionList *)getSection:(NSNumber *)section;
- (NSArray *)getAllSectionLists;
@end
