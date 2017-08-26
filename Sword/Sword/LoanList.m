//
//  LoanList.m
//  Sword
//
//  Created by haorenjie on 2017/3/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "LoanList.h"

@implementation LoanList
{
    NSMutableDictionary *_sectionDict;
    NSMutableArray *_sections;
    BOOL _recommended;
}

- (instancetype)initWithType:(BOOL)recommended {
    if (self = [super init]) {
        _recommended = recommended;
        _sectionDict = [[NSMutableDictionary alloc] initWithCapacity:_recommended ? 4 : 3];
        _sections = [[NSMutableArray alloc] initWithCapacity:_recommended ? 4 : 3];
        _hasMore = NO;
    }
    return self;
}

- (NSArray *)sections {
    return _sections;
}

- (BOOL)shouldRefresh {
    BOOL shouldRefresh = NO;
    NSArray *keys = [_sectionDict allKeys];
    for (NSNumber *key in keys) {
        MSSectionList *list = [_sectionDict objectForKey:key];
        shouldRefresh = list.listWrapper.isEmpty;
        if (shouldRefresh) {
            break;
        }
    }
    return shouldRefresh;
}

- (void)setList:(MSListWrapper *)list {
    _hasMore = list.hasMore;
    [_sectionDict removeAllObjects];
    if (_recommended) {
        [self classifyByRecommend:[list getList]];
    } else {
        [self classifyByInvest:[list getList]];
    }
}

- (MSSectionList *)getSection:(NSNumber *)section
{
    return [_sectionDict objectForKey:section];
}

- (NSArray *)getAllSectionLists {
    
    NSMutableArray *sectionLists = [NSMutableArray array];
    
    if (_sectionDict[@(MSSectionListTypeNewer)]) {
        [sectionLists addObject:_sectionDict[@(MSSectionListTypeNewer)]];
    }
    
    if (_sectionDict[@(MSSectionListTypeWillStart)]) {
        [sectionLists addObject:_sectionDict[@(MSSectionListTypeWillStart)]];
    }
    
    if (_sectionDict[@(MSSectionListTypeInvesting)]) {
        [sectionLists addObject:_sectionDict[@(MSSectionListTypeInvesting)]];
    }
    
    if (_sectionDict[@(MSSectionListTypeCompleted)]) {
        [sectionLists addObject:_sectionDict[@(MSSectionListTypeCompleted)]];
    }
    
    return sectionLists;
}

- (void)classifyByRecommend:(NSArray *)list {
    NSUInteger count = list.count;
    NSMutableArray *newerList = [[NSMutableArray alloc] init];
    int index = 0;
    MSServiceManager *serviceMgr = [MSAppDelegate getServiceManager];
    for (; index < count; ++index) {
        NSNumber *loanId = [list objectAtIndex:index];
        LoanInfo *loanInfo = [serviceMgr getLoanInfo:loanId].baseInfo;
        if (loanInfo.classify != 1) {
            break;
        }
        [newerList addObject:loanId];
    }

    if (newerList.count > 0) {
        [self addList:newerList withType:MSSectionListTypeNewer];
    }

    if (index < count) {
        NSRange range = NSMakeRange(index, count - index);
        NSArray *otherList = [list subarrayWithRange:range];
        [self classifyByInvest:otherList];
    }
}

- (void)classifyByInvest:(NSArray *)list {
    NSUInteger count = list.count;
    NSMutableArray *investingList = [[NSMutableArray alloc] init];
    NSMutableArray *willStartList = [[NSMutableArray alloc] init];
    int index = 0;
    MSServiceManager *serviceMgr = [MSAppDelegate getServiceManager];
    for (; index < count; ++index) {
        NSNumber *loanId = [list objectAtIndex:index];
        LoanInfo *loanInfo = [serviceMgr getLoanInfo:loanId].baseInfo;
        if (LOAN_STATUS_COMPLETED == loanInfo.status || LOAN_STATUS_INVEST_END == loanInfo.status) {
            break;
        }

        if (LOAN_STATUS_INVEST_NOW == loanInfo.status) {
            [investingList addObject:loanId];
        } else {
            [willStartList addObject:loanId];
        }
    }

    if (investingList.count > 0) {
        [self addList:investingList withType:MSSectionListTypeInvesting];
    }
    if (willStartList.count > 0) {
        [self addList:willStartList withType:MSSectionListTypeWillStart];
    }

    if (index < count) {
        NSRange range = NSMakeRange(index, count - index);
        NSArray *completedList = [list subarrayWithRange:range];
        [self addList:completedList withType:MSSectionListTypeCompleted];
    }
}

- (void)addList:(NSArray *)list withType:(MSSectionListType)type {
    NSNumber *key = [NSNumber numberWithInt:type];
    MSSectionList *section = [_sectionDict objectForKey:key];
    if (!section) {
        MSListWrapper *listWrapper = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
        section = [MSSectionList sectionListWithType:type listWrapper:listWrapper];
        [_sectionDict setObject:section forKey:key];
    }
    [section.listWrapper addList:list];
    if (![_sections containsObject:key]) {
        [_sections addObject:key];
    }
}

@end
