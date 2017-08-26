//
//  MSListWrapper.m
//  Sword
//
//  Created by haorenjie on 2017/3/23.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSListWrapper.h"

@interface MSListWrapper()
{
    NSUInteger _pageSize;
}

@property (strong, nonatomic) NSMutableArray *list;

@end

@implementation MSListWrapper

- (instancetype)initWithPageSize:(NSUInteger)pageSize {
    if (self = [super init]) {
        assert(pageSize > 0);
        _pageSize = pageSize;
        _hasMore = NO;
        _list = [[NSMutableArray alloc] initWithCapacity:pageSize];
    }
    return self;
}

- (BOOL)isEmpty {
    return _list.count == 0;
}

- (NSUInteger)count {
    return _list.count;
}

- (void)clear {
    [self.list removeAllObjects];
    _hasMore = YES;
}

- (void)addList:(NSArray *)list {
    if (!list || list.count == 0) {
        _hasMore = NO;
        return;
    }

    [self.list addObjectsFromArray:list];
    _hasMore = (self.list.count % _pageSize == 0);
}

- (NSArray *)getList {
    return self.list;
}

- (id)getItemWithIndex:(NSUInteger)index {
    return self.list[index];
}

- (id)getLastItem {
    return _list.lastObject;
}

- (NSInteger)getNextPageIndex {
    if (!self.hasMore) {
        return -1;
    }

    return [self getPageCount] + 1;
}

- (NSUInteger)getPageCount {
    NSUInteger pageCount = self.list.count / _pageSize;
    if (self.list.count % _pageSize) {
        pageCount += 1;
    }
    return pageCount;
}

@end
