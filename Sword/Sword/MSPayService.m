//
//  MSPayService.m
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPayService.h"
#import "RACError.h"
#import "MSRechargeOne.h"
#import "MSRechargeTwo.h"
#import "MSRechargeThree.h"

@interface MSPayService()
{
    id<IMJSProtocol> _protocol;
}
@end

@implementation MSPayService

- (instancetype)initWithProtocol:(id<IMJSProtocol>)protocol {
    if (self = [super init]) {
        _protocol = protocol;
        _payCache = [[MSPayCache alloc] init];
    }
    return self;
}

- (RACSignal *)bindCardWithUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber phoneNumber:phoneNumber
        bankId:(NSString *)bankId bankCardNumber:(NSString *)bankCardNumber verifyCode:(NSString *)verifyCode {
    
    return [_protocol bindCardRealName:userName idCard:idCardNumber bankId:bankId bankCard:bankCardNumber phone:phoneNumber verifyCode:verifyCode];
}

- (RACSignal *)querySupportBankListByIds:(NSArray *)bankIdList {
    NSUInteger idCount = bankIdList.count;
    NSString *bankIdsString = @"";
    if (idCount > 0) {
        NSMutableString *stringBuilder = [[NSMutableString alloc] initWithCapacity:bankIdList.count];
        for (int i = 0; i < idCount; ++i) {
            if (i > 0) {
                [stringBuilder appendString:@","];
            }
            [stringBuilder appendString:[bankIdList objectAtIndex:i]];
        }
        bankIdsString = stringBuilder;
    }
    return [_protocol querySupportBankList:bankIdsString];
}

- (RACSignal *)setPayPassword:(NSString *)payPassword {
    return [_protocol userSetTradePassword:payPassword];
}

- (RACSignal *)verifyPayBoundPhoneNumber:(NSString *)phoneNumber verifyCode:(NSString *)verifyCode {
    @weakify(self);
    self.payCache.token = nil;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [[_protocol resetTradePasswordPhone:phoneNumber verifyCode:verifyCode] subscribeNext:^(id x) {
            @strongify(self);
            self.payCache.token = (NSString *)x;
            [subscriber sendNext:x];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)verifyPayBoundUserName:(NSString *)userName idCardNumber:(NSString *)idCardNumber bankCardNumber:(NSString *)bankCardNumber {
    if (!self.payCache.token) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            RACError *error = [[RACError alloc] init];
            error.result = ERR_INVALID_STATE;
            [subscriber sendNext:error];
            [subscriber sendCompleted];
            return nil;
        }];
    }
    return [_protocol resetTradePasswordRealName:userName idCard:idCardNumber bankCard:bankCardNumber token:self.payCache.token];
}

- (RACSignal *)resetPayPassword:(NSString *)payPassword {
    if (!self.payCache.token) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            RACError *error = [[RACError alloc] init];
            error.result = ERR_INVALID_STATE;
            [subscriber sendNext:error];
            [subscriber sendCompleted];
            return nil;
        }];
    }
    return [_protocol userResetTradePassword:payPassword token:self.payCache.token];
}

- (RACSignal *)queryRecharegeConfig {
    return [_protocol queryRechargeConfig];
}

- (RACSignal *)verifyRechargeInfoWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword {
    @weakify(self);
    self.payCache.rechargeSeqNumber = nil;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[_protocol queryChargeOneStepMoney:amount.stringValue password:payPassword] subscribeNext:^(NSDictionary *dic) {
            
            @strongify(self);
            self.payCache.rechargeSeqNumber = dic[@"rechargeNo"];
            if (!self.payCache.rechargeSeqNumber) {
                [MSLog error:@"Recharge Seq Number is nil."];
            }
            [subscriber sendNext:dic[@"message"]];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryRechargeVerifyCode {
    if (!self.payCache.rechargeSeqNumber) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            MSRechargeTwo *rechargeTwo = [[MSRechargeTwo alloc] init];
            rechargeTwo.result = ERR_INVALID_STATE;
            [subscriber sendError:rechargeTwo];
            return nil;
        }];
    }
    return [_protocol queryChargeTwoStepWithRechargeNo:self.payCache.rechargeSeqNumber];
}

- (RACSignal *)rechargeByVerifyCode:(NSString *)verifyCode {
    if (!self.payCache.rechargeSeqNumber) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            MSRechargeThree *rechargeThree = [[MSRechargeThree alloc] init];
            rechargeThree.result = ERR_INVALID_STATE;
            [subscriber sendError:rechargeThree];
            return nil;
        }];
    }
    return [_protocol queryChargeThreeStepRechargeNo:self.payCache.rechargeSeqNumber vCode:verifyCode];
}

- (RACSignal *)queryWithdrawConfig {
    return [_protocol queryWithdrawConfig];
}

- (RACSignal *)withdrawWithAmount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword {
    // TODO: amount type should changed to decimal.
    return [_protocol queryDrawcash:amount.stringValue password:payPassword];
}

- (RACSignal *)investWithLoanId:(NSNumber *)loanId redEnvelopeId:(NSString *)redEnvelopeId amount:(NSDecimalNumber *)amount payPassword:(NSString *)payPassword {
    // TODO: data type issue.
    return [_protocol queryNewInvestLoadId:loanId.stringValue redBagId:redEnvelopeId password:payPassword money:amount.stringValue];
}

- (RACSignal *)buyDebtOfId:(NSNumber *)debtId payPassword:(NSString *)payPassword {
    // TODO: data type issue.
    return [_protocol queryBuyDebt:debtId.stringValue password:payPassword];
}

- (RACSignal *)purchaseCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    return [_protocol purchaseCurrentWithID:currentID amount:amount password:payPassword];
}

- (RACSignal *)redeemCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    return [_protocol redeemCurrentWithID:currentID amount:amount password:payPassword];
}

@end

#pragma mark - MSPayCache
@implementation MSPayCache : NSObject

@end
