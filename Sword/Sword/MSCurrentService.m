//
//  MSCurrentService.m
//  Sword
//
//  Created by haorenjie on 2017/3/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentService.h"

@implementation MSCurrentCache

- (instancetype)init {
    if (self = [super init]) {
        _recommendedList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
        _currentList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
        _currentDict = [[NSMutableDictionary alloc] init];
        _earningsHistoryDict = [[NSMutableDictionary alloc] init];
        _purchaseConfigDict = [[NSMutableDictionary alloc] init];
        _redeemConfigDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end

@interface MSCurrentService()
{
    id<IMJSProtocol> _protocol;
}

@end

@implementation MSCurrentService

- (instancetype)initWithProtocol:(id<IMJSProtocol>)protocol
{
    if (self = [super init]) {
        _protocol = protocol;
        _cache = [[MSCurrentCache alloc] init];
    }
    return self;
}

- (CurrentDetail *)getCurrent:(NSNumber *)currentID {
    return [self.cache.currentDict objectForKey:currentID];
}

- (RACSignal *)queryCurrentListByType:(ListRequestType)type isRecommended:(BOOL)isRecommended
{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSNumber *lastCurrentID = [NSNumber numberWithInteger:-1];
        @strongify(self);
        if (LIST_REQUEST_MORE == type) {
            MSListWrapper *currentList = isRecommended ? self.cache.recommendedList : self.cache.currentList;
            if (!currentList.hasMore) {
                [subscriber sendCompleted];
                return nil;
            }

            NSArray *currentListArray = isRecommended ? [self.cache.recommendedList getList]: [self.cache.currentList getList];
            if (currentListArray.count > 0) {
                CurrentInfo *currentInfo = currentListArray[currentList.count - 1];
                lastCurrentID = currentInfo.currentID;
            }
        }

        [[_protocol queryCurrentListWithLastID:lastCurrentID pageSize:isRecommended ? 1 : MS_PAGE_SIZE isRecommended:isRecommended] subscribeNext:^(NSArray *currentList) {
            @strongify(self);
            if (LIST_REQUEST_NEW == type) {
                NSArray *currentIDList = isRecommended ? [self.cache.recommendedList getList]: [self.cache.currentList getList];
                for (NSNumber *currentId in currentIDList) {
                    [self.cache.currentDict removeObjectForKey:currentId];
                }
                if (isRecommended) {
                    [self.cache.recommendedList clear];
                } else {
                    [self.cache.currentList clear];
                }
            }

            NSMutableArray *currentIDList = [[NSMutableArray alloc] initWithCapacity:currentList.count];
            for (CurrentInfo *currentInfo in currentList) {
                [currentIDList addObject:currentInfo.currentID];
                CurrentDetail *currentDetail = [self.cache.currentDict objectForKey:currentInfo.currentID];
                if (!currentDetail) {
                    currentDetail = [[CurrentDetail alloc] init];
                    [self.cache.currentDict setObject:currentDetail forKey:currentInfo.currentID];
                }
                currentDetail.baseInfo = currentInfo;
            }

            if (isRecommended) {
                [self.cache.recommendedList addList:currentIDList];
            } else {
                [self.cache.currentList addList:currentIDList];
            }

        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryCurrentDetail:(NSNumber *)currentID {
    @weakify(self);
    return [[_protocol queryCurrentDetail:currentID] doNext:^(CurrentDetail *currentDetail) {
        @strongify(self);
        CurrentDetail *localDetail = [self.cache.currentDict objectForKey:currentID];
        currentDetail.baseInfo = localDetail.baseInfo;
        [self.cache.currentDict setObject:currentDetail forKey:currentID];
    }];
}

- (RACSignal *)queryCurrentEarningsHistoryByType:(ListRequestType)type WithID:(NSNumber *)currentID {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        long lastDate = -1L;
        @strongify(self);
        
        MSListWrapper *earningsHistory = [self.cache.earningsHistoryDict objectForKey:currentID];
        if (!earningsHistory) {
            earningsHistory = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
            [self.cache.earningsHistoryDict setObject:earningsHistory forKey:currentID];
        }
        
        if (LIST_REQUEST_MORE == type) {
            if (!earningsHistory.hasMore) {
                [subscriber sendCompleted];
                return nil;
            }

            NSArray *earningsList = [earningsHistory getList];
            if (earningsList.count > 0) {
                CurrentEarnings *earnings = earningsList[earningsList.count - 1];
                lastDate = earnings.date;
            }
        }

        [[_protocol queryCurrentEarningsHistoryWithID:currentID lastEarningsDate:lastDate pageSize:MS_PAGE_SIZE] subscribeNext:^(NSArray *earningsList) {
            @strongify(self);
            MSListWrapper *earningsHistory = [self.cache.earningsHistoryDict objectForKey:currentID];
            if (LIST_REQUEST_NEW == type) {
                [earningsHistory clear];
            }
            [earningsHistory addList:earningsList];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryCurrentPurchaseConfig:(NSNumber *)currentID {
    @weakify(self);
    return [[_protocol queryCurrentPurchaseConfig:currentID] doNext:^(CurrentPurchaseConfig *config) {
        @strongify(self);
        [self.cache.purchaseConfigDict setObject:config forKey:currentID];
    }];
}

- (RACSignal *)queryCurrentRedeemConfig:(NSNumber *)currentID {
    @weakify(self);
    return [[_protocol queryCurrentRedeemConfig:currentID] doNext:^(CurrentRedeemConfig *config) {
        @strongify(self);
        [self.cache.redeemConfigDict setObject:config forKey:currentID];
    }];
}

@end
