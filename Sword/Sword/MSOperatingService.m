//
//  MSOperatingService.m
//  Sword
//
//  Created by haorenjie on 2017/2/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSOperatingService.h"
#import "SystemConfigs.h"
#import "RiskInfo.h"
#import "MSLog.h"
#import "MSConfig.h"
#import "GoodsInfo.h"
#import "MessageInfo.h"
#import "RACError.h"
#import "NoticeInfo.h"

@interface MSOperatingService()
{
    id<IMJSProtocol> _protocol;
}
@end

@implementation MSOperatingService

- (instancetype)initWithProtocol:(id<IMJSProtocol>)protocol {
    if (self = [super init]) {
        _protocol = protocol;
        _operatingCache = [[MSOperatingCache alloc] init];
    }
    return self;
}

- (RACSignal *)querySystemConfig {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol querySystemConfig] subscribeNext:^(id x) {
            self.operatingCache.systemConfigs = (SystemConfigs *)x;
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryInviteCode:(ShareType)shareType {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryInviteCode:shareType] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryVerifyCodeByPhoneNumber:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACSignal *signal = [_protocol queryVerifyCodeByPhoneNumber:phoneNumber aim:aim];
        [signal subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)queryBannerList {
    return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryBannerList] subscribeNext:^(id x) {
            self.operatingCache.bannerList = (NSArray *)x;
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            RACError *result = (RACError *)error;
            [MSLog error:@"Query banner list failed, error:%d, message:%@", result.result, result.message];
            [subscriber sendError:result];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (BOOL)isShouldQueryBannerList{
    return (self.operatingCache.bannerList.count > 0) ? NO : YES;
}

- (RACSignal *)queryGoodsListByType:(ListRequestType)requestType {
    int pageIndex;
    if (LIST_REQUEST_NEW == requestType) {
        pageIndex = 1;
    } else {
        pageIndex = (int)self.operatingCache.pointShopList.count / MS_PAGE_SIZE + 1;
    }
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryProductList:pageIndex size:MS_PAGE_SIZE requestType:requestType] subscribeNext:^(NSDictionary *dic) {
            @strongify(self);
            ListRequestType type = [dic[TYPE] intValue];
            int totalCount = [dic[TOTALCOUNT] intValue];
            NSMutableArray *list = dic[LIST];
            
            if (type == LIST_REQUEST_NEW) {
                [self.operatingCache.pointShopList removeAllObjects];
            }
            [self.operatingCache.pointShopList addObjectsFromArray:list];
            
            self.operatingCache.totalPointGoods = totalCount;
            self.operatingCache.hasMorePointGoods = (list.count >= MS_PAGE_SIZE);
            
            [subscriber sendNext:nil];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (BOOL)hasMoreGoodsList{
    return [self.operatingCache hasMorePointGoods];
}

- (RACSignal *)exchangeByGoodsId:(NSNumber *)goodsId {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol exchange:goodsId.intValue] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryAbout {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       [[_protocol queryCompanyNotice:1 size:1 type:TYPE_ABOUT keywords:nil requestType:LIST_REQUEST_NEW] subscribeNext:^(id x) {
           NSDictionary *dic = (NSDictionary *)x;
           NSArray *list = dic[LIST];
           NoticeInfo *noticeInfo = (list && list.count > 0) ? list[0] : nil;
           
           [subscriber sendNext:noticeInfo];
       } error:^(NSError *error) {
           [subscriber sendError:error];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
        return nil;
    }];
}

- (RACSignal *)queryHelpListByType:(ListRequestType)requestType {
    int pageIndex;
    if (LIST_REQUEST_NEW == requestType) {
        pageIndex = 1;
    } else {
        pageIndex = (int)self.operatingCache.helpList.count / MS_PAGE_SIZE + 1;
    }
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryCompanyNotice:pageIndex size:MS_PAGE_SIZE type:TYPE_HELP keywords:nil requestType:requestType] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = (NSDictionary *)x;
            ListRequestType type = [dic[TYPE] intValue];
            int totalCount = [dic[TOTALCOUNT] intValue];
            NSMutableArray *list = dic[LIST];
            
            if (type == LIST_REQUEST_NEW) {
                [self.operatingCache.helpList removeAllObjects];
            }
            
            self.operatingCache.totalHelpCount = totalCount;
            self.operatingCache.hasMoreHelpList = (list.count >= MS_PAGE_SIZE);
            [self.operatingCache.helpList addObjectsFromArray:list];
            
            [subscriber sendNext:dic];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryNoticeListByType:(ListRequestType)requestType {
    int pageIndex;
    if (LIST_REQUEST_NEW == requestType) {
         pageIndex = 1;
    } else {
        pageIndex = (int)self.operatingCache.noticeList.count / MS_PAGE_SIZE + 1;
    }
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryCompanyNotice:pageIndex size:MS_PAGE_SIZE type:TYPE_NOTICE keywords:nil requestType:requestType] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = (NSDictionary *)x;
            ListRequestType type = [dic[TYPE] intValue];
            int totalCount = [dic[TOTALCOUNT] intValue];
            NSMutableArray *list = dic[LIST];
            
            if (type == LIST_REQUEST_NEW) {
                [self.operatingCache.noticeList removeAllObjects];
            }
            
            self.operatingCache.totalNoticeCount = totalCount;
            self.operatingCache.hasMoreNoticeList = (list.count >= MS_PAGE_SIZE);
            [self.operatingCache.noticeList addObjectsFromArray:list];
            
            [subscriber sendNext:dic];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryLatestNoticeId {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryNewNoticeList] subscribeNext:^(id x) {
            self.operatingCache.newNoticeId = [x intValue];
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryUnreadMessageCount {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryUnreadMessageCount] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryMessageListByType:(ListRequestType)requestType {
    int lastMessageId = 0;
    if (LIST_REQUEST_MORE == requestType) {
        if (self.operatingCache.messageList.count > 0) {
            lastMessageId = ((MessageInfo *)self.operatingCache.messageList.lastObject).messageId;
        }
    }
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol queryMessageList:lastMessageId size:MS_PAGE_SIZE requestType:requestType] subscribeNext:^(id x) {
            @strongify(self);
            NSDictionary *dic = (NSDictionary *)x;
            ListRequestType type = [dic[TYPE] intValue];
            NSMutableArray *list = dic[LIST];
            
            if (type == LIST_REQUEST_NEW) {
                [self.operatingCache.messageList removeAllObjects];
                [self.operatingCache.messageIdCache removeAllObjects];
            }
            
            self.operatingCache.hasMoreMessage = (list.count >= MS_PAGE_SIZE);

            for (MessageInfo *info in list) {
                //判断messageid 去掉重复数据
                NSString *messageId = [NSString stringWithFormat:@"%d",info.messageId];
                if (![self.operatingCache.messageIdCache objectForKey:messageId]) {
                    [self.operatingCache.messageIdCache setObject:info forKey:messageId];
                    [self.operatingCache.messageList addObject:info];
                } else {
                    //[MSLog info:@"有重复数据：%d", info.messageId];
                }
            }
            [subscriber sendNext:dic];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)readMessageWithId:(NSNumber *)messageId {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       [[_protocol sendReadMessageId:messageId.intValue] subscribeNext:^(id x) {
           RACError *result = (RACError *)x;
           if (result.result == ERR_NONE) {
               MessageInfo *info = [self.operatingCache.messageIdCache objectForKey:messageId.stringValue];
               info.status = 1;
           }else{
               LOGE(@"Send read message id failed, error:%ld, message:%@",(long)result.result,result.message);
           }
           
           [subscriber sendNext:result];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
        return nil;
    }];
}

- (RACSignal *)deleteMessageWithId:(NSNumber *)messageId {
    
    MessageInfo *info = self.operatingCache.messageIdCache[messageId.stringValue];
    [self.operatingCache.messageList removeObject:info];
    [self.operatingCache.messageIdCache removeObjectForKey:messageId.stringValue];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       [[_protocol sendDeleteMessage:messageId.intValue] subscribeNext:^(id x) {
           [subscriber sendNext:x];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
        return nil;
    }];
}

- (RACSignal *)checkUpdate {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_protocol checkUpdate] subscribeNext:^(id x) {
            self.operatingCache.updateInfo = (UpdateInfo *)x;
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (UpdateInfo *)getUpdateInfo{
    return self.operatingCache.updateInfo;
}

- (RACSignal *)queryRiskAssessment {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
       [[_protocol queryRiskAssessment] subscribeNext:^(id x) {
           [subscriber sendNext:x];
       } error:^(NSError *error) {
           [subscriber sendError:error];
       } completed:^{
           [subscriber sendCompleted];
       }];
        
        return nil;
    }];
}

- (RACSignal *)commitRiskAssessmentWithAnswers:(NSArray *)answers {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol commitRiskAssessment:answers] subscribeNext:^(RiskResultInfo *resultInfo) {
            self.operatingCache.resultInfo = resultInfo;
            [subscriber sendNext:resultInfo];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryRiskInfoByType:(RiskType)riskType {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol getRiskConfigueWithRiskType:riskType] subscribeNext:^(RiskResultInfo *resultInfo) {
            self.operatingCache.resultInfo = resultInfo;
            [subscriber sendNext:resultInfo];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryNewUrlWithOldUrl:(NSString *)url{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol reloginForRequest:url] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)feedback:(FeedbackInfo *)feedbackInfo {
    return [_protocol feedback:feedbackInfo];
}

@end

#pragma mark - MSOperatingCache
@implementation MSOperatingCache
- (instancetype)init
{
    self = [super init];
    if (self) {
        _pointShopList = [NSMutableArray array];
        
        _messageList = [NSMutableArray array];
        _messageIdCache = [[NSMutableDictionary alloc] init];
        
        _helpList = [[NSMutableArray alloc] init];
        _noticeList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)hasMoreMessageList{
    return _hasMoreMessage;
}

- (BOOL)hasMorePointGoods{
    return _pointShopList.count < _totalPointGoods || _hasMorePointGoods;
}

- (BOOL)hasMoreHelpList {
    return  _helpList.count < _totalHelpCount || _hasMoreHelpList;
}

- (BOOL)hasMoreNoticeList {
    return _noticeList.count < _totalNoticeCount || _hasMoreNoticeList;
}

- (void)clear {
    // TODO:
}

@end
