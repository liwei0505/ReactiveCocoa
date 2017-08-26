//
//  IMJSProtocol.h
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"

@class RACSignal;
@protocol IMJSProtocol <NSObject>

// 获取验证码
- (RACSignal *)queryVerifyCodeByPhoneNumber:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim;
// 注册
- (RACSignal *)registerWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode;
// 重置密码
- (RACSignal *)resetLoginPasswordWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode;
// 登录
- (RACSignal *)loginWithUserName:(NSString *)userName password:(NSString *)password;
// 登出
- (void)logout;
// 修改密码
- (RACSignal *)changePasswordWithUserName:(NSString *)userName origPassword:(NSString *)origPassword newPassword:(NSString *)newPassword;

- (NSString *)setSessionForURL:(NSString *)url;
// 获取我的账户详情
- (RACSignal *)queryMyAccountInfo;
// 获取我的投资列表
- (RACSignal *)queryMyInvestListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize status:(InvestStatus)status type:(ListRequestType)type;
// 获取我的转让列表
- (RACSignal *)queryMyDebtListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize statuses:(NSInteger)statuses type:(ListRequestType)type;
// 获取我的资金流水
- (RACSignal *)queryMyFundsFlowWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize recordType:(FlowType)type timeType:(Period)time requestType:(ListRequestType)requestType;
// 获取我的红包列表
- (RACSignal *)queryMyRedEnvelopeListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize status:(RedEnvelopeStatus)status type:(ListRequestType)requestType;
// 获取我的积分
- (RACSignal *)queryMyPoints;
// 获取我的积分列表
- (RACSignal *)queryMyPointListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize type:(ListRequestType)type;

// 获取广告列表
- (RACSignal *)queryBannerList;
// 获取推荐列表
- (RACSignal *)queryRecommendedList;
// 获取投资列表
- (RACSignal *)queryInvestList:(int)pageIndex size:(int)pageSize type:(NSInteger)type;
// 获取标的详情
- (RACSignal *)queryLoanDetail:(int)loanId;
// 获取标的用户投资总额
- (RACSignal *)queryMyInvestedAmount:(NSNumber *)loanId;
// 获取项目说明
- (RACSignal *)queryProjectInstruction:(int)loanId type:(int)type;
// 获取合同模板
- (RACSignal *)queryContractTemplate:(int)loanId;
// 获取投资记录
- (RACSignal *)queryInvestRecordList:(int)lastInvestorId size:(int)pageSize loanId:(int)loanId;
// 获取转让列表
- (RACSignal *)queryDebtList:(int)pageIndex size:(int)pageSize type:(NSInteger)type;
// 获取转让详情
- (RACSignal *)queryDebtDetail:(int)debtId;
// 获取投资可用红包列表
- (RACSignal *)queryRedEnvelopeListForLoanId:(NSNumber *)loanId investAmount:(NSDecimalNumber *)amount flag:(NSUInteger)flag;
// 转让债权
- (RACSignal *)sellDebt:(int)debtId discount:(double)discount;
// 撤销转让
- (RACSignal *)undoDebtSell:(int)debtId;

// 获取最新公告列表
- (RACSignal *)queryNewNoticeList;
// 获取未读消息数
- (RACSignal *)queryUnreadMessageCount;
// 消息已读
- (RACSignal *)sendReadMessageId:(int)messageId;
// 删除消息
- (RACSignal *)sendDeleteMessage:(int)messageId;
// 版本升级
- (RACSignal *)checkUpdate;
// 获取用户站内信息
- (RACSignal *)queryMessageList:(int)lastId size:(int)pageSize requestType:(ListRequestType)requestType;
// 获取商城商品列表
- (RACSignal *)queryProductList:(int)pageIndex size:(int)pageSize requestType:(ListRequestType)requestType;
// 兑换商品
- (RACSignal *)exchange:(int)productId;
// 获取邀请码
- (RACSignal *)queryInviteCode:(ShareType)shareType;
// 获取已邀请的朋友列表
- (RACSignal *)queryMyInvitedFriendListWithLastFriendID:(NSNumber *)friendID size:(NSInteger)pageSize;
// 获取系统配置信息
- (RACSignal *)querySystemConfig;
//关于我们 帮助中心 平台公告
- (RACSignal *)queryCompanyNotice:(int)pageIndex size:(int)pageSize type:(int)type keywords:(NSString *)keywords requestType:(ListRequestType)requestType;
- (RACSignal *)feedback:(FeedbackInfo *)feedbackInfo;

- (RACSignal *)reloginForRequest:(NSString *)url;

//风险测试题目
- (RACSignal *)queryRiskAssessment;
//提交测试答案
- (RACSignal *)commitRiskAssessment:(NSArray *)commitList;
//直接获取测试结果
- (RACSignal *)getRiskConfigueWithRiskType:(int)type;

- (RACSignal *)queryDebtAgreementInfo:(NSUInteger)debtId;
- (NSString *)getInvestAgreementById:(NSNumber *)debtId;
//获取支持的银行列表
- (RACSignal *)querySupportBankList:(NSString *)list;

- (RACSignal *)queryDrawcash:(NSString *)money password:(NSString *)password;
- (RACSignal *)queryNewInvestLoadId:(NSString *)loanId redBagId:(NSString *)redBagId password:(NSString *)password money:(NSString *)money;
- (RACSignal *)queryBuyDebt:(NSString *)debtId password:(NSString *)password;
- (RACSignal *)queryChargeOneStepMoney:(NSString *)money password:(NSString *)password;
- (RACSignal *)queryChargeTwoStepWithRechargeNo:(NSString *)rechargeNo;
- (RACSignal *)queryChargeThreeStepRechargeNo:(NSString *)rechargeNo vCode:(NSString *)vCode;
- (RACSignal *)userSetTradePassword:(NSString *)password;
- (RACSignal *)userResetTradePassword:(NSString *)password token:(NSString *)token;
- (RACSignal *)resetTradePasswordPhone:(NSString *)phone verifyCode:(NSString *)code;
- (RACSignal *)resetTradePasswordRealName:(NSString *)name idCard:(NSString *)idCard bankCard:(NSString *)card token:(NSString *)token;
- (RACSignal *)bindCardRealName:(NSString *)name idCard:(NSString *)idCard bankId:(NSString *)bankId bankCard:(NSString *)card phone:(NSString *)phone verifyCode:(NSString *)code;
- (RACSignal *)queryRechargeConfig;
- (RACSignal *)queryWithdrawConfig;

// Current
- (RACSignal *)queryMyAsset;
- (RACSignal *)queryCurrentListWithLastID:(NSNumber *)lastCurrentID pageSize:(NSInteger)pageSize isRecommended:(BOOL)isRecommended;
- (RACSignal *)queryCurrentDetail:(NSNumber *)currentID;
- (RACSignal *)queryCurrentEarningsHistoryWithID:(NSNumber *)currentID lastEarningsDate:(long)lastDate pageSize:(NSInteger)pageSize;
- (RACSignal *)queryCurrentPurchaseConfig:(NSNumber *)currentID;
- (RACSignal *)purchaseCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword;
- (RACSignal *)queryCurrentRedeemConfig:(NSNumber *)currentID;
- (RACSignal *)redeemCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword;

@end
