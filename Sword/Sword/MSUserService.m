//
//  MSUserService.m
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSUserService.h"
#import "MSSettings.h"
#import "NSString+Ext.h"
#import "MSCheckInfoUtils.h"

@interface MSUserService()
{
    id<IMJSProtocol> _protocol;
}

@end

@implementation MSUserService

- (instancetype)initWithProtocol:(id<IMJSProtocol>)protocol {
    if (self = [super init]) {
        _protocol = protocol;
        _userCache = [[MSUserCache alloc] init];
        [MSNotificationHelper addObserver:self selector:@selector(logout) name:NOTIFY_USER_KICK];
    }
    return self;
}

- (void)dealloc{
    [MSNotificationHelper removeObserver:self];
}

#pragma mark - Auth
- (RACSignal *)registerWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode {

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_protocol registerWithPhoneNumber:phoneNumber password:[NSString desWithKey:password key:nil] verifyCode:verifyCode] subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)resetLoginPasswordWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_protocol resetLoginPasswordWithPhoneNumber:phoneNumber password:password verifyCode:verifyCode] subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)loginWithUserName:(NSString *)userName password:(NSString *)password {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[_protocol loginWithUserName:userName password:password] subscribeNext:^(MSLoginInfo *loginInfo) {
            @strongify(self);
            
            self.userCache.loginInfo = loginInfo;
            self.userCache.isLogin = YES;
            [MSSettings saveLastLoginInfo:loginInfo];
            
            MSUserLocalConfig *config = [MSSettings getLocalConfig:loginInfo.userId];
            config.patternLockErrorCount = 0;
            [MSSettings saveLocalConfig:config];
            
            [subscriber sendNext:loginInfo];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (void)logout {
    [_protocol logout];
    [self.userCache clear];
    MSUserLocalConfig *config = [MSSettings getLocalConfig:self.userCache.loginInfo.userId];
    config.patternLockErrorCount = 0;
    [MSSettings saveLocalConfig:config];
    [MSSettings clearUserPassword];
    [MJSStatistics setUserID:@""];
    [MJSStatistics setSessionID:@""];
}

- (RACSignal *)changeOrignalPassword:(NSString *)orignalPassword toPassword:(NSString *)newPassword {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_protocol changePasswordWithUserName:self.userCache.loginInfo.userName origPassword:orignalPassword newPassword:newPassword] subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            @strongify(self);
            [self logout];
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (NSString *)setSessionForURL:(NSString *)url {
    return [_protocol setSessionForURL:url];
}

#pragma mark - user info
- (RACSignal *)queryMyInfo {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (self.userCache.accountInfo) {
            [subscriber sendNext:self.userCache.accountInfo];
        }

        [[_protocol queryMyAccountInfo] subscribeNext:^(AccountInfo *accountInfo) {
            @strongify(self)
            self.userCache.accountInfo = accountInfo;
            MSUserLocalConfig *localConfig = [MSSettings getLocalConfig:self.userCache.loginInfo.userId];
            localConfig.phoneNumber = accountInfo.phoneNumber;
            [MSSettings saveLocalConfig:localConfig];
            [subscriber sendNext:accountInfo];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyAsset {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (self.userCache.assetInfo) {
            [subscriber sendNext:self.userCache.assetInfo];
        }

        [[_protocol queryMyAsset] subscribeNext:^(AssetInfo *assetInfo) {
            @strongify(self)
            self.userCache.assetInfo = assetInfo;
            [subscriber sendNext:assetInfo];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyInvestListByType:(ListRequestType)requestType status:(InvestStatus)status {
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        MSListWrapper *investList = self.userCache.investListDict[@(status)];
        if (!investList) {
            investList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
            self.userCache.investListDict[@(status)] = investList;
        }

        NSInteger pageIndex = 1;
        if (LIST_REQUEST_MORE == requestType) {
            pageIndex = [investList getNextPageIndex];
            if (pageIndex < 0) {
                [subscriber sendCompleted];
                return nil;
            }
        }
        
        [[_protocol queryMyInvestListWithPageIndex:pageIndex pageSize:MS_PAGE_SIZE status:status type:requestType] subscribeNext:^(NSDictionary *dic) {
            @strongify(self);
            NSArray *list = dic[LIST];
            
            MSListWrapper *investList = self.userCache.investListDict[@(status)];
            if (requestType == LIST_REQUEST_NEW) {
                [investList clear];
            }
            [investList addList:list];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyDebtListByType:(ListRequestType)requestType status:(NSInteger)status {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        MSListWrapper *myDebtList = self.userCache.debtListDict[@(status)];
        if (!myDebtList) {
            myDebtList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
            self.userCache.debtListDict[@(status)] = myDebtList;
        }
        
        NSInteger pageIndex = 1;
        if (LIST_REQUEST_MORE == requestType) {
            pageIndex = [myDebtList getNextPageIndex];
            if (pageIndex < 0) {
                [subscriber sendCompleted];
                return nil;
            }
        }
        
        [[_protocol queryMyDebtListWithPageIndex:pageIndex pageSize:MS_PAGE_SIZE statuses:status type:requestType] subscribeNext:^(NSDictionary *dic) {
            @strongify(self);
            NSArray *list = dic[LIST];
            
            MSListWrapper *debtList = self.userCache.debtListDict[@(status)];
            
            if (requestType == LIST_REQUEST_NEW) {
                [debtList clear];
            }
            [debtList addList:list];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)sellDebtById:(NSNumber *)debtId discount:(NSNumber *)discount {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[_protocol sellDebt:debtId.intValue discount:discount.doubleValue] subscribeNext:^(NSNumber *debtId_) {
            
            NSInteger category = STATUS_CAN_BE_TRANSFER;
            MSListWrapper *canTransferList = self.userCache.debtListDict[@(category)];
            [canTransferList clear];
            category = STATUS_TRANSFERRING | STATUS_TRANSFERRED;
            MSListWrapper *transferredList = self.userCache.debtListDict[@(category)];
            [transferredList clear];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[KEY_DEBT_ID] = debtId_;
            
            [subscriber sendNext:params];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)undoDebtSoldOfId:(NSNumber *)debtId {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[_protocol undoDebtSell:debtId.intValue] subscribeNext:^(NSNumber *debtId_) {
            
            NSInteger category = STATUS_CAN_BE_TRANSFER;
            MSListWrapper *canTransferList = self.userCache.debtListDict[@(category)];
            [canTransferList clear];
            category = STATUS_TRANSFERRING | STATUS_TRANSFERRED;
            MSListWrapper *transferredList = self.userCache.debtListDict[@(category)];
            [transferredList clear];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[KEY_DEBT_ID] = debtId_;
            
            [subscriber sendNext:params];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (DebtTradeInfo *)getCanTransferDebt:(NSNumber *)debtId{
    
    MSListWrapper *canTransferList = self.userCache.debtListDict[@(STATUS_CAN_BE_TRANSFER)];
    if (!canTransferList || canTransferList.isEmpty) {
        return nil;
    }
    for (DebtTradeInfo *attornInfo in [canTransferList getList]) {
        if (attornInfo.debtInfo.debtId == debtId.intValue) {
            return attornInfo;
        }
    }
    return nil;
}


- (RACSignal *)queryMyRedEnvelopeListByType:(ListRequestType)requestType status:(RedEnvelopeStatus)status {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        MSListWrapper *redEnvelopeList = self.userCache.redEnvelopeListDict[@(status)];
        if (!redEnvelopeList) {
            redEnvelopeList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
            self.userCache.redEnvelopeListDict[@(status)] = redEnvelopeList;
        }
        
        NSInteger pageIndex = 1;
        if (LIST_REQUEST_MORE == requestType) {
            pageIndex = [redEnvelopeList getNextPageIndex];
            if (pageIndex < 0) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }
        }
        
        [[_protocol queryMyRedEnvelopeListWithPageIndex:pageIndex pageSize:MS_PAGE_SIZE status:status type:requestType] subscribeNext:^(NSDictionary *dic) {
            @strongify(self);
            
            NSArray *list_ = dic[LIST];

            MSListWrapper *redEnvelopeList = self.userCache.redEnvelopeListDict[@(status)];
            if (requestType == LIST_REQUEST_NEW) {
                [redEnvelopeList clear];
            }
            [redEnvelopeList addList:list_];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[KEY_MY_REDBAG_CATEGORY] = @(status);
            
            [subscriber sendNext:params];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryRedEnvelopeListForLoanId:(NSNumber *)loanId investAmount:(NSDecimalNumber *)amount flag:(NSUInteger)flag {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_protocol queryRedEnvelopeListForLoanId:loanId investAmount:amount flag:flag] subscribeNext:^(NSArray *redEnvelopeList) {
            
            NSMutableDictionary *params = [NSMutableDictionary new];
            [params setObject:loanId forKey:KEY_LOAN_ID];
            [params setObject:amount forKey:KEY_INVEST_AMOUNT];
            [params setObject:redEnvelopeList forKey:KEY_RED_ENVELOPE_LIST];
            
            [subscriber sendNext:params];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyFundsFlowByType:(ListRequestType)requestType typeCategory:(FlowType)typeCategory timeCategory:(Period)timeCategory {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSUInteger pageIndex;
        if (LIST_REQUEST_NEW == requestType) {
            pageIndex = 1;
        }else{
            pageIndex = (int)self.userCache.fundsFlowList.count / MS_PAGE_SIZE + 1;;
        }

        [[_protocol queryMyFundsFlowWithPageIndex:pageIndex pageSize:MS_PAGE_SIZE recordType:typeCategory timeType:timeCategory requestType:requestType] subscribeNext:^(NSDictionary *dic) {
            @strongify(self);
            ListRequestType requestType_ = [dic[TYPE] intValue];
            NSArray *list = dic[LIST];
            int total = [dic[TOTALCOUNT] intValue];
            
            if (requestType_ == LIST_REQUEST_NEW) {
                [self.userCache.fundsFlowList removeAllObjects];
            }
            [self.userCache.fundsFlowList addObjectsFromArray:list];
            
            self.userCache.totalFundsFlow = total;
            self.userCache.hasMoreFundsFlow = (list.count >= MS_PAGE_SIZE);
            
            [subscriber sendNext:nil];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyInviteInfo {
    return [_protocol queryMyInvitedFriendListWithLastFriendID:@(0) size:0];
}

- (RACSignal *)queryMyInvitedFriendListByType:(ListRequestType)requestType {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);

        if (!self.userCache.invitedFriendList) {
            self.userCache.invitedFriendList = [[MSListWrapper alloc] initWithPageSize:MS_PAGE_SIZE];
        }

        NSNumber *lastID = @(0);
        if (LIST_REQUEST_MORE == requestType && self.userCache.invitedFriendList.count > 0) {
            FriendInfo *friendInfo = [self.userCache.invitedFriendList getItemWithIndex:self.userCache.invitedFriendList.count - 1];
            lastID = friendInfo.userID;
            if (!lastID) {
                [self.userCache.invitedFriendList addList:[NSArray array]];
                [subscriber sendCompleted];
                return nil;
            }
        }

        [[_protocol queryMyInvitedFriendListWithLastFriendID:lastID size:MS_PAGE_SIZE] subscribeNext:^(NSArray *invitedFriendList) {
            @strongify(self);
            if (LIST_REQUEST_NEW == requestType) {
                [self.userCache.invitedFriendList clear];
            }
            [self.userCache.invitedFriendList addList:invitedFriendList];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];;
        
        return nil;
    }];
}

- (RACSignal *)queryMyPoints {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_protocol queryMyPoints] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];;
        
        return nil;
    }];
}

- (BOOL)hasMorePointData{
    return [self.userCache hasMorePointList];
}

- (RACSignal *)queryMyPointDetailsByType:(ListRequestType)requestType {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSUInteger pageIndex;
        if (LIST_REQUEST_NEW == requestType) {
            pageIndex = 1;
        }else{
            pageIndex = (int)self.userCache.myPointList.count / MS_PAGE_SIZE + 1;
        }

        [[_protocol queryMyPointListWithPageIndex:pageIndex pageSize:MS_PAGE_SIZE type:requestType] subscribeNext:^(NSDictionary *dic) {
            @strongify(self);
            ListRequestType type_ = [dic[TYPE] intValue];
            int total = [dic[TOTALCOUNT] intValue];
            NSArray *list_ = dic[LIST];
            
            if (type_ == LIST_REQUEST_NEW) {
                [self.userCache.myPointList removeAllObjects];
            }
            [self.userCache.myPointList addObjectsFromArray:list_];
            
            self.userCache.totalPointList = total;
            self.userCache.hasMorePointList = (list_.count >= MS_PAGE_SIZE);
            
            [subscriber sendNext:nil];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

@end

#pragma mark - MSUserCache
@implementation MSUserCache

- (instancetype)init {
    if (self = [super init]) {
        _loginInfo = [[MSLoginInfo alloc] init];
        _isLogin = NO;
        _loginStatus = STATUS_NOT_LOGIN;
        _accountInfo = nil;
        _investListDict = [NSMutableDictionary dictionary];
        _debtListDict = [NSMutableDictionary dictionary];
        _fundsFlowList = [NSMutableArray array];
        _redEnvelopeListDict = [NSMutableDictionary dictionary];
        _myPointList = [NSMutableArray array];
    }
    return self;
}

- (BOOL)hasMoreFundsFlow {
    return _fundsFlowList.count < _totalFundsFlow || _hasMoreFundsFlow;
}

- (BOOL)hasMorePointList {
    return _myPointList.count < _totalPointList || _hasMorePointList;
}

- (void)clear {
    _loginInfo = [[MSLoginInfo alloc] init];
    _isLogin = NO;
    _loginStatus = STATUS_NOT_LOGIN;
    _accountInfo = nil;
    _assetInfo = nil;
    [_investListDict removeAllObjects];
    [_debtListDict removeAllObjects];
    [_fundsFlowList removeAllObjects];
    _hasMoreFundsFlow = NO;
    _totalFundsFlow = 0;
    [_redEnvelopeListDict removeAllObjects];
    [_myPointList removeAllObjects];
    _hasMorePointList = NO;
    _totalPointList = 0;
    [self.invitedFriendList clear];
}

@end
