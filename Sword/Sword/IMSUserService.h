//
//  IUserService.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"
#import "DebtTradeInfo.h"

@protocol IMSUserService <NSObject>

// Auth related API
- (RACSignal *)registerWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode;
- (RACSignal *)resetLoginPasswordWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode;
- (RACSignal *)loginWithUserName:(NSString *)userName password:(NSString *)password;
- (void)logout;
- (RACSignal *)changeOrignalPassword:(NSString *)orignalPassword toPassword:(NSString *)newPassword;

// Utils
- (NSString *)setSessionForURL:(NSString *)url;
// User related API
- (RACSignal *)queryMyInfo;
- (RACSignal *)queryMyAsset;

- (RACSignal *)queryMyInvestListByType:(ListRequestType)requestType status:(InvestStatus)status;
- (RACSignal *)queryMyDebtListByType:(ListRequestType)requestType status:(NSInteger)status;

- (RACSignal *)sellDebtById:(NSNumber *)debtId discount:(NSNumber *)discount;
- (RACSignal *)undoDebtSoldOfId:(NSNumber *)debtId;

- (DebtTradeInfo *)getCanTransferDebt:(NSNumber *)debtId;

- (RACSignal *)queryRedEnvelopeListForLoanId:(NSNumber *)loanId investAmount:(NSDecimalNumber *)amount flag:(NSUInteger)flag;

- (RACSignal *)queryMyRedEnvelopeListByType:(ListRequestType)requestType status:(RedEnvelopeStatus)status;

- (RACSignal *)queryMyFundsFlowByType:(ListRequestType)requestType typeCategory:(FlowType)typeCategory timeCategory:(Period)timeCategory;

- (RACSignal *)queryMyInviteInfo;
- (RACSignal *)queryMyInvitedFriendListByType:(ListRequestType)requestType;

- (RACSignal *)queryMyPoints;
- (BOOL)hasMorePointData;

- (RACSignal *)queryMyPointDetailsByType:(ListRequestType)requestType;

@end
