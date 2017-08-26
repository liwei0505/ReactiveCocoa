//
//  IMSPayService.h
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMSPayService <NSObject>
//绑卡
- (RACSignal *)bindCardWithUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber phoneNumber:(NSString *)phoneNumber
        bankId:(NSString *)bankId bankCardNumber:(NSString *)bankCardNumber verifyCode:(NSString *)verifyCode;
//获取银行卡列表
- (RACSignal *)querySupportBankListByIds:(NSArray *)bankIdList;

//设置交易密码
- (RACSignal *)setPayPassword:(NSString *)payPassword;

//重置交易密码
- (RACSignal *)verifyPayBoundPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode;
- (RACSignal *)verifyPayBoundUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber bankCardNumber:(NSString *)bankCardNumber;
- (RACSignal *)resetPayPassword:(NSString *)payPassword;

//充值
- (RACSignal *)queryRecharegeConfig;
- (RACSignal *)verifyRechargeInfoWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword;
- (RACSignal *)queryRechargeVerifyCode;
- (RACSignal *)rechargeByVerifyCode:(NSString *)verifyCode;
//提现
- (RACSignal *)queryWithdrawConfig;
- (RACSignal *)withdrawWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword;

//投资
- (RACSignal *)investWithLoanId:(NSNumber *)loanId redEnvelopeId:(NSString *)redEnvelopeId amount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword;
//认购
- (RACSignal *)buyDebtOfId:(NSNumber *)debtId payPassword:(NSString *)payPassword;

// 活期申购
- (RACSignal *)purchaseCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword;
// 活期赎回
- (RACSignal *)redeemCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword;

@end
