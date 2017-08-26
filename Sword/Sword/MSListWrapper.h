//
//  MSListWrapper.h
//  Sword
//
//  Created by haorenjie on 2017/3/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSListWrapper<T> : NSObject
@property (assign, nonatomic, readonly) BOOL hasMore;
@property (assign, nonatomic, readonly) BOOL isEmpty;
@property (assign, nonatomic, readonly) NSUInteger count;

- (instancetype)initWithPageSize:(NSUInteger)pageSize;
- (void)clear;
- (void)addList:(NSArray *)list;
- (NSArray *)getList;
- (id)getItemWithIndex:(NSUInteger)index;
- (id)getLastItem;
- (NSInteger)getNextPageIndex;

@end
