//
//  MSServiceManager.m
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSServiceManager.h"
#import "MJSServiceFactory.h"
#import "MSUserService.h"
#import "MSPayService.h"
#import "MSOperatingService.h"
#import "RACError.h"
#import "RACEmptySubscriber.h"
#import "InvestInfo.h"

@interface MSServiceManager()
{
    MSUserService *_userService;
    MSPayService *_payService;
    MSOperatingService *_operatingService;
    MSFinanceService *_financeService;
    MSCurrentService *_currentService;
    MJSInsuranceService *_insuranceService;
}

@end

@implementation MSServiceManager

- (instancetype)initWithServiceFactory:(__autoreleasing id<IMSServiceFactory>)serviceFactory {
    if (self = [super init]) {
        _userService = [serviceFactory createUserService];
        _payService = [serviceFactory createPayService];
        _operatingService = [serviceFactory createOperatingService];
        id extensionFactory = [serviceFactory getExtensionFactory];
        if (extensionFactory && [extensionFactory isKindOfClass:[MJSServiceFactory class]]) {
            MJSServiceFactory *mjsServiceFactory = (MJSServiceFactory *)extensionFactory;
            _financeService = [mjsServiceFactory createFinanceService];
            _currentService = [mjsServiceFactory createCurrentService];
            _insuranceService = [mjsServiceFactory createInsuranceService];
        }
    }
    return self;
}

#pragma mark - UserService
- (RACSignal *)registerWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode {
    return [_userService registerWithPhoneNumber:phoneNumber password:password verifyCode:verifyCode];
}

- (RACSignal *)resetLoginPasswordWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode {
    return [_userService resetLoginPasswordWithPhoneNumber:phoneNumber password:password verifyCode:verifyCode];
}

- (RACSignal *)loginWithUserName:(NSString *)userName password:(NSString *)password {
    @weakify(self);
    return [[_userService loginWithUserName:userName password:password] doNext:^(MSLoginInfo *loginInfo) {
        @strongify(self);

        self.riskResultInfo = [[RiskResultInfo alloc] init];
        self.riskResultInfo.type = loginInfo.riskType;
        if (loginInfo.riskType == EVALUATE_NOT) {
            self.riskResultInfo.title = NSLocalizedString(@"str_risk_evaluate_no", @"");
            self.riskResultInfo.desc = @"";
            self.riskResultInfo.icon = @"";
        } else {
            [[self queryRiskInfoByType:loginInfo.riskType] subscribe:[RACEmptySubscriber empty]];
        }

        [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
        [[self queryMyAsset] subscribe:[RACEmptySubscriber empty]];
    }];
}

- (void)logout {
    [_userService logout];
    // Reset all user related publish datum.
    [RACEventHandler publish:[AccountInfo new]];
    [RACEventHandler publish:[AssetInfo new]];
}

- (BOOL)isLogin{
    return _userService.userCache.isLogin;
}

- (RACSignal *)changeOrignalPassword:(NSString *)orignalPassword toPassword:(NSString *)newPassword {
    return [_userService changeOrignalPassword:orignalPassword toPassword:newPassword];
}

- (RACSignal *)queryMyInfo {
    @weakify(self);
    return [[_userService queryMyInfo] doNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        [[self querySystemConfig] subscribe:[RACEmptySubscriber empty]];
        [RACEventHandler publish:accountInfo];
    }];
}

- (RACSignal *)queryMyAsset {
    return [[_userService queryMyAsset] doNext:^(AssetInfo *assetInfo) {
        [RACEventHandler publish:assetInfo];
    }];
}

- (NSString *)setSessionForURL:(NSString *)url {
    return [_userService setSessionForURL:url];
}

- (RACSignal *)queryMyInvestListByType:(ListRequestType)requestType status:(InvestStatus)status {
    return [[_userService queryMyInvestListByType:requestType status:status] doCompleted:^{
        MSListWrapper *investList = [self getMyInvestList:status];
        NSUInteger count = investList.count;
        for (int i = 0; i < count; ++i) {
            LoanInfo *loanInfo = ((InvestInfo *)[investList getItemWithIndex:i]).loanInfo;
            [_financeService addLoanInfo:loanInfo];
        }

        MJSMyInvestListChangedEvent *event = [[MJSMyInvestListChangedEvent alloc] init];
        event.status = status;
        [RACEventHandler broadcast:event];
    }];
}

- (MSListWrapper *)getMyInvestList:(InvestStatus)status {
    return _userService.userCache.investListDict[@(status)];
}

- (RACSignal *)queryMyDebtListByType:(ListRequestType)requestType status:(NSInteger)status {
    return [[_userService queryMyDebtListByType:requestType status:status] doCompleted:^{
        MJSMyDebtListChangedEvent *event = [[MJSMyDebtListChangedEvent alloc] init];
        event.status = status;
        [RACEventHandler broadcast:event];
    }];
}

- (MSListWrapper *)getMyDebtList:(NSInteger)status {
    return _userService.userCache.debtListDict[@(status)];
}

- (RACSignal *)sellDebtById:(NSNumber *)debtId discount:(NSNumber *)discount {
    return [_userService sellDebtById:debtId discount:discount];
}

- (RACSignal *)undoDebtSoldOfId:(NSNumber *)debtId {
    return [_userService undoDebtSoldOfId:debtId];
}

- (DebtTradeInfo *)getCanTransferDebt:(NSNumber *)debtId{
    return [_userService getCanTransferDebt:debtId];
}

- (RACSignal *)queryMyRedEnvelopeListByType:(ListRequestType)requestType status:(RedEnvelopeStatus)status {
    return [_userService queryMyRedEnvelopeListByType:requestType status:status];
}

- (MSListWrapper *)getRedEnvelopeList:(RedEnvelopeStatus)status{
    return _userService.userCache.redEnvelopeListDict[@(status)];
}

- (RACSignal *)queryRedEnvelopeListForLoanId:(NSNumber *)loanId investAmount:(NSDecimalNumber *)amount flag:(NSUInteger)flag {
    return [_userService queryRedEnvelopeListForLoanId:loanId investAmount:amount flag:flag];
}

- (RACSignal *)queryMyFundsFlowByType:(ListRequestType)requestType typeCategory:(FlowType)typeCategory timeCategory:(Period)timeCategory {
    return [_userService queryMyFundsFlowByType:requestType typeCategory:typeCategory timeCategory:timeCategory];
}

- (NSArray *)getFundsFlowList{
    return _userService.userCache.fundsFlowList;
}

- (BOOL)hasMoreFundsFlow{
    return [_userService.userCache hasMoreFundsFlow];
}

- (RACSignal *)queryMyInviteInfo {
    return [_userService queryMyInviteInfo];
}

- (RACSignal *)queryMyInvitedFriendListByType:(ListRequestType)requestType {
    return [_userService queryMyInvitedFriendListByType:requestType];
}

- (MSListWrapper *)getInvitedFriendList{
    return _userService.userCache.invitedFriendList;
}

- (RACSignal *)queryMyPoints {
    return [_userService queryMyPoints];
}

- (NSArray *)getPointList{
    return _userService.userCache.myPointList;
}

- (BOOL)hasMorePointData{
    return [_userService hasMorePointData];
}

- (RACSignal *)queryMyPointDetailsByType:(ListRequestType)requestType {
    return [_userService queryMyPointDetailsByType:requestType];
}

#pragma mark - FinanceService
- (LoanDetail *)getLoanInfo:(NSNumber *)loanId{
    return [_financeService getLoanInfo:loanId];
}

- (DebtDetail *)getDebtInfo:(NSNumber *)debtId{
    return [_financeService getDebtInfo:debtId];
}

- (RACSignal *)queryRecommendedList {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        LoanList *recommendedList = [[LoanList alloc] initWithType:YES];

        [[_financeService queryRecommendedList] subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [recommendedList setList:_financeService.financeCache.recommenedList];
            [subscriber sendNext:recommendedList];
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryLoanListByType:(ListRequestType)type {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        LoanList *investList = [[LoanList alloc] initWithType:NO];

        [[_financeService queryLoanListByType:type] subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [investList setList:_financeService.financeCache.investList];
            [subscriber sendNext:investList];
            [subscriber sendCompleted];
        }];

        return nil;
    }];
}

- (RACSignal *)queryLoanDetailById:(NSNumber *)loanId {
    return  [_financeService queryLoanDetailById:loanId];
}

- (RACSignal *)queryMyInvestedAmount:(NSNumber *)loanId {
    return [_financeService queryMyInvestedAmount:loanId];
}

- (RACSignal *)queryProjectInstructionByType:(ProjectInstructionType)type loanId:(NSNumber *)loanId {
    return [_financeService queryProjectInstructionByType:type loanId:loanId];
}

- (RACSignal *)queryLoanInvestorListByType:(ListRequestType)type loanId:(NSNumber *)loanId {
    return [_financeService queryLoanInvestorListByType:type loanId:loanId];
}

- (MSInvestRecordList *)getInvestRecords:(NSNumber *)loanId{
    return [_financeService getInvestRecords:loanId];
}

- (RACSignal *)queryInvestContractByLoanId:(NSNumber *)loanId {
    return [_financeService queryInvestContractByLoanId:loanId];
}

- (RACSignal *)queryDebtListByType:(ListRequestType)type {
    return [_financeService queryDebtListByType:type];
}

- (BOOL)isShouldQueryDebtList{
    return [_financeService isShouldQueryDebtList];
}
- (NSInteger)getDebtListCount{
    return [_financeService getDebtListCount];
}
- (NSNumber *)getDebtIdWithIndex:(NSInteger)index{
    return [_financeService getDebtIdWithIndex:index];
}
- (BOOL)hasMoreAttorns{
    return [_financeService hasMoreAttorns];
}

- (RACSignal *)queryDebtDetailById:(NSNumber *)debtId {
    return [_financeService queryDebtDetailById:debtId];
}

- (RACSignal *)queryDebtAgreementById:(NSNumber *)debtId {
    return [_financeService queryDebtAgreementById:debtId];
}

- (NSString *)getInvestAgreementById:(NSNumber *)debtId {
    return [_financeService getInvestAgreementById:debtId];
}

- (NSInteger)investCheck:(LoanDetail *)loanInfo {
    
    if (!_userService.userCache.isLogin) {
        return ERR_NOT_LOGIN;
    }
    
    AccountInfo *accountInfo = _userService.userCache.accountInfo;
    
    if (accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
        return ERR_NOT_AUTHENTICATED;
    }
    
    if (accountInfo.payStatus == STATUS_PAY_NO_PASSWORD) {
        return ERR_NO_PAY_PASSWORD;
    }
    
    if (accountInfo.uId == loanInfo.borrowId) {
        return ERR_BUY_FROM_SELF;
    }
    
    if (loanInfo.baseInfo.classify == CLASSIFY_FOR_TIRO && accountInfo.investCount > 0) {
        return ERR_NOT_TIRO;
    }
    return ERR_NONE;
}

- (NSInteger)investCheck:(LoanDetail *)loanInfo investAmount:(NSInteger)investAmount{
    
    if (!_userService.userCache.isLogin) {
        return ERR_NOT_LOGIN;
    }
    
    AccountInfo *accountInfo = _userService.userCache.accountInfo;
    
    if (accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
        return ERR_NOT_AUTHENTICATED;
    }
    
    if (accountInfo.payStatus == STATUS_PAY_NO_PASSWORD) {
        return ERR_NO_PAY_PASSWORD;
    }
    
    if (accountInfo.uId == loanInfo.borrowId) {
        return ERR_BUY_FROM_SELF;
    }
    
    if (loanInfo.baseInfo.classify == CLASSIFY_FOR_TIRO && accountInfo.investCount > 0) {
        return ERR_NOT_TIRO;
    }
    
    if (investAmount <= 0) {
        return ERR_ZERO_AMOUNT;
    }
    
    //可投金额 小于起投金额
    if (loanInfo.baseInfo.subjectAmount < loanInfo.baseInfo.startAmount) {
        if (investAmount == loanInfo.baseInfo.subjectAmount) {
            return ERR_NONE;
        } else {
            return ERR_AMOUNT_NOT_EQUAL;
        }
    }
    
    if (investAmount > loanInfo.baseInfo.subjectAmount) {
        return ERR_EXCEED_SUBJECT_AMOUNT;
    }
    
    if (loanInfo.baseInfo.maxInvestLimit > 0 && investAmount > loanInfo.baseInfo.maxInvestLimit) {
        return ERR_EXCEED_MAX_LIMIT;
    }
    
    if (investAmount < loanInfo.baseInfo.startAmount
        || ((investAmount - loanInfo.baseInfo.startAmount) % loanInfo.increaseAmount) > 0) {
        return ERR_MISMATCHED_AMOUNT;
    }
    
    return ERR_NONE;
}

- (NSInteger)attornCheck:(DebtDetail *)debtInfo{
    
    if (!_userService.userCache.isLogin) {
        return ERR_NOT_LOGIN;
    }
    
    AccountInfo *accountInfo = _userService.userCache.accountInfo;
    
    if (accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
        return ERR_NOT_AUTHENTICATED;
    }
    
    if (accountInfo.payStatus == STATUS_PAY_NO_PASSWORD) {
        return ERR_NO_PAY_PASSWORD;
    }
    
    
    if (accountInfo.uId == debtInfo.investorUserId) {
        return ERR_BUY_FROM_SELF;
    }
    
    return ERR_NONE;
}

#pragma mark - OperatingService
- (SystemConfigs *)getSysConfigs{
    return _operatingService.operatingCache.systemConfigs;
}

- (RACSignal *)querySystemConfig {
    return [_operatingService querySystemConfig];
}

- (RACSignal *)queryInviteCode:(ShareType)shareType {
    return [_operatingService queryInviteCode:shareType];
}

- (RACSignal *)queryVerifyCodeByPhoneNumber:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim {
    return [_operatingService queryVerifyCodeByPhoneNumber:phoneNumber aim:aim];
}

- (RACSignal *)queryBannerList {
   return  [_operatingService queryBannerList];
}

- (BOOL)isShouldQueryBannerList{
     return [_operatingService isShouldQueryBannerList];
}

- (RACSignal *)queryGoodsListByType:(ListRequestType)requestType {
    return [_operatingService queryGoodsListByType:requestType];
}

- (NSArray  *)getGoodsList{
    return _operatingService.operatingCache.pointShopList;
}

- (BOOL)hasMoreGoodsList{
    return [_operatingService hasMoreGoodsList];
}

- (RACSignal *)exchangeByGoodsId:(NSNumber *)goodsId {
    return [_operatingService exchangeByGoodsId:goodsId];
}

- (RACSignal *)queryAbout {
    return [_operatingService queryAbout];
}

- (RACSignal *)queryHelpListByType:(ListRequestType)requestType {
    return [_operatingService queryHelpListByType:requestType];
}

- (NSArray *)getHelpList{
    return _operatingService.operatingCache.helpList;
}

- (BOOL)hasMoreHelpList{
    return [_operatingService.operatingCache hasMoreHelpList];
}

- (RACSignal *)queryNoticeListByType:(ListRequestType)requestType {
    return [_operatingService queryNoticeListByType:requestType];
}

- (NSArray *)getNoticeList{
    return _operatingService.operatingCache.noticeList;
}
- (BOOL)hasMoreNoticeList{
    return [_operatingService.operatingCache hasMoreNoticeList];
}

- (RACSignal *)queryLatestNoticeId{
    return [_operatingService queryLatestNoticeId];
}

- (int)getNewNoticeId{
    return _operatingService.operatingCache.newNoticeId;
}

- (RACSignal *)queryUnreadMessageCount {
    return [_operatingService queryUnreadMessageCount];
}

- (RACSignal *)queryMessageListByType:(ListRequestType)requestType {
    return [_operatingService queryMessageListByType:requestType];
}

- (NSArray *)getMessageList{
    return _operatingService.operatingCache.messageList;
}
- (BOOL)hasMoreMessageList{
    return [_operatingService.operatingCache hasMoreMessageList];
}

- (RACSignal *)readMessageWithId:(NSNumber *)messageId {
    return [_operatingService readMessageWithId:messageId];
}

- (RACSignal *)deleteMessageWithId:(NSNumber *)messageId {
    return [_operatingService deleteMessageWithId:messageId];
}

- (RACSignal *)checkUpdate {
    return [_operatingService checkUpdate];
}

- (UpdateInfo *)getUpdateInfo{
    return [_operatingService getUpdateInfo];
}

- (RACSignal *)queryRiskAssessment {
    return [_operatingService queryRiskAssessment];
}

- (RACSignal *)commitRiskAssessmentWithAnswers:(NSArray *)answers {
    return [_operatingService commitRiskAssessmentWithAnswers:answers];
}

- (RACSignal *)queryRiskInfoByType:(RiskType)riskType {
    return [_operatingService queryRiskInfoByType:riskType];
}

- (void)setRiskResultInfo:(RiskResultInfo *)riskResultInfo{
    _operatingService.operatingCache.resultInfo = riskResultInfo;
}

- (RiskResultInfo *)riskResultInfo{
    return _operatingService.operatingCache.resultInfo;
}

- (RACSignal *)queryNewUrlWithOldUrl:(NSString *)url{
    return [_operatingService queryNewUrlWithOldUrl:url];
}

- (RACSignal *)feedback:(FeedbackInfo *)feedbackInfo {
    return [_operatingService feedback:feedbackInfo];
}

#pragma mark - CurrentService
- (RACSignal *)queryCurrentListByType:(ListRequestType)type isRecommended:(BOOL)isRecommended {
    return [_currentService queryCurrentListByType:type isRecommended:isRecommended];
}

- (MSListWrapper *)getCurrentIdList {
    if (_currentService.cache.currentList.count > 0) {
        return _currentService.cache.currentList;
    }else if (_currentService.cache.recommendedList.count > 0) {
        return _currentService.cache.recommendedList;
    }
    return nil;
}

- (CurrentDetail *)getCurrent:(NSNumber *)currentID {
    return [_currentService getCurrent:currentID];
}

- (RACSignal *)queryCurrentDetail:(NSNumber *)currentID {
    return [_currentService queryCurrentDetail:currentID];
}

- (RACSignal *)queryCurrentEarningsHistoryByType:(ListRequestType)type WithID:(NSNumber *)currentID {
    return [_currentService queryCurrentEarningsHistoryByType:type WithID:currentID];
}

- (RACSignal *)queryCurrentPurchaseConfig:(NSNumber *)currentID {
    return [_currentService queryCurrentPurchaseConfig:currentID];
}

- (RACSignal *)queryCurrentRedeemConfig:(NSNumber *)currentID {
    return [[_currentService queryCurrentRedeemConfig:currentID] doNext:^(CurrentRedeemConfig *config) {
        AssetInfo *assetInfo = _userService.userCache.assetInfo;
        NSDecimalNumber *userCanRedeemAmount = assetInfo.currentAsset.canRedeemAmount;
        if ([userCanRedeemAmount compare:config.leftCanRedeemAmount] == NSOrderedAscending) {
            config.leftCanRedeemAmount = userCanRedeemAmount;
        }
    }];
}

- (MSListWrapper *)getCurrentEarningsHistory:(NSNumber *)currentID {
    return [_currentService.cache.earningsHistoryDict objectForKey:currentID];
}

#pragma mark - PayService
- (RACSignal *)bindCardWithUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber phoneNumber:(NSString *)phoneNumber
        bankId:(NSString *)bankId bankCardNumber:(NSString *)bankCardNumber verifyCode:(NSString *)verifyCode {
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_payService bindCardWithUserName:userName idCardNumber:idCardNumber phoneNumber:phoneNumber bankId:bankId bankCardNumber:bankCardNumber verifyCode:verifyCode] subscribeError:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            @strongify(self);
            [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)querySupportBankListByIds:(NSArray *)bankIdList {
    return [_payService querySupportBankListByIds:bankIdList];
}

- (RACSignal *)setPayPassword:(NSString *)payPassword {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_payService setPayPassword:payPassword] subscribeNext:^(id x) {
            @strongify(self);
            [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
            [subscriber sendNext:x];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)verifyPayBoundPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode {
    return [_payService verifyPayBoundPhoneNumber:phoneNumber verifyCode:verifyCode];
}

- (RACSignal *)verifyPayBoundUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber bankCardNumber:(NSString *)bankCardNumber {
    
    return [_payService verifyPayBoundUserName:userName idCardNumber:idCardNumber bankCardNumber:bankCardNumber];
}

- (RACSignal *)resetPayPassword:(NSString *)payPassword {
    return [_payService resetPayPassword:payPassword];
}

- (RACSignal *)queryRechargeConfig {
    return [_payService queryRecharegeConfig];
}

- (RACSignal *)verifyRechargeInfoWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword {
    return [_payService verifyRechargeInfoWithAmount:amount payPassword:payPassword];
}

- (RACSignal *)queryRechargeVerifyCode {
    return [_payService queryRechargeVerifyCode];
}

- (RACSignal *)rechargeByVerifyCode:(NSString *)verifyCode {
    @weakify(self);
    return [[_payService rechargeByVerifyCode:verifyCode] doCompleted:^{
        @strongify(self);
        [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
        [[self queryMyAsset] subscribe:[RACEmptySubscriber empty]];
    }];
}

- (RACSignal *)queryWithdrawConfig {
    return [[_payService queryWithdrawConfig] doNext:^(WithdrawConfig *withdrawConfig) {
        [RACEventHandler publish:withdrawConfig];
    }];
}

- (RACSignal *)withdrawWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword {
    @weakify(self);
    return [[_payService withdrawWithAmount:amount payPassword:payPassword] doCompleted:^{
        @strongify(self);
        [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
        [[self queryMyAsset] subscribe:[RACEmptySubscriber empty]];
        [[self queryWithdrawConfig] subscribe:[RACEmptySubscriber empty]];
    }];
}

- (RACSignal *)investWithLoanId:(NSNumber *)loanId redEnvelopeId:(NSString *)redEnvelopeId amount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword {
    @weakify(self);
    return [[_payService investWithLoanId:loanId redEnvelopeId:redEnvelopeId amount:amount payPassword:payPassword] doCompleted:^{
        @strongify(self);
        [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
        [[self queryMyAsset] subscribe:[RACEmptySubscriber empty]];
    }];
}

- (RACSignal *)buyDebtOfId:(NSNumber *)debtId payPassword:(NSString *)payPassword {
    @weakify(self);
    return  [[_payService buyDebtOfId:debtId payPassword:payPassword] doCompleted:^{
        @strongify(self);
        [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
        [[self queryMyAsset] subscribe:[RACEmptySubscriber empty]];
    }];
}

- (RACSignal *)purchaseCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    @weakify(self);
    return [[_payService purchaseCurrentWithID:currentID amount:amount password:payPassword] doNext:^(id x) {
        @strongify(self);
        [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
        [[self queryMyAsset] subscribe:[RACEmptySubscriber empty]];
    }];
}

- (RACSignal *)redeemCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    @weakify(self);
    return [[_payService redeemCurrentWithID:currentID amount:amount password:payPassword] doCompleted:^{
        @strongify(self);
        [[self queryMyInfo] subscribe:[RACEmptySubscriber empty]];
        [[self queryMyAsset] subscribe:[RACEmptySubscriber empty]];
    }];
}

#pragma mark - InsuranceService

- (RACSignal *)queryInsuranceRecommendedList {
    return [_insuranceService queryRecommendedList];
}

- (RACSignal *)queryInsuranceSectionList {
    return [_insuranceService querySectionList];
}

- (RACSignal *)queryInsuranceDetailWithId:(NSString *)insuranceId wholeInfo:(BOOL)wholeInfo {
    return [_insuranceService queryInsuranceDetailWithId:insuranceId wholeInfo:wholeInfo];
}

- (RACSignal *)queryInsuranceContentWithId:(NSString *)insuranceId type:(InsuranceContentType)contentType {
    return [_insuranceService queryInsuranceContentWithId:insuranceId type:contentType];
}

- (RACSignal *)insuranceWithInsuranceId:(NSString *)insuranceId productId:(NSString *)productId effectiveDate:(NSTimeInterval)effectiveDate copiesCount:(NSUInteger)copiesCount insurerMail:(NSString *)insurerMail insurant:(InsurantInfo *)insurantInfo {
    if (!insurantInfo) {
        insurantInfo = [[InsurantInfo alloc] init];
        AccountInfo *accountInfo = _userService.userCache.accountInfo;
        insurantInfo.name = accountInfo.realName;
        insurantInfo.mobile = accountInfo.phoneNumber;
        insurantInfo.certificateId = accountInfo.idcardNum;
    }
    return [_insuranceService insuranceWithInsuranceId:insuranceId productId:productId effectiveDate:effectiveDate copiesCount:copiesCount insurerMail:insurerMail insurant:insurantInfo];
}

- (RACSignal *)cancelInsuranceWithOrderId:(NSString *)orderId {
    return [_insuranceService cancelInsuranceWithOrderId:orderId];
}

- (RACSignal *)queryPayInfoWithOrderId:(NSString *)orderId payType:(PayType)payType {
    return [_insuranceService queryPayInfoWithOrderId:orderId payType:payType];
}

- (RACSignal *)queryFHOnlinePayInfoWithOrderId:(NSString *)orderId {
    return [_insuranceService queryFHOnlinePayInfoWithOrderId:orderId];
}

- (RACSignal *)queryInsurancePolicyInfoWithId:(NSString *)orderId {
    return [[_insuranceService queryPolicyInfoWithId:orderId] doNext:^(InsurancePolicy *policyInfo) {
        policyInfo.insurerName = _userService.userCache.accountInfo.realName;
    }];
}

- (InsurancePolicy *)getInsurancePolicyInfoWithId:(NSString *)orderId {
    InsurancePolicy *policyInfo = [_insuranceService getPolicyInfo:orderId];
    policyInfo.insurerName = _userService.userCache.accountInfo.realName;
    return policyInfo;
}

- (RACSignal *)queryMyInsurancePolicyListWithStatus:(NSUInteger)statusFlag reqeustType:(ListRequestType)requestType {
    return [_insuranceService queryMyPolicyListWithStatus:statusFlag reqeustType:requestType];
}

@end
