//
//  MSServiceManager.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSServiceManager.h"
#import "MSInvestRecordList.h"
#import "DebtDetail.h"
#import "SystemConfigs.h"
#import "MSLoginInfo.h"
#import "AccountInfo.h"
#import "InviteInfo.h"
#import "RiskInfo.h"

@class MSListWrapper;
@class CurrentDetail;
@class InsurantInfo;
@class InsurancePolicy;

@interface MSServiceManager : NSObject <IMSServiceManager>

- (instancetype)initWithServiceFactory:(id<IMSServiceFactory>)serviceFactory;

#pragma mark - UserService
- (RACSignal *)registerWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode;
- (RACSignal *)resetLoginPasswordWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode;
- (RACSignal *)loginWithUserName:(NSString *)userName password:(NSString *)password;
- (void)logout;
- (BOOL)isLogin;

- (RACSignal *)changeOrignalPassword:(NSString *)orignalPassword toPassword:(NSString *)newPassword;

- (RACSignal *)queryMyInfo;
- (RACSignal *)queryMyAsset;
- (NSString *)setSessionForURL:(NSString *)url;

- (RACSignal *)queryMyInvestListByType:(ListRequestType)requestType status:(InvestStatus)status;
- (MSListWrapper *)getMyInvestList:(InvestStatus)status;

- (RACSignal *)queryMyDebtListByType:(ListRequestType)requestType status:(NSInteger)status;
- (MSListWrapper *)getMyDebtList:(NSInteger)status;

- (RACSignal *)sellDebtById:(NSNumber *)debtId discount:(NSNumber *)discount;
- (RACSignal *)undoDebtSoldOfId:(NSNumber *)debtId;
- (DebtTradeInfo *)getCanTransferDebt:(NSNumber *)debtId;

- (RACSignal *)queryMyRedEnvelopeListByType:(ListRequestType)requestType status:(RedEnvelopeStatus)status;
- (MSListWrapper *)getRedEnvelopeList:(RedEnvelopeStatus)status;

- (RACSignal *)queryRedEnvelopeListForLoanId:(NSNumber *)loanId investAmount:(NSDecimalNumber *)amount flag:(NSUInteger)flag;

- (RACSignal *)queryMyFundsFlowByType:(ListRequestType)requestType typeCategory:(FlowType)typeCategory timeCategory:(Period)timeCategory;
- (NSArray *)getFundsFlowList;
- (BOOL)hasMoreFundsFlow;

- (RACSignal *)queryMyInviteInfo;
- (RACSignal *)queryMyInvitedFriendListByType:(ListRequestType)requestType;
- (MSListWrapper *)getInvitedFriendList;

- (RACSignal *)queryMyPoints;
- (NSArray *)getPointList;
- (BOOL)hasMorePointData;

- (RACSignal *)queryMyPointDetailsByType:(ListRequestType)requestType;

#pragma mark - FinanceService
- (RACSignal *)queryRecommendedList;
- (RACSignal *)queryLoanListByType:(ListRequestType)type;
- (LoanDetail *)getLoanInfo:(NSNumber *)loanId;

- (RACSignal *)queryLoanDetailById:(NSNumber *)loanId;
- (RACSignal *)queryMyInvestedAmount:(NSNumber *)loanId;
- (RACSignal *)queryProjectInstructionByType:(ProjectInstructionType)type loanId:(NSNumber *)loanId;
- (RACSignal *)queryLoanInvestorListByType:(ListRequestType)type loanId:(NSNumber *)loanId;
- (MSInvestRecordList *)getInvestRecords:(NSNumber *)loanId;
- (RACSignal *)queryInvestContractByLoanId:(NSNumber *)loanId;

- (RACSignal *)queryDebtListByType:(ListRequestType)type;
- (BOOL)isShouldQueryDebtList;
- (NSInteger)getDebtListCount;
- (NSNumber *)getDebtIdWithIndex:(NSInteger)index;
- (BOOL)hasMoreAttorns;
- (DebtDetail *)getDebtInfo:(NSNumber *)debtId;

- (RACSignal *)queryDebtDetailById:(NSNumber *)debtId;
- (RACSignal *)queryDebtAgreementById:(NSNumber *)debtId;
- (NSString *)getInvestAgreementById:(NSNumber *)debtId;
- (NSInteger)investCheck:(LoanDetail *)loanInfo;
- (NSInteger)investCheck:(LoanDetail *)loanInfo investAmount:(NSInteger)investAmount;
- (NSInteger)attornCheck:(DebtDetail *)debtInfo;

#pragma mark - OperatingService
- (SystemConfigs *)getSysConfigs;
- (RACSignal *)querySystemConfig;
- (RACSignal *)queryInviteCode:(ShareType)shareType;
- (RACSignal *)queryVerifyCodeByPhoneNumber:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim;
- (RACSignal *)queryBannerList;
- (BOOL)isShouldQueryBannerList;

- (RACSignal *)queryGoodsListByType:(ListRequestType)requestType;
- (NSArray  *)getGoodsList;
- (BOOL)hasMoreGoodsList;

- (RACSignal *)exchangeByGoodsId:(NSNumber *)goodsId;

- (RACSignal *)queryAbout;
- (RACSignal *)queryHelpListByType:(ListRequestType)requestType;
- (NSArray *)getHelpList;
- (BOOL)hasMoreHelpList;

- (RACSignal *)queryNoticeListByType:(ListRequestType)requestType;
- (NSArray *)getNoticeList;
- (BOOL)hasMoreNoticeList;

- (RACSignal *)queryLatestNoticeId;
- (int)getNewNoticeId;

- (RACSignal *)queryUnreadMessageCount;
- (RACSignal *)queryMessageListByType:(ListRequestType)requestType;
- (NSArray *)getMessageList;
- (BOOL)hasMoreMessageList;
- (RACSignal *)readMessageWithId:(NSNumber *)messageId;
- (RACSignal *)deleteMessageWithId:(NSNumber *)messageId;

- (RACSignal *)checkUpdate;
- (UpdateInfo *)getUpdateInfo;
- (RACSignal *)queryRiskAssessment;
- (RACSignal *)commitRiskAssessmentWithAnswers:(NSArray *)answers;
- (RACSignal *)queryRiskInfoByType:(RiskType)riskType;
@property (strong, nonatomic) RiskResultInfo *riskResultInfo;
@property (strong, nonatomic) NSMutableArray *topics;
- (RACSignal *)queryNewUrlWithOldUrl:(NSString *)url;

- (RACSignal *)feedback:(FeedbackInfo *)feedbackInfo;

#pragma mark - CurrentService
- (RACSignal *)queryCurrentListByType:(ListRequestType)type isRecommended:(BOOL)isRecommended;
- (MSListWrapper *)getCurrentIdList;
- (CurrentDetail *)getCurrent:(NSNumber *)currentID;
- (RACSignal *)queryCurrentDetail:(NSNumber *)currentID;
- (RACSignal *)queryCurrentEarningsHistoryByType:(ListRequestType)type WithID:(NSNumber *)currentID;
- (RACSignal *)queryCurrentPurchaseConfig:(NSNumber *)currentID;
- (RACSignal *)queryCurrentRedeemConfig:(NSNumber *)currentID;

- (MSListWrapper *)getCurrentEarningsHistory:(NSNumber *)currentID;

#pragma mark - PayService
- (RACSignal *)bindCardWithUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber phoneNumber:(NSString *)phoneNumber
        bankId:(NSString *)bankId bankCardNumber:(NSString *)bankCardNumber verifyCode:(NSString *)verifyCode;
- (RACSignal *)querySupportBankListByIds:(NSArray *)bankIdList;
- (RACSignal *)setPayPassword:(NSString *)payPassword;
- (RACSignal *)verifyPayBoundPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode;
- (RACSignal *)verifyPayBoundUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber bankCardNumber:(NSString *)bankCardNumber;
- (RACSignal *)resetPayPassword:(NSString *)payPassword;
- (RACSignal *)queryRechargeConfig;
- (RACSignal *)verifyRechargeInfoWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword;
- (RACSignal *)queryRechargeVerifyCode;
- (RACSignal *)rechargeByVerifyCode:(NSString *)verifyCode;
- (RACSignal *)queryWithdrawConfig;
- (RACSignal *)withdrawWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword;
- (RACSignal *)investWithLoanId:(NSNumber *)loanId redEnvelopeId:(NSString *)redEnvelopeId amount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword;
- (RACSignal *)buyDebtOfId:(NSNumber *)debtId payPassword:(NSString *)payPassword;
- (RACSignal *)purchaseCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword;
- (RACSignal *)redeemCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword;

#pragma mark - InsuranceService

- (RACSignal *)queryInsuranceRecommendedList;
- (RACSignal *)queryInsuranceSectionList;
- (RACSignal *)queryInsuranceDetailWithId:(NSString *)insuranceId wholeInfo:(BOOL)wholeInfo;
- (RACSignal *)queryInsuranceContentWithId:(NSString *)insuranceId type:(InsuranceContentType)contentType;
- (RACSignal *)insuranceWithInsuranceId:(NSString *)insuranceId productId:(NSString *)productId effectiveDate:(NSTimeInterval)effectiveDate copiesCount:(NSUInteger)copiesCount insurerMail:(NSString *)insurerMail insurant:(InsurantInfo *)insurantInfo;
- (RACSignal *)cancelInsuranceWithOrderId:(NSString *)orderId;
- (RACSignal *)queryFHOnlinePayInfoWithOrderId:(NSString *)orderId;
- (RACSignal *)queryInsurancePolicyInfoWithId:(NSString *)orderId;
- (InsurancePolicy *)getInsurancePolicyInfoWithId:(NSString *)orderId;
- (RACSignal *)queryMyInsurancePolicyListWithStatus:(NSUInteger)statusFlag reqeustType:(ListRequestType)requestType;
// Deprecated.
- (RACSignal *)queryPayInfoWithOrderId:(NSString *)orderId payType:(PayType)payType;

@end
