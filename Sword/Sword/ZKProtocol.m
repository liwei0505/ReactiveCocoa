//
//  ZKProtocol.m
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "ZKProtocol.h"
#import "MSUrlManager.h"
#import "MSConsts.h"
#import "MSDeviceUtils.h"
#import "NSString+Ext.h"
#import "MSTextUtils.h"
#import "MSLog.h"
#import "BannerInfo.h"
#import "InvestInfo.h"
#import "InvestRecord.h"
#import "AccountInfo.h"
#import "DebtTradeInfo.h"
#import "FundsFlow.h"
#import "GoodsInfo.h"
#import "FriendInfo.h"
#import "FundsFlow.h"
#import "MessageInfo.h"
#import "NoticeInfo.h"
#import "UserPoint.h"
#import "PointRecord.h"
#import "ProjectInfo.h"
#import "RedEnvelope.h"
#import "SystemConfigs.h"
#import "UserPoint.h"
#import "UpdateInfo.h"
#import "TimeUtils.h"
#import "ZKSessionManager.h"
#import "MJSStatistics.h"
#import "DebtAgreementInfo.h"
#import "BankInfo.h"
#import "MSDrawCash.h"
#import "MSSubmitInvest.h"
#import "MSBuyDebt.h"
#import "MSRechargeOne.h"
#import "MSRechargeTwo.h"
#import "MSRechargeThree.h"
#import "MSConfig.h"
#import "RACError.h"
#import "InviteCode.h"
#import "MSPushManager.h"
#import "MSNotificationHelper.h"
#import "NSMutableDictionary+nilObject.h"
#import "NSString+Ext.h"
#import "MSFormText.h"
#import "MSFormFile.h"

#define  LIMIT_TIME  600
@interface ZKProtocol()
{
    ZKSessionManager *_httpService;
}

@end

@implementation ZKProtocol

- (instancetype)initWithSessionManager:(ZKSessionManager *)sessionManager {
    if (self = [super init]) {
        _httpService = sessionManager;
    }
    return self;
}

//根据不同的aim判断获取验证码类型
- (RACSignal *)queryVerifyCodeByPhoneNumber:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim {
    NSString *messageId = @"getVerifyCode";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:phoneNumber forKey:@"phoneNumber"];
    [params setObject:[NSNumber numberWithInteger:aim] forKey:@"aim"];
    [params setObject:messageId forKey:@"messageId"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                int resAim = [[response objectForKey:@"aim"] intValue];
                if (resAim != aim) {
                    LOGW(@"Not the requested response, orig = %ld, curr = %d", (long)aim, resAim);
                }
                [subscriber sendCompleted];
            } else {
                switch (reqResult.result) {
                    case 2: // 不支持的短信类型
                        reqResult.result = ERR_NOT_SUPPORT;
                        break;
                    case 3: // 该手机号已经被注册
                        reqResult.result = ERR_ALREADY_EXISTS;
                        break;
                    case 4: // 短信验证码获取次数过多，请稍候重试
                        reqResult.result = ERR_TOO_FREQUENT;
                        break;
                    case 5: // 用户不存在
                        reqResult.result = ERR_NOT_EXISTS;
                        break;
                    default:
                        break;
                }
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)registerWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode {
    NSString *messageId = @"register";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"3" forKey:@"channel"]; // 3: iOS
    [params setObject:phoneNumber forKey:@"phonenumber"];
    [params setObject:password forKey:@"password"];
    [params setObject:verifyCode forKey:@"vfcode"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                [subscriber sendCompleted];
            } else {
                if (reqResult.result == 4) { // 已注册
                    reqResult.result = ERR_ALREADY_EXISTS;
                }
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)resetLoginPasswordWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password verifyCode:(NSString *)verifyCode {
    NSString *messageId = @"resetPassword";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:phoneNumber forKey:@"phonenumber"];
    [params setObject:password forKey:@"password"];
    [params setObject:verifyCode forKey:@"vfcode"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)loginWithUserName:(NSString *)userName password:(NSString *)password {
    NSString *messageId = @"login";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userName forKey:@"loginname"];
    [params setObject:password forKey:@"password"];
    [params setObject:[MSDeviceUtils getUUID] forKey:@"imei"];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:@1 forKey:@"ostype"];

    NSString *token = [[MSPushManager getInstance] getDeviceToken];
    if (token) {
        [params setObject:token forKey:@"cid"];
    }
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                MSLoginInfo *loginInfo = [[MSLoginInfo alloc] init];
                loginInfo.userName = userName;
                loginInfo.password = password;
                NSString *userId = [response objectForKey:@"userId"];
                loginInfo.userId = [NSNumber numberWithInteger:userId.integerValue];
                int riskType = [[response objectForKey:@"riskTestType"] intValue];
                [MJSStatistics setUserID:userId];
                loginInfo.riskType = [self getRealType:riskType];
                [subscriber sendNext:loginInfo];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (void)logout {
    [_httpService resetSession];
}

- (RACSignal *)changePasswordWithUserName:(NSString *)userName origPassword:(NSString *)origPassword newPassword:(NSString *)newPassword {
    NSString *messageId = @"changePassword";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userName forKey:@"loginname"];
    [params setObject:origPassword forKey:@"origpassword"];
    [params setObject:newPassword forKey:@"newpassword"];
    [params setObject:messageId forKey:@"messageId"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryRiskAssessment
{
    NSString *messageId = @"getRiskAssessment";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            RACError *reqResult = [self getResult:result fromResponse:response];
            
            NSMutableArray *arr = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                for (NSDictionary *dic in response[@"riskAssessmentList"]) {
                    RiskInfo *info = [[RiskInfo alloc] init];
                    info.questionId = dic[@"queId"];
                    info.icon = dic[@"queImgUrl"];
                    info.title = dic[@"queTitle"];
                    
                    NSArray *options = [dic[@"choosMap"] jsonToObject];
                    for (NSDictionary *option in options) {
                        RiskDetailInfo *detailInfo = [[RiskDetailInfo alloc] init];
                        detailInfo.answerId = option[@"id"];
                        detailInfo.answer = option[@"question"];
                        NSString *order = option[@"letternum"];
                        if (order && order.length > 0) {
                            detailInfo.order = [order characterAtIndex:0];
                        }else{
                            [MSLog warning:@"Order is nil."];
                        }
                        [info.riskDetailInfoArr addObject:detailInfo];
                    }
                    [info.riskDetailInfoArr sortUsingComparator:^NSComparisonResult(RiskDetailInfo* _Nonnull obj1, RiskDetailInfo*  _Nonnull obj2) {
                        return (obj1.order > obj2.order) ? 1 : (obj1.order == obj2.order) ? 0 : -1;
                    }];
                    [arr addObject:info];
                }
                
                [subscriber sendNext:arr];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)commitRiskAssessment:(NSArray *)commitList
{
    NSString *messageId = @"commitRiskAssessment";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:commitList forKey:@"commitList"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            RACError *reqResult = [self getResult:result fromResponse:response];
            RiskResultInfo *resultInfo = nil;
            if (reqResult.result == ERR_NONE) {
                resultInfo = [[RiskResultInfo alloc] init];
                resultInfo.desc = response[@"desc"];
                resultInfo.icon = response[@"imgUrl"];
                resultInfo.title = response[@"typeName"];
                NSInteger type = [response[@"type"] integerValue];
                resultInfo.type = [self getRealType:type];
                if (resultInfo.type == EVALUATE_UNKNOWN) {
                    resultInfo.title = @"未知型";
                    resultInfo.desc = @"本版本暂不支持该类型";
                }
                
                [subscriber sendNext:resultInfo];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RiskType)getRealType:(NSInteger)type
{
    if (type == 0) {
        return  EVALUATE_NOT;
    }else if (type == 2){
        return  EVALUATE_OLD;
    }else if (type == 3){
        return  EVALUATE_STEADY;
    }else if (type == 4){
        return  EVALUATE_RISK;
    }else{
        return  EVALUATE_UNKNOWN;
    }
}

- (RACSignal *)getRiskConfigueWithRiskType:(int)type
{
    NSString *messageId = @"getRiskConf";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSString stringWithFormat:@"%d",type] forKey:@"riskTestType"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            RACError *reqResult = [self getResult:result fromResponse:response];
            RiskResultInfo *resultInfo = nil;
            if (reqResult.result == ERR_NONE) {
                resultInfo = [[RiskResultInfo alloc] init];
                resultInfo.desc = response[@"desc"];
                resultInfo.icon = response[@"imgUrl"];
                resultInfo.title = response[@"typeName"];
                NSInteger type = [response[@"type"] integerValue];
                resultInfo.type = [self getRealType:type];
                if (resultInfo.type == EVALUATE_UNKNOWN) {
                    resultInfo.title = @"未知型";
                    resultInfo.desc = @"本版本暂不支持该类型";
                }
                
                [subscriber sendNext:resultInfo];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (NSString *)getInvestAgreementById:(NSNumber *)debtId
{
    return  [_httpService getInvestAgreementById:debtId];
}

- (NSString *)setSessionForURL:(NSString *)url {
    return [_httpService setSessionFor:url];
}

//获取账户信息
- (RACSignal *)queryMyAccountInfo {
    NSString *messageId = @"getMyAccount";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                AccountInfo *accountInfo = [AccountInfo new];
                accountInfo.uId = [[response objectForKey:@"userId"] intValue];
                accountInfo.phoneNumber = [response objectForKey:@"phonenumber"];
                accountInfo.nickName = accountInfo.phoneNumber;
                accountInfo.realName = [response objectForKey:@"realName"];
                accountInfo.idcardNum = [response objectForKey:@"idCard"];
                accountInfo.investCount = [[response objectForKey:@"investCount"] intValue];

                NSInteger bindStatus = [[response objectForKey:@"bindStatus"] integerValue];
                accountInfo.payStatus = bindStatus == 1 ? STATUS_PAY_NO_PASSWORD : STATUS_PAY_NOT_REGISTER;
                if (bindStatus == 1) {
                    NSInteger tradePasswordStatus = [[response objectForKey:@"tradePasswordStatus"] integerValue];
                    accountInfo.payStatus = tradePasswordStatus == 1 ? STATUS_PAY_PASSWORD_SET : STATUS_PAY_NO_PASSWORD;
                }

                accountInfo.cardId = [response objectForKey:@"bankCardNo"];
                accountInfo.bankId = [response objectForKey:@"bankId"];
                accountInfo.cardBindPhone = [response objectForKey:@"cardBindPhoneNumber"];
                
                accountInfo.canUseRedEnvelopeNumber = [[response objectForKey:@"redMoneyNum"] integerValue];

                [subscriber sendNext:accountInfo];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

//投资记录
- (RACSignal *)queryMyInvestListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize status:(InvestStatus)status type:(ListRequestType)type {
    NSString *messageId = @"searchMyInvestList";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageSize] forKey:@"pagesize"];
    [params setObject:[NSNumber numberWithInt:status] forKey:@"searchtype"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            int total = 0;
            NSMutableArray *investList = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                total = [[response objectForKey:@"totalrows"] intValue];
                NSArray *list = [response objectForKey:@"investList"];
                for (NSDictionary *dict in list) {
                    InvestInfo *info = [InvestInfo new];
                    info.investId = [[dict objectForKey:@"id"] intValue];
                    info.endDate = [dict objectForKey:@"endtime"];
                    info.investAmount = [[dict objectForKey:@"investamount"] doubleValue];
                    info.investDate = [dict objectForKey:@"investdate"];
                    info.netIncome = [[dict objectForKey:@"netincome"] doubleValue];
                    info.nextAmount = [[dict objectForKey:@"nextamount"] doubleValue];
                    info.nextRepayDate = [dict objectForKey:@"nextrepaydate"];
                    info.productType = [dict objectForKey:@"producttype"];
                    info.repayedAmount = [[dict objectForKey:@"repayedamount"] doubleValue];
                    info.repayDate = [[dict objectForKey:@"paymentTime"] doubleValue];

                    info.loanInfo.loanId = [[dict objectForKey:@"loanid"] intValue];
                    info.loanInfo.title = [dict objectForKey:@"title"];
                    info.loanInfo.interest = [[dict objectForKey:@"interest"] doubleValue];
                    info.loanInfo.progress = [[dict objectForKey:@"progress"] doubleValue];
                    info.loanInfo.statusName = [dict objectForKey:@"status"];
                    info.loanInfo.termInfo.termCount = [[dict objectForKey:@"termCount"] intValue];
                    info.loanInfo.termInfo.unitType = [[dict objectForKey:@"termUnit"] intValue];
                    info.loanInfo.termInfo.monthPerTerm = [[dict objectForKey:@"monthCount"] intValue];
                    info.loanInfo.termInfo.yearRadix = [[dict objectForKey:@"yearradix"] intValue];
                    info.loanInfo.raiseBeginTime = [[dict objectForKey:@"intervalOpenTime"] doubleValue];
                    info.loanInfo.raiseEndTime = [[dict objectForKey:@"intervalOpenEndTime"] doubleValue];
                    if (LOAN_STATUS_INVEST_NOW == info.loanInfo.status) {
                        info.loanInfo.deadline = info.loanInfo.raiseBeginTime;
                    } else if (LOAN_STATUS_WILL_START == info.loanInfo.status) {
                        info.loanInfo.deadline = info.loanInfo.raiseEndTime;
                    }
                    info.loanInfo.type = [[dict objectForKey:@"type"] intValue];;

                    NSString *temp = [response objectForKey:@"subjectamount"];
                    if ([MSTextUtils isEmpty:temp]) {
                        info.loanInfo.subjectAmount = 0.0;
                    } else {
                        info.loanInfo.subjectAmount = [[temp stringByReplacingOccurrencesOfString:@"元" withString:@""] doubleValue];
                    }
                    [investList addObject:info];
                }
                
                NSDictionary *dic = @{TYPE : @(type), LIST : investList, TOTALCOUNT : @(total), STATUS : @(status)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyDebtListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize statuses:(NSInteger)statuses type:(ListRequestType)type{

    NSString *messageId = @"searchMyDebtList";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageSize] forKey:@"pagesize"];
    NSInteger zkStatus = [self convertDebtStatusesToZKStatus:statuses];
    [params setObject:[NSNumber numberWithInteger:zkStatus] forKey:@"searchtype"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            int total = 0;
            NSMutableArray *myDebtList = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                total = [[response objectForKey:@"totalrows"] intValue];
                NSArray *list = [response objectForKey:@"debtList"];
                for (NSDictionary *dict in list) {
                    DebtTradeInfo *info = [DebtTradeInfo new];
                    info.debtInfo.debtId = [[dict objectForKey:@"debtid"] intValue];
                    info.debtInfo.annualInterestRate = [dict objectForKey:@"annualinterestrate"];
                    info.debtInfo.leftTermCount = [[dict objectForKey:@"lefttermcount"] intValue];
                    info.debtInfo.termCount = [dict objectForKey:@"lefttermcount"];

                    NSString *price = [dict objectForKey:@"soldprice"];
                    if (price) {
                        info.debtInfo.soldPrice = [price stringByReplacingOccurrencesOfString:@"元" withString:@""];
                    } else {

                        info.debtInfo.soldPrice = @"";
                    }

                    info.debtInfo.nextRepayDate = [dict objectForKey:@"nextrepaydate"];
                    NSString *value = [dict objectForKey:@"value"];
                    if (value) {
                        info.debtInfo.value = [value stringByReplacingOccurrencesOfString:@"元" withString:@""];
                    } else {
                        info.debtInfo.value = @"";
                    }
                    info.debtInfo.nextAmount = [dict objectForKey:@"nextamount"];
                    info.debtInfo.canBeTrasfer = [[dict objectForKey:@"isTransferred"] intValue];
                    info.debtInfo.fee = [dict objectForKey:@"fee"];
                    int status = [[dict objectForKey:@"status"] intValue];
                    if (status == 200) {
                        info.debtInfo.status = STATUS_TRANSFERRING;
                    } else if (status == 300) {
                        info.debtInfo.status = STATUS_TRANSFERRED;
                    } else {
                        info.debtInfo.status = statuses;
                    }

                    info.debtInfo.loanInfo.baseInfo.loanId = [[dict objectForKey:@"loanid"] intValue];
                    info.debtInfo.loanInfo.baseInfo.title = [dict objectForKey:@"title"];
                    info.debtInfo.loanInfo.baseInfo.status = status;
                    info.debtInfo.loanInfo.baseInfo.type = [[dict objectForKey:@"type"] intValue];

                    info.debtInfo.loanInfo.borrowId = [[dict objectForKey:@"borrowid"] intValue];
                    info.debtInfo.loanInfo.repayType = [dict objectForKey:@"repaytype"];

                    info.tradeDate = [dict objectForKey:@"tradeTime"];
                    info.investDate = [dict objectForKey:@"investTime"];
                    info.incomingInterest = [[dict objectForKey:@"toBeCollectedInterest"] doubleValue];
                    info.incomingPrincipal = [[dict objectForKey:@"toBeCollectedPrincipal"] doubleValue];
                    info.receivedPrincipal = [[dict objectForKey:@"collectedPrincipal"] doubleValue];
                    info.receivedInterest = [[dict objectForKey:@"collectedInterest"] doubleValue];

                    [myDebtList addObject:info];
                }
                
                NSDictionary *dic = @{TYPE : @(type), LIST : myDebtList, TOTALCOUNT : @(total), STATUS : @(statuses)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyFundsFlowWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize recordType:(FlowType)type timeType:(Period)time requestType:(ListRequestType)requestType{
    
    NSString *messageId = @"searchMoneyRecordList";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageSize] forKey:@"pagesize"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"recordtype"];
    [params setObject:[NSNumber numberWithInt:time] forKey:@"timetype"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            int total = 0;
            if (reqResult.result == ERR_NONE) {
                NSMutableArray *fundsflowList = [NSMutableArray array];
                total = [[response objectForKey:@"totalrows"] intValue];
                NSArray *list = [response objectForKey:@"moneyRecordList"];
                for (NSDictionary *dict in list) {
                    FundsFlow *info = [FundsFlow new];
                    info.type = [[dict objectForKey:@"recordtype"] intValue];
                    info.typeName = [dict objectForKey:@"recordtypename"];
                    info.target = [dict objectForKey:@"loantitle"];

                    NSString *date = [dict objectForKey:@"createtime"];
                    NSRange range = [date rangeOfString:@" "];
                    info.tradeDate = [date substringToIndex:range.location];

                    NSString *temp = [dict objectForKey:@"amount"];
                    info.tradeAmount = [[temp stringByReplacingOccurrencesOfString:@"元" withString:@""] doubleValue];
                    [fundsflowList addObject:info];
                }
                
                NSDictionary *dic = @{TYPE : @(requestType), TOTALCOUNT :@(total), LIST : fundsflowList};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyRedEnvelopeListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize status:(RedEnvelopeStatus)status type:(ListRequestType)requestType{
    NSString *messageId = @"getRedMoneyList";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageSize] forKey:@"pagesize"];
    [params setObject:[NSNumber numberWithInt:status] forKey:@"redtype"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            int total = 0;
            if (reqResult.result == ERR_NONE) {
                NSMutableArray *myRedEnvelopeList = [NSMutableArray array];
                total = [[response objectForKey:@"totalrows"] intValue];
                NSArray *list = [response objectForKey:@"redMoneyList"];
                for (NSDictionary *dict in list) {
                    RedEnvelope *envelope = [RedEnvelope new];
                    envelope.amount = [[dict objectForKey:@"amount"] doubleValue];
                    envelope.receiveDate = [dict objectForKey:@"recievedate"];

                    NSRange range;
                    NSString *dateBegin = [dict objectForKey:@"startdate"];
                    range = [dateBegin rangeOfString:@" "];
                    envelope.beginDate = [dateBegin substringToIndex:range.location];

                    NSString *dateEnd = [dict objectForKey:@"enddate"];
                    range = [dateEnd rangeOfString:@" "];
                    envelope.endDate = [dateEnd substringToIndex:range.location];

                    envelope.usageRange = [dict objectForKey:@"userange"];
                    envelope.requirement = [[dict objectForKey:@"requirement"] doubleValue];
                    envelope.type = [self convertStringToRedEnvelopeType:[dict objectForKey:@"way"]];
                    envelope.status = [dict objectForKey:@"status"];
                    envelope.name = [dict objectForKey:@"name"];
                    [myRedEnvelopeList addObject:envelope];
                }
                
                NSDictionary *dic = @{TYPE : @(requestType), TOTALCOUNT : @(total), LIST: myRedEnvelopeList, STATUS: @(status)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyPoints {

    NSString *messageId = @"getUserScore";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                UserPoint *point = [UserPoint new];
                point.totalPoints = [[response objectForKey:@"totalpoints"] intValue];
                point.usedPoints = [[response objectForKey:@"usedpoints"] intValue];
                point.freezePoints = [[response objectForKey:@"freezepoints"] intValue];
                point.expendPoints = [[response objectForKey:@"expendpoints"] intValue];

                [subscriber sendNext:point];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryMyPointListWithPageIndex:(NSUInteger)pageIndex pageSize:(NSUInteger)pageSize type:(ListRequestType)type {
    NSString *messageId = @"getScoreList";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithUnsignedLong:pageSize] forKey:@"pagesize"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            int total = 0;
            if (reqResult.result == ERR_NONE) {
                total = [[response objectForKey:@"totalrows"] intValue];
                NSMutableArray *pointDetailList = [NSMutableArray array];
                NSArray *list = [response objectForKey:@"scoreList"];
                for (NSDictionary *dict in list) {
                    PointRecord *record = [PointRecord new];
                    record.pointName = [dict objectForKey:@"pointsname"];
                    record.receivedDate = [dict objectForKey:@"time"];
                    record.status = [dict objectForKey:@"status"];
                    record.point = [[dict objectForKey:@"points"] intValue];
                    [pointDetailList addObject:record];
                }
                
                NSDictionary *dic  = @{TYPE : @(type), TOTALCOUNT : @(total), LIST : pointDetailList};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

// 获取广告列表
- (RACSignal *)queryBannerList {
    NSString *messageId = @"getBannerList";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            NSMutableArray *bannerList = nil;
            if (reqResult.result == ERR_NONE) {
                bannerList = [[NSMutableArray alloc] init];
                NSArray *jsonArray = [response objectForKey:@"bannerList"];
                for (NSDictionary *jsonObj in jsonArray) {
                    BannerInfo *bannerInfo = [[BannerInfo alloc] init];
                    bannerInfo.bannerUrl = [jsonObj objectForKey:@"bannerurl"];
                    bannerInfo.link = [jsonObj objectForKey:@"link"];
                    [bannerList addObject:bannerInfo];
                }
            }
            if (bannerList && bannerList.count > 0) {
                [subscriber sendNext:bannerList];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

// 获取推荐列表
- (RACSignal *)queryRecommendedList {
    int pageIndex = 1;
    int pageSize = 5;
    return [self doQueryInvestList:pageIndex size:pageSize recommended:YES type:0];
}

// 获取投资列表
- (RACSignal *)queryInvestList:(int)pageIndex size:(int)pageSize type:(NSInteger)type{
    return [self doQueryInvestList:pageIndex size:pageSize recommended:NO type:type];
}

// 获取投资列表 pagesize页记录数pageIndex页数
- (RACSignal *)doQueryInvestList:(int)pageIndex size:(int)pageSize recommended:(BOOL)recommended type:(NSInteger)type{
    NSString *messageId = recommended ? @"searchIndexLoanList" : @"searchLoanList";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"pagesize"];
    [params setObject:[NSNumber numberWithInt:recommended ? 0 : 1] forKey:@"isindex"];
    [params setObject:@50 forKey:@"searchname"]; // 50:进度
    [params setObject:recommended ? @1 : @0 forKey:@"searchtype"]; // 0:全部，1:筹款中
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            int total = 0;
            NSMutableArray *investList = [NSMutableArray array];
            if (result == ERR_NONE) {
                total = [[response objectForKey:@"totalrows"] intValue];
                NSArray *jsonArray = [response objectForKey:@"investList"];
                NSUInteger count = jsonArray.count;
                for (int i = 0; i < count; ++i) {
                    NSDictionary *jsonInvest = [jsonArray objectAtIndex:i];
                    LoanInfo *investInfo = [LoanInfo new];
                    investInfo.loanId = [[jsonInvest objectForKey:@"loanid"] intValue];
                    investInfo.title = [jsonInvest objectForKey:@"title"];
                    
                    investInfo.progress = [[jsonInvest objectForKey:@"progress"] doubleValue];
                    investInfo.interest = [[jsonInvest objectForKey:@"interest"] doubleValue];
                    investInfo.startAmount = [[jsonInvest objectForKey:@"beginamount"] intValue];
                    investInfo.classify = [[jsonInvest objectForKey:@"classify"] intValue];
                    investInfo.termInfo.termCount = [[jsonInvest objectForKey:@"termCount"] intValue];
                    investInfo.termInfo.unitType = [[jsonInvest objectForKey:@"termUnit"] intValue];
                    investInfo.termInfo.monthPerTerm = [[jsonInvest objectForKey:@"monthCount"] intValue];
                    investInfo.termInfo.yearRadix = [[jsonInvest objectForKey:@"yearradix"] intValue];
                    investInfo.redEnvelopeTypes = [self convertWayToRedEnvelopeTypes:jsonInvest[@"loanpic"]];
                    investInfo.subjectAmount = [[jsonInvest objectForKey:@"subjectamount"] doubleValue];
                    investInfo.maxInvestLimit = [[jsonInvest objectForKey:@"limitmoney"] doubleValue];
                    
                    NSInteger status = [[jsonInvest objectForKey:@"status"] integerValue];
                    switch (status) {
                        case 300: {
                            investInfo.status = LOAN_STATUS_INVEST_NOW;
                        } break;
                        case 301: {
                            investInfo.status = LOAN_STATUS_WILL_START;
                        } break;
                        case 302:
                        case 400:
                        case 600: {
                            investInfo.status = LOAN_STATUS_COMPLETED;
                        } break;
                        case 500:
                        case 550: {
                            investInfo.status = LOAN_STATUS_INVEST_END;

                        } break;
                        default: {
                            investInfo.status = LOAN_STATUS_INVEST_END;
                            [MSLog warning:@"Unknown loan status: %d", status];
                        } break;
                    }

                    investInfo.raiseBeginTime = [[jsonInvest objectForKey:@"intervalOpenTime"] doubleValue];
                    investInfo.raiseEndTime = [[jsonInvest objectForKey:@"intervalOpenEndTime"] doubleValue];
                    if (LOAN_STATUS_INVEST_NOW == investInfo.status) {
                        investInfo.deadline = investInfo.raiseBeginTime;
                    } else if (LOAN_STATUS_WILL_START == investInfo.status) {
                        investInfo.deadline = investInfo.raiseEndTime;
                    }
                    
                    investInfo.statusName = [jsonInvest objectForKey:@"statusName"];
                    double temp = [[jsonInvest objectForKey:@"salesRate"] doubleValue];
                    if (temp) {
                        investInfo.salesRate = temp;
                    }
                    [investList addObject:investInfo];
                }
            }
            if (recommended) {
                if (result == ERR_NONE) {
                    [subscriber sendNext:investList];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:reqResult];
                }
            } else {
                if (result == ERR_NONE) {
                    NSDictionary *dic = @{TYPE : @(type), LIST : investList, TOTALCOUNT : @(total)};
                    [subscriber sendNext:dic];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:reqResult];
                }
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryLoanDetail:(int)loanId {

    NSString *messageId = @"searchLoanDetail";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:loanId] forKey:@"loanid"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            LoanDetail *detailInfo = nil;
            if (reqResult.result == ERR_NONE) {
                detailInfo = [LoanDetail new];
                detailInfo.baseInfo.loanId = [[response objectForKey:@"loanid"] intValue];
                detailInfo.baseInfo.title = [response objectForKey:@"title"];
                
                detailInfo.baseInfo.progress = [[response objectForKey:@"progress"] doubleValue];
                
                detailInfo.baseInfo.interest = [[response objectForKey:@"interest"] doubleValue];
                detailInfo.baseInfo.status = [[response objectForKey:@"status"] intValue];
                
                detailInfo.baseInfo.statusName = [response objectForKey:@"statusName"];
                detailInfo.baseInfo.startAmount = [[response objectForKey:@"beginamount"] intValue];
                detailInfo.baseInfo.classify = [[response objectForKey:@"classify"] intValue];
                NSString *isWay = [response objectForKey:@"isWay"];
                detailInfo.baseInfo.redEnvelopeTypes = (int)[self convertWayToRedEnvelopeTypes:isWay];
                detailInfo.borrowId = [[response objectForKey:@"borrowid"] intValue];
                NSString *temp = [response objectForKey:@"amount"];
                if ([MSTextUtils isEmpty:temp]) {
                    detailInfo.totalAmount = 0.0;
                } else {
                    detailInfo.totalAmount = [[temp stringByReplacingOccurrencesOfString:@"元" withString:@""] doubleValue];
                }
                temp = nil;
                detailInfo.safeType = [response objectForKey:@"safetype"];
                detailInfo.repayType = [response objectForKey:@"repaytype"];
                detailInfo.repayNumber = [response objectForKey:@"repayNumber"];
                detailInfo.monthlyAmount = [response objectForKey:@"monthlyamount"];
                detailInfo.prepayment = [response objectForKey:@"prepayment"];
                
                temp = [response objectForKey:@"subjectamount"];
                if ([MSTextUtils isEmpty:temp]) {
                    detailInfo.baseInfo.subjectAmount = 0.0;
                } else {
                    detailInfo.baseInfo.subjectAmount = [[temp stringByReplacingOccurrencesOfString:@"元" withString:@""] doubleValue];
                }
                temp = nil;
                
                detailInfo.increaseAmount = [[response objectForKey:@"increaseamount"] integerValue];
                detailInfo.baseInfo.maxInvestLimit = [[response objectForKey:@"limitmoney"] doubleValue];
                detailInfo.countdownName = [response objectForKey:@"countdownName"];
                detailInfo.countdownNumber = [[response objectForKey:@"countdownNumber"] integerValue];
                detailInfo.baseInfo.deadline = [TimeUtils date].timeIntervalSince1970 + detailInfo.countdownNumber / 1000.0;
                
                detailInfo.interestBeginTime = [response objectForKey:@"interestStartTime"];
                detailInfo.interestEndTime = [response objectForKey:@"interestEndTime"];
                detailInfo.debtCloseDays = [response objectForKey:@"debtClosedDays"];
                detailInfo.contractName = [response objectForKey:@"contractName"];
                detailInfo.rate = [[response objectForKey:@"salesRate"] doubleValue];
                
                detailInfo.fullTime = [[response objectForKey:@"fullTime"] doubleValue];
                detailInfo.loanInvestorTotalCount = [[response objectForKey:@"loanInvestorCount"] integerValue];

                detailInfo.loanLimit = [[response objectForKey:@"limitType"] unsignedIntegerValue];
            }
            
            if (detailInfo) {
                [subscriber sendNext:detailInfo];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryMyInvestedAmount:(NSNumber *)loanId {
    NSString *messageId = @"searchInvestMoney";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:loanId forKey:@"loanid "];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                NSDecimalNumber *investedAmount = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"investMoney"]];
                [subscriber sendNext:investedAmount];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

//项目说明
- (RACSignal *)queryProjectInstruction:(int)loanId type:(int)type {
    
    NSString *messageId = @"getProdectDescByLoanid";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:loanId] forKey:@"loanid"];
    [params setObject:[self convertProjectInstructionTypeToProtocolType:type] forKey:@"type"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            NSArray *dataArr = nil;
            NSString *content = nil;
            if (reqResult.result == ERR_NONE) {
                
                content = [response objectForKey:@"content"];
                NSArray *fileArr = response[@"loanProjectDocList"];
                NSMutableArray *fileInfoArr = [NSMutableArray array];
                for (NSDictionary *dic in fileArr) {
                    ProductFileInfo *fileInfo = [[ProductFileInfo alloc] init];
                    fileInfo.fileName = dic[@"filename"];
                    fileInfo.filepath = dic[@"path"];
                    NSLog(@"%@",fileInfo.filepath);
                    [fileInfoArr addObject:fileInfo];
                }
                if (fileInfoArr && fileInfoArr.count > 0) {
                    dataArr = fileInfoArr;
                }
            }
            
            BOOL isHasContent = content && content.length > 0;
            BOOL isHasDataArr = dataArr && dataArr.count > 0;
            
            if (isHasContent || isHasDataArr) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[TYPE] = @(type);
                dic[LOANID] = @(loanId);
                if (isHasContent) {
                    dic[CONTENT] = content;
                }
                if (isHasDataArr) {
                    dic[LIST] = dataArr;
                }
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

//合同模版
- (RACSignal *)queryContractTemplate:(int)loanId {

    NSString *messageId = @"getContractbByLoaid";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:loanId] forKey:@"loanid"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            NSString *content = [[NSString alloc] init];
            if (reqResult.result == ERR_NONE) {
                content = [response objectForKey:@"content"];
            }
            
            if (content && content.length > 0) {
                NSDictionary *dic = @{CONTENT : content, TYPE : @(INSTRUCTION_TYPE_INVEST_CONTRACT), LOANID : @(loanId)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

//投资记录
- (RACSignal *)queryInvestRecordList:(int)lastInvestorId size:(int)pageSize loanId:(int)loanId {

    NSString *messageId = @"searchInvestListByLoanid";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (lastInvestorId > 0) {
        [params setObject:[NSNumber numberWithInt:lastInvestorId] forKey:@"maxId"];
    }
    [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"pagesize"];
    [params setObject:[NSNumber numberWithInt:loanId] forKey:@"loanid"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            NSMutableArray *investList = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                NSArray *lists = [response objectForKey:@"investList"];
                for (NSDictionary *dict in lists) {
                    InvestRecord *record = [InvestRecord new];
                    record.loadId = loanId;
                    record.inverstorId = [[dict objectForKey:@"id"] intValue];
                    record.investor = [dict objectForKey:@"investor"];
                    record.createDateTime = [dict objectForKey:@"createtime"];
                    NSString *amount = [dict objectForKey:@"amount"];
                    record.amount = [amount stringByReplacingOccurrencesOfString:@"元" withString:@""];
                    [investList addObject:record];
                }
            }
            
            if (reqResult.result == ERR_NONE) {
                NSDictionary *dic = @{LIST : investList, LOANID : @(loanId)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

//投资可用红包列表
- (RACSignal *)queryRedEnvelopeListForLoanId:(NSNumber *)loanId investAmount:(NSDecimalNumber *)amount flag:(NSUInteger)flag {
    NSString *messageId = @"searchInvestRedMoneyList";

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:amount forKey:@"amount"];
    [params setObject:@0 forKey:@"type"];
    [params setObject:loanId forKey:@"loanid"];
    [params setObject:[self convertRedEnvelopeTypeToWay:flag] forKey:@"isWay"];
    [params setObject:@20 forKey:@"searchtype"];
    [params setObject:@"searchInvestRedMoneyList" forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];

            if (reqResult.result == ERR_NONE) {
                NSMutableArray *redEnvelopeLists = [NSMutableArray array];
                NSArray *lists = [response objectForKey:@"investRedMoneyList"];
                for (NSDictionary *dict in lists) {
                    RedEnvelope *envelope = [RedEnvelope new];
                    envelope.redId = [dict objectForKey:@"id"];
                    envelope.amount = [[dict objectForKey:@"amount"] doubleValue];
                    envelope.requirement = [[dict objectForKey:@"requirement"] doubleValue];
                    int way = [[dict objectForKey:@"way"] intValue];
                    envelope.type = [self convertIntToRedEnvelopeType:way];
                    envelope.usageRange = [dict objectForKey:@"userange"];
                    envelope.receiveDate = [dict objectForKey:@"recievedate"];
                    envelope.beginDate = [dict objectForKey:@"startdate"];
                    envelope.endDate = [dict objectForKey:@"enddate"];
                    [redEnvelopeLists addObject:envelope];
                }
                if (redEnvelopeLists && redEnvelopeLists.count > 0) {
                    RedEnvelope *envelope = [RedEnvelope new];
                    envelope.redId = nil;
                    envelope.usageRange = @"不使用红包";
                    [redEnvelopeLists insertObject:envelope atIndex:0];
                }
                [subscriber sendNext:redEnvelopeLists];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

//获取转让列表
- (RACSignal *)queryDebtList:(int)pageIndex size:(int)pageSize type:(NSInteger)type{
    NSString *messageId = @"searchDebtList";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"pagesize"];
    [params setObject:@50 forKey:@"searchname"]; // 50:进度
    [params setObject:@1 forKey:@"searchtype"]; // 0:倒叙，1:升序
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            int total = 0;
            NSMutableArray *debtList = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                total = [[response objectForKey:@"totalrows"] intValue];
                NSArray *lists = [response objectForKey:@"debtList"];
                for (NSDictionary *dict in lists) {
                    DebtInfo *info = [DebtInfo new];
                    info.debtId = [[dict objectForKey:@"debtid"] intValue];
                    info.loanInfo.baseInfo.loanId = [[dict objectForKey:@"loanid"] intValue];
                    info.borrowId = [[dict objectForKey:@"borrowid"] intValue];
                    info.loanInfo.baseInfo.type = [[dict objectForKey:@"type"] intValue];
                    info.loanInfo.baseInfo.title = [dict objectForKey:@"title"];
                    info.annualInterestRate = [dict objectForKey:@"annualinterestrate"];
                    info.leftTermCount = [[dict objectForKey:@"lefttermcount"] intValue];
                    NSString *soldPrice = [dict objectForKey:@"soldprice"];
                    info.soldPrice = [soldPrice stringByReplacingOccurrencesOfString:@"元" withString:@""];
                    info.nextAmount = [dict objectForKey:@"nextamount"];
                    info.loanInfo.repayType = [dict objectForKey:@"repaytype"];
                    info.status = [[dict objectForKey:@"status"] intValue];
                    info.earnings = [[dict objectForKey:@"tobetotalcollection"] doubleValue];
                    info.fee = [dict objectForKey:@"fee"];
                    [debtList addObject:info];
                }
            }
            
            if (reqResult.result == ERR_NONE) {
                NSDictionary *dic = @{TYPE : @(type), LIST : debtList, TOTALCOUNT : @(total)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryDebtDetail:(int)debtId {
    NSString *messageId = @"searchDebtDetail";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:debtId] forKey:@"debtid"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            DebtDetail *debtDetail = nil;
            if (reqResult.result == ERR_NONE) {
                debtDetail = [DebtDetail new];
                debtDetail.investorUserId = [[response objectForKey:@"investorUserId"] intValue];
                debtDetail.baseInfo.debtId = debtId;
                debtDetail.baseInfo.loanInfo.baseInfo.loanId = [[response objectForKey:@"loanid"] intValue];
                debtDetail.baseInfo.loanInfo.baseInfo.title = [response objectForKey:@"loantitle"];
                debtDetail.baseInfo.loanInfo.baseInfo.startAmount = [[response objectForKey:@"beginamount"] intValue];
                debtDetail.baseInfo.loanInfo.interestEndTime = [response objectForKey:@"interestEndTime"];
                debtDetail.baseInfo.value = [response objectForKey:@"debtValue"];
                debtDetail.baseInfo.leftTermCount = [[response objectForKey:@"debtDeadlineCount"] intValue];
                debtDetail.payAmount = [[response objectForKey:@"payAmount"] doubleValue];
                debtDetail.expectedRate = [[response objectForKey:@"debtExpectedRate"] doubleValue];
                debtDetail.expectedEarning = [[response objectForKey:@"debtExpectedEarning"] doubleValue];
                debtDetail.investType = [response objectForKey:@"investType"];
                debtDetail.subscribeLeftTime = [[response objectForKey:@"debtResidueTime"] integerValue];
                debtDetail.deadline = [TimeUtils date].timeIntervalSince1970 + debtDetail.subscribeLeftTime / 1000;
                debtDetail.repayDate = [response objectForKey:@"repayTime"];
                debtDetail.releaseDate = [response objectForKey:@"releaseTime"];
            }
            if (debtDetail) {
                [subscriber sendNext:debtDetail];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)sellDebt:(int)debtId discount:(double)discount {
    
    NSString *messageId = @"sellDebt";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:debtId] forKey:@"debtid"];
    [params setObject:[NSNumber numberWithDouble:discount] forKey:@"discount"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            
            if (reqResult.result == ERR_NONE) {
                [subscriber sendNext:@(debtId)];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];

}

- (RACSignal *)undoDebtSell:(int)debtId {
   
    NSString *messageId = @"unsellDebt";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:debtId] forKey:@"debtid"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            
            if (reqResult.result == ERR_NONE) {
                [subscriber sendNext:@(debtId)];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryNewNoticeList {
    
    NSString *messageId = @"getIdForNewCompanyNotice";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                NSNumber *noticeId = [response objectForKey:@"id"];
                [subscriber sendNext:noticeId ? noticeId : @(0)];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryCompanyNotice:(int)pageIndex size:(int)pageSize type:(int)type keywords:(NSString *)keywords requestType:(ListRequestType)requestType {

    NSString *messageId = @"getCompanyNotice";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"pagesize"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    if (keywords) {
        [params setObject:keywords forKey:@"searchText"];
    }
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:@0 forKey:@"id"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            int totalrows = 0;
            NSMutableArray *lists = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                totalrows = [[response objectForKey:@"totalrows"] intValue];
                NSArray *list = [response objectForKey:@"companyNoticeList"];
                for (NSDictionary *dict in list) {
                    NoticeInfo *info = [NoticeInfo new];
                    info.noticeId = [[dict objectForKey:@"id"] intValue];
                    info.title = [dict objectForKey:@"title"];
                    info.datetime = [dict objectForKey:@"time"];
                    info.content = [dict objectForKey:@"content"];
                    info.h5url = [dict objectForKey:@"h5url"];
                    [lists addObject:info];
                }
            }
            if (reqResult.result == ERR_NONE) {
                NSDictionary *dic = @{TOTALCOUNT : @(totalrows), LIST : lists, TYPE : @(requestType)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)feedback:(FeedbackInfo *)feedbackInfo {
    NSString *url = [NSString stringWithFormat:@"%@%@", [MSUrlManager getBaseUrl], @"appLog/addFeedback"];

    NSMutableArray *formItems = [[NSMutableArray alloc] init];
    MSFormText *suggestion = [[MSFormText alloc] init];
    suggestion.name = @"remarks";
    suggestion.text = feedbackInfo.suggestion;
    [formItems addObject:suggestion];

    MSFormText *contactInfo = [[MSFormText alloc] init];
    contactInfo.name = @"phone";
    contactInfo.text = feedbackInfo.contactInfo;
    [formItems addObject:contactInfo];

    MSFormFile *attachment = [[MSFormFile alloc] init];
    attachment.name = @"file";
    attachment.fileName = [NSString stringWithFormat:@"feedback_%lld_%@.zip", [TimeUtils currentTimeMillis], feedbackInfo.contactInfo];
    attachment.filePath = feedbackInfo.attachment;
    [formItems addObject:attachment];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [_httpService submitForm:url items:formItems result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryUnreadMessageCount {
    NSString *messageId = @"getUnReadMessageCount";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                NSNumber *unreadMsgCount = [response objectForKey:@"count"];
                [subscriber sendNext:unreadMsgCount ? unreadMsgCount : @(0)];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryMessageList:(int)lastId size:(int)pageSize requestType:(ListRequestType)requestType{

    NSString *messageId = @"getMessageInfoList";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (lastId > 0) {
        [params setObject:[NSNumber numberWithInt:lastId] forKey:@"maxId"];
    }
    [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"pagesize"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            int totalrows = 0;
            NSMutableArray *lists = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                totalrows = [[response objectForKey:@"totalrows"] intValue];
                NSArray *list = [response objectForKey:@"messageList"];
                for (NSDictionary *dict in list) {
                    MessageInfo *info = [MessageInfo new];
                    info.messageId = [[dict objectForKey:@"id"] intValue];
                    info.content = [dict objectForKey:@"content"];
                    info.status = [[dict objectForKey:@"isread"] intValue];
                    info.type = [dict objectForKey:@"messagetype"];
                    info.sendDate = [dict objectForKey:@"sendtime"];
                    [lists addObject:info];
                }
            }
            if (reqResult.result == ERR_NONE) {
                NSDictionary *dic = @{TOTALCOUNT : @(totalrows), LIST : lists, TYPE : @(requestType)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryProductList:(int)pageIndex size:(int)pageSize requestType:(ListRequestType)requestType{
    
    NSString *messageId = @"getScoreGoodsList";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:pageIndex] forKey:@"pageno"];
    [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"pagesize"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            int totalrows = 0;
            NSMutableArray *lists = [NSMutableArray array];
            if (reqResult.result == ERR_NONE) {
                totalrows = [[response objectForKey:@"totalrows"] intValue];
                NSArray *list = [response objectForKey:@"scoreGoodsList"];
                for (NSDictionary *dict in list) {
                    GoodsInfo *info = [GoodsInfo new];
                    info.goodId = [[dict objectForKey:@"id"] intValue];
                    info.name = [dict objectForKey:@"goodsname"];
                    info.pictureUrl = [dict objectForKey:@"picpath"];
                    info.points = [[dict objectForKey:@"points"] intValue];
                    info.datetime = [dict objectForKey:@"time"];
                    info.price = [[dict objectForKey:@"price"] doubleValue];
                    [lists addObject:info];
                }
            }
            
            if (reqResult.result == ERR_NONE) {
                NSDictionary *dic = @{TOTALCOUNT : @(totalrows), LIST : lists, TYPE : @(requestType)};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)exchange:(int)productId {

    NSString *messageId = @"scoreExchange";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:productId] forKey:@"id"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                reqResult.message = [response objectForKey:@"statusMessage"];
                [subscriber sendNext:reqResult];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryInviteCode:(ShareType)shareType {
    
    NSString *messageId = @"getInviteCode";    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:shareType] forKey:@"type"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:(shareType == SHARE_INVITE) params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            InviteCode *inviteCode = nil;
            if (reqResult.result == ERR_NONE) {
                inviteCode = [InviteCode new];
                inviteCode.desc = [response objectForKey:@"desc"];
                inviteCode.codeLink = [response objectForKey:@"code"];
                inviteCode.shareUrl = [response objectForKey:@"picName"];
                inviteCode.title = [response objectForKey:@"title"];
                
                [subscriber sendNext:inviteCode];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)queryMyInvitedFriendListWithLastFriendID:(NSNumber *)friendID size:(NSInteger)pageSize {
    NSString *messageId = @"getInviteFriendListByPage";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:friendID forKey:@"pageno"];
    [params setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pagesize"];
    // type: 0 - InviteInfo, 1 - Inivted friend list.
    [params setObject:[NSNumber numberWithInteger:(pageSize == 0) ? 0 : 1] forKey:@"type"];
    [params setObject:messageId forKey:@"messageId"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                if (pageSize > 0) {
                    NSArray *friends = [response objectForKey:@"inviteList"];
                    NSMutableArray *inviteFriendList = [NSMutableArray arrayWithCapacity:friends.count];
                    for (NSDictionary *friend in friends) {
                        FriendInfo *info = [FriendInfo new];
                        info.userID = [friend objectForKey:@"invitedInfoId"];
                        info.nickname = [friend objectForKey:@"nickname"];
                        info.inviteReward = [[friend objectForKey:@"redmoneyamount"] doubleValue];
                        info.registerDate = [TimeUtils convertToUTCTimestampFromString:[friend objectForKey:@"inviteeregdate"]];
                        info.status = [[friend objectForKey:@"statu"] integerValue];
                        info.rewardValid = [[friend objectForKey:@"moneystatus"] boolValue];
                        info.way = [[friend objectForKey:@"way"] integerValue];
                        info.redEnvelopeCount = [[friend objectForKey:@"redmoneysize"] integerValue];
                        info.totalReward = friend[@"totalReward"];
                        [inviteFriendList addObject:info];
                    }
                    [subscriber sendNext:inviteFriendList];
                } else {
                    InviteInfo *inviteInfo = [InviteInfo new];
                    inviteInfo.bannerLink = response[@"bannerLink"];
                    inviteInfo.inviteTitle = response[@"inviteTitle"];
                    inviteInfo.inviteContent = response[@"inviteContent"];
                    inviteInfo.inviteBanner = response[@"inviteBanner"];
                    inviteInfo.inviteCount = [[response objectForKey:@"invitenum"] intValue];
                    inviteInfo.inviteReward = [[response objectForKey:@"invitemoney"] doubleValue];

                    [subscriber sendNext:inviteInfo];
                }
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)sendReadMessageId:(int)msgId {

    NSString *messageId = @"readMessage";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:msgId] forKey:@"id"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            [subscriber sendNext:reqResult];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)checkUpdate {
    NSString *messageId = @"checkVersion";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@1 forKey:@"type"];
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    [params setObject:currentVersion forKey:@"currentVersion"];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];

            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                UpdateInfo *info = [[UpdateInfo alloc] init];
                info.desc = [response objectForKey:@"desc"];
                info.flag = [[response objectForKey:@"flag"] integerValue];
                info.url = [response objectForKey:@"url"];
                [subscriber sendNext:info];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)sendDeleteMessage:(int)msgId {

    NSString *messageId = @"deletMessage";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInt:msgId] forKey:@"id"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            [subscriber sendNext:reqResult];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];

}

- (RACSignal *)queryDebtAgreementInfo:(NSUInteger)debtId
{
    NSString *messageId = @"getDebtAgreement";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:[NSNumber numberWithInteger:debtId] forKey:@"debtid"];
    
    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            DebtAgreementInfo *agreementInfo = nil;
            if (reqResult.result == ERR_NONE) {
                agreementInfo = [DebtAgreementInfo new];
                agreementInfo.contractTitle = response[@"contractTitle"];
                agreementInfo.url = response[@"url"];
                
                [subscriber sendNext:agreementInfo];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)queryDrawcash:(NSString *)money password:(NSString *)password
{
    NSString *messageId = @"withdrawcash";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:money forKey:@"amount"];
    [params setObject:password forKey:@"paypassword"];
    
    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            
            NSLog(@"提现===%@",response);
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            MSDrawCash *drawCash = [[MSDrawCash alloc] init];
            if (result == ERR_NONE) {
                drawCash.canRetryCount = [response[@"canRetryCount"] intValue];
                drawCash.result = ERR_NONE;
            }else{
                drawCash.result = result;
            }
            drawCash.message = response[@"statusMessage"];
            
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (drawCash.result == ERR_NONE) {
                    [subscriber sendNext:drawCash.message];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:drawCash];
                }
            });
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryNewInvestLoadId:(NSString *)loanId redBagId:(NSString *)redBagId password:(NSString *)password money:(NSString *)money
{
    NSString *messageId = @"submitInvest";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:loanId forKey:@"loanId"];
    if (redBagId && redBagId.length > 0) {
        [params setObject:redBagId forKey:@"redbagId"];
    }
    [params setObject:password forKey:@"tradePassword"];
    [params setObject:money forKey:@"amount"];
    
    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            
            NSLog(@"投资===%@",response);
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            MSSubmitInvest *submitInvest = [[MSSubmitInvest alloc] init];
            if (result == ERR_NONE) {
                submitInvest.canRetryCount = [response[@"canRetryCount"] intValue];
                submitInvest.result = ERR_NONE;
            }else{
                submitInvest.result = result;
            }
            submitInvest.message = response[@"statusMessage"];
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (submitInvest.result == ERR_NONE) {
                    [subscriber sendNext:submitInvest.message];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:submitInvest];
                }
            });
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryBuyDebt:(NSNumber *)debtId password:(NSString *)password
{
    NSString *messageId = @"buyDebt";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:debtId forKey:@"debtid"];
    [params setObject:password forKey:@"tradePassword"];
    
    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            
            NSLog(@"认购===%@",response);
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            MSBuyDebt *buyDebt = [[MSBuyDebt alloc] init];
            if (result == ERR_NONE) {
                buyDebt.canRetryCount = [response[@"canRetryCount"] intValue];
                buyDebt.result = ERR_NONE;
            }else{
                buyDebt.result = result;
            }
            buyDebt.message = response[@"statusMessage"];
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (buyDebt.result == ERR_NONE) {
                    [subscriber sendNext:buyDebt.message];
                    [subscriber sendCompleted];
                }else{
                    [subscriber sendError:buyDebt];
                }
            });
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryChargeOneStepMoney:(NSString *)money password:(NSString *)password
{
    NSString *messageId = @"rechargeOneStep";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:money forKey:@"amount"];
    [params setObject:password forKey:@"tradePassword"];
    
    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {

            NSLog(@"充值第一步===%@",response);
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            MSRechargeOne *rechargeOne = [[MSRechargeOne alloc] init];
            
            if (result == ERR_NONE) {
                rechargeOne.rechargeNo = response[@"rechargeNo"];
                if (!rechargeOne.rechargeNo) {
                    [MSLog error:@"Returned recharge No is null. Response: %@", response];
                }
                rechargeOne.canRetryCount = [response[@"canRetryCount"] intValue];
                rechargeOne.result = ERR_NONE;
            }else {
                rechargeOne.result = result;
            }
            rechargeOne.message = response[@"statusMessage"];
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (rechargeOne.result == ERR_NONE) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setNoNilObject:rechargeOne.message forKey:@"message"];
                    [dic setNoNilObject:rechargeOne.rechargeNo forKey:@"rechargeNo"];
                    [subscriber sendNext:dic];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:rechargeOne];
                }
            });
            
        }];
        
        return nil;
        
    }];
}

- (RACSignal *)queryChargeTwoStepWithRechargeNo:(NSString *)rechargeNo
{
    NSString *messageId = @"rechargeTwoStep";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:rechargeNo forKey:@"rechargeNo"];
    
    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            
            NSLog(@"充值第二步===%@",response);
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            MSRechargeTwo *rechargeTwo = [[MSRechargeTwo alloc] init];
            rechargeTwo.result = result;
            rechargeTwo.message = response[@"statusMessage"];
            
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME/2.0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (rechargeTwo.result == ERR_NONE) {
                    [subscriber sendNext:rechargeTwo.message];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:rechargeTwo];
                }
            });
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryChargeThreeStepRechargeNo:(NSString *)rechargeNo vCode:(NSString *)vCode
{
    NSString *messageId = @"rechargeThreeStep";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:rechargeNo forKey:@"rechargeNo"];
    [params setObject:vCode forKey:@"verifyCode"];
    
    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {

            NSLog(@"充值第三步===%@",response);
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            MSRechargeThree *rechargeThree = [[MSRechargeThree alloc] init];
            rechargeThree.result = result;
            rechargeThree.message = response[@"statusMessage"];
            
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (rechargeThree.result == ERR_NONE) {
                    [subscriber sendNext:rechargeThree.message];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:rechargeThree];
                }
            });
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)querySystemConfig {
    NSString *messageId = @"searchSys";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];

    UInt64 start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            [self statisticInterface:messageId startTime:start];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            SystemConfigs *config = nil;
            if (reqResult.result == ERR_NONE) {
                config = [SystemConfigs new];
                config.transferFee = [[response objectForKey:@"fee"] doubleValue];
                config.minFee = [[response objectForKey:@"feemin"] doubleValue];
                config.maxFee = [[response objectForKey:@"feemax"] doubleValue];
                config.minDiscountRate = [[response objectForKey:@"diccountratemin"] doubleValue];
                config.maxDiscountRate = [[response objectForKey:@"diccountratemax"] doubleValue];
                config.minDaysAfterBought = [[response objectForKey:@"gmsxhbdyts"] intValue];
                config.minDaysBeforeEndRepay = [[response objectForKey:@"hkjsbdyts"] intValue];
                config.beginInvestAmount = [[response objectForKey:@"qtje"] longValue];
                config.increaseInvestAmount = [[response objectForKey:@"dzje"] longValue];
                config.rechargeProtocolUrl = [response objectForKey:@"rechargeProtocolUrl"];
            }
            
            if (config) {
                [subscriber sendNext:config];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)querySupportBankList:(NSString *)list {

    NSString *messageId = @"getSupportBankList";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:list forKey:@"bankId"];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            RACError *reqResult = [self getResult:result fromResponse:response];
            NSMutableArray *bankList = nil;
            if (reqResult.result == ERR_NONE) {
                NSArray *supportList = [response objectForKey:@"banklist"];
                bankList = [[NSMutableArray alloc] initWithCapacity:supportList.count];
                for (NSDictionary *dict in supportList) {
                    BankInfo *bank = [BankInfo new];
                    bank.bankId = [dict objectForKey:@"bankId"];
                    bank.bankName = [dict objectForKey:@"bankName"];
                    bank.bankUrl = [dict objectForKey:@"bankUrl"];
                    bank.singleLimit = [[dict objectForKey:@"singleLimit"] doubleValue];
                    bank.dayLimit = [[dict objectForKey:@"dayLimit"] doubleValue];
                    bank.monthLimit = [[dict objectForKey:@"monthLimit"] doubleValue];
                    [bankList addObject:bank];
                }
                
                [subscriber sendNext:bankList];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)userSetTradePassword:(NSString *)password {
    
    NSString *messageId = @"setPayPassword";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:password forKey:@"tradePassword"];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == 4) {
                reqResult.result = ERR_TRADE_PASSWORD_EXIST;
            }
            [subscriber sendNext:reqResult];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)userResetTradePassword:(NSString *)password token:(NSString *)token {
    
    NSString *messageId = @"resetPayPassCommit";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:password forKey:@"tradePassword"];
    [params setObject:token forKey:@"token"];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            RACError *reqResult = [self getResult:result fromResponse:response];
            [subscriber sendNext:reqResult];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)resetTradePasswordPhone:(NSString *)phone verifyCode:(NSString *)code {

    NSString *messageId = @"resetPayPassVerifyPhone";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:phone forKey:@"phoneNumber"];
    [params setObject:code forKey:@"verifyCode"];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            RACError *reqResult = [self getResult:result fromResponse:response];
            NSString *token = nil;
            if (reqResult.result == ERR_NONE) {
                token = [response objectForKey:@"token"];
                
                [subscriber sendNext:token];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

- (RACSignal *)resetTradePasswordRealName:(NSString *)name idCard:(NSString *)idCard bankCard:(NSString *)card token:(NSString *)token {
    NSString *messageId = @"resetPayPassAuthentication";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:name forKey:@"realName"];
    [params setObject:idCard forKey:@"idCardNumber"];
    [params setObject:card forKey:@"bankCardNumber"];
    [params setObject:token forKey:@"token"];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            RACError *reqResult = [self getResult:result fromResponse:response];
            [subscriber sendNext:reqResult];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)bindCardRealName:(NSString *)name idCard:(NSString *)idCard bankId:(NSString *)bankId bankCard:(NSString *)card phone:(NSString *)phone verifyCode:(NSString *)code {
    NSString *messageId = @"bindBankCard";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:name forKey:@"userName"];
    [params setObject:idCard forKey:@"idCardNumber"];
    [params setObject:card forKey:@"bankCardNumber"];
    [params setObject:phone forKey:@"phoneNumber"];
    [params setObject:code forKey:@"verifyCode"];
    [params setObject:bankId forKey:@"bankId"];

    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result != ERR_NONE) {
                switch (reqResult.result) {
                    case 3:
                    case 5:
                        reqResult.result = ERR_BIND_CARD_ERROR;
                        break;
                }
                
                [subscriber sendError:reqResult];
            }else{
                [subscriber sendCompleted];
            }
            
        }];
        
        return nil;
    }];
}

- (RACSignal *)queryRechargeConfig {
    NSString *messageId = @"queryRechargeConfig";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                RechargeConfig *rechargeConfig = [[RechargeConfig alloc] init];
                rechargeConfig.dayCanRechargeAmount = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"dayQuota"]];
                rechargeConfig.monthCanRechargeAmount = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"monthQuota"]];
                [subscriber sendNext:rechargeConfig];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)queryWithdrawConfig {
    NSString *messageId = @"queryWithdrawConfig";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"messageId"];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                WithdrawConfig *withdrawConfig = [[WithdrawConfig alloc] init];
                withdrawConfig.minCash = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"minCash"]];
                withdrawConfig.maxCash = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"maxCash"]];
                withdrawConfig.dayCashCountLimit = [[response objectForKey:@"dayCount"] integerValue];
                withdrawConfig.canCashCount = [[response objectForKey:@"usableCashCount"] integerValue];
                withdrawConfig.dayCanCashAmount = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"surplusDayCash"]];
                withdrawConfig.monthCanCashAmount = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"surplusMonthCash"]];
                withdrawConfig.dayCashAmountLimit = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"dayCash"]];
                withdrawConfig.monthCashAmountLimit = [NSDecimalNumber decimalNumberWithString:[response objectForKey:@"monthCash"]];
                [subscriber sendNext:withdrawConfig];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];

        return nil;
    }];
}

- (RACSignal *)reloginForRequest:(NSString *)url
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        [_httpService reloginForRequest:url result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            NSString *updatedUrl = nil;
            if (reqResult.result == ERR_NONE) {
                updatedUrl = [response objectForKey:@"url"];
                NSDictionary *dic = @{KEY_OLD_URL : url, KEY_UPDATED_URL : updatedUrl};
                [subscriber sendNext:dic];
                [subscriber sendCompleted];
            }else{
                [subscriber sendError:reqResult];
            }
        }];
        
        return nil;
    }];
}

#pragma mark - Current

- (RACSignal *)queryMyAsset {
    NSString *messageId = @"queryAssetInfo";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                AssetInfo *assetInfo = [[AssetInfo alloc] init];

                assetInfo.balance = [[response objectForKey:@"balance"] toDecicmalNumber];
                assetInfo.withdrawFrozenAmount = [[response objectForKey:@"withdrawFrozenAmount"] toDecicmalNumber];

                NSDictionary *jsonRegular = [response objectForKey:@"regularAsset"];
                assetInfo.regularAsset.tobeReceivedPrincipal = [[jsonRegular objectForKey:@"toBeReceivedPrincipal"] toDecicmalNumber];
                assetInfo.regularAsset.tobeReceivedInterest = [[jsonRegular objectForKey:@"toBeReceivedInterest"] toDecicmalNumber];
                assetInfo.regularAsset.investFrozenAmount = [[jsonRegular objectForKey:@"forzenAmount"] toDecicmalNumber];
                assetInfo.regularAsset.totalEarnings = [[jsonRegular objectForKey:@"totalEarnedInterest"] toDecicmalNumber];
                
                NSDictionary *jsonCurrent = [response objectForKey:@"currentAsset"];
                assetInfo.currentAsset.investAmount = [[jsonCurrent objectForKey:@"investAmount"] toDecicmalNumber];
                assetInfo.currentAsset.addUpAmount = [[jsonCurrent objectForKey:@"addUpAmount"] toDecicmalNumber];
                assetInfo.currentAsset.purchaseFrozenAmount = [[jsonCurrent objectForKey:@"investFrozenAmount"] toDecicmalNumber];
                assetInfo.currentAsset.redeemFrozenAmount = [[jsonCurrent objectForKey:@"redeemFrozenAmount"] toDecicmalNumber];
                assetInfo.currentAsset.historyAddUpAmount = [[jsonCurrent objectForKey:@"historyAddUpAmount"] toDecicmalNumber];
                assetInfo.currentAsset.yesterdayEarnings = [[jsonCurrent objectForKey:@"yesterdayEarnings"] toDecicmalNumber];

                [subscriber sendNext:assetInfo];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)queryCurrentListWithLastID:(NSNumber *)lastCurrentID pageSize:(NSInteger)pageSize isRecommended:(BOOL)isRecommended {
    NSString *messageId = @"queryCurrentList";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:lastCurrentID forKey:@"lastCurrentId"];
    [params setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithBool:isRecommended] forKey:@"isRecommended"];

    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                NSArray *jsonCurrentList = [response objectForKey:@"currentList"];
                NSUInteger count = jsonCurrentList.count;
                NSMutableArray *currentList = [[NSMutableArray alloc] initWithCapacity:count];
                for (int i = 0; i < count; ++i) {
                    CurrentInfo *currentInfo = [[CurrentInfo alloc] init];
                    NSDictionary *jsonCurrent = [jsonCurrentList objectAtIndex:i];
                    currentInfo.currentID = [jsonCurrent objectForKey:@"currentId"];
                    currentInfo.title = [jsonCurrent objectForKey:@"title"];
                    currentInfo.interestRate = [jsonCurrent objectForKey:@"interestRate"];
                    currentInfo.interestRateDescription = [jsonCurrent objectForKey:@"interestRateDescription"];
                    currentInfo.startAmount = [jsonCurrent objectForKey:@"startAmount"];
                    currentInfo.inceaseAmount = [jsonCurrent objectForKey:@"increaseAmount"];
                    currentInfo.termUnit = [jsonCurrent objectForKey:@"termUnit"];
                    NSInteger status = [[jsonCurrent objectForKey:@"status"] integerValue];
                    currentInfo.status = status == 1 ? STATUS_SALING : STATUS_SALE_OUT;
                    NSString *redEnvelopeFlag = [jsonCurrent objectForKey:@"supportedRedbagTypes"];
                    @strongify(self);
                    currentInfo.supportedRedEnvelopeTypes = [self convertWayToRedEnvelopeTypes:redEnvelopeFlag];

                    [currentList addObject:currentInfo];
                }

                [subscriber sendNext:currentList];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)queryCurrentDetail:(NSNumber *)currentID {
    NSString *messageId = @"queryCurrentDetail";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:currentID forKey:@"currentId"];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:NO params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                CurrentDetail *currentDetail = [[CurrentDetail alloc] init];
                currentDetail.baseInfo.currentID = [response objectForKey:@"currentId"];

                NSDictionary *jsonDetail = [response objectForKey:@"currentDetail"];
                currentDetail.earningsPer10000 = [jsonDetail objectForKey:@"earningsPer10000"];
                currentDetail.investRulesURL = [jsonDetail objectForKey:@"investRulesURL"];

                currentDetail.maxDisplayInterestRate = [jsonDetail objectForKey:@"maxDisplayInterestRate"];
                currentDetail.minDisplayInterestRate = [jsonDetail objectForKey:@"minDisplayInterestRate"];
                currentDetail.intervalRateCount = [[jsonDetail objectForKey:@"intervalCount"] integerValue];

                NSArray *json7InterestRates = [jsonDetail objectForKey:@"last7daysInterestRates"];
                NSUInteger rateCount = json7InterestRates.count;
                NSMutableArray<DayInterestRate *> *last7DaysInterestRates = [[NSMutableArray alloc] initWithCapacity:rateCount];
                for (int i = 0; i < rateCount; ++i) {
                    NSDictionary *jsonRate = [json7InterestRates objectAtIndex:i];
                    DayInterestRate *rateInfo = [[DayInterestRate alloc] init];
                    rateInfo.interestRate = [[jsonRate objectForKey:@"interestRate"] doubleValue];
                    rateInfo.date = [[jsonRate objectForKey:@"date"] longValue];
                    [last7DaysInterestRates addObject:rateInfo];
                }

                NSArray<DayInterestRate *> *sortedRateArray = [last7DaysInterestRates sortedArrayUsingComparator:^NSComparisonResult(DayInterestRate *obj1, DayInterestRate *obj2) {
                    if (obj1.date < obj2.date) {
                        return (NSComparisonResult) NSOrderedAscending;
                    }
                    if (obj1.date > obj2.date) {
                        return (NSComparisonResult) NSOrderedDescending;
                    }
                    return (NSComparisonResult) NSOrderedSame;
                }];

                NSMutableArray<DayInterestRate *> *ratesArray = [[NSMutableArray alloc] initWithCapacity:7];
                if (rateCount > 0 && rateCount <= 7) {
                    DayInterestRate *rateInfo = [sortedRateArray objectAtIndex:0];
                    for (int i = 0; i < 7 - rateCount; ++i) {
                        [ratesArray addObject:rateInfo];
                    }
                    [ratesArray addObjectsFromArray:sortedRateArray];
                } else if (rateCount > 7) {
                    for (int i = 0; i < 7; ++i) {
                        DayInterestRate *rateInfo = [sortedRateArray objectAtIndex:(rateCount - 7 + i)];
                        [ratesArray addObject:rateInfo];
                    }
                } else {
                    [MSLog warning:@"Unexpected rate count: %u", rateCount];
                }
                currentDetail.last7DaysInterestRates = ratesArray;

                NSDictionary *jsonProduct = [jsonDetail objectForKey:@"productInfo"];
                currentDetail.productInfo.productManager = [jsonProduct objectForKey:@"productManager"];
                NSArray *jsonProductItems = [jsonProduct objectForKey:@"productItems"];
                NSUInteger itemCount = jsonProductItems.count;
                NSMutableArray *productItems = [[NSMutableArray alloc] initWithCapacity:itemCount];
                for (int i = 0; i < itemCount; ++i) {
                    NSDictionary *jsonItem = [jsonProductItems objectAtIndex:i];
                    CurrentProductItem *item = [[CurrentProductItem alloc] init];
                    item.name = [jsonItem objectForKey:@"name"];
                    item.url = [jsonItem objectForKey:@"url"];
                    item.order = [[jsonItem objectForKey:@"order"] integerValue];
                    [productItems addObject:item];
                }
                currentDetail.productInfo.items = [productItems sortedArrayUsingComparator:^NSComparisonResult(CurrentProductItem *item1, CurrentProductItem *item2) {
                    if (item1.order < item2.order) {
                        return (NSComparisonResult) NSOrderedAscending;
                    }
                    if (item1.order > item2.order) {
                        return (NSComparisonResult) NSOrderedDescending;
                    }
                    return (NSComparisonResult) NSOrderedSame;
                }];

                [subscriber sendNext:currentDetail];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)queryCurrentEarningsHistoryWithID:(NSNumber *)currentID lastEarningsDate:(long)lastDate pageSize:(NSInteger)pageSize {
    NSString *messageId = @"queryCurrentEarningsHistory";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:currentID forKey:@"currentId"];
    [params setObject:[NSNumber numberWithLong:lastDate] forKey:@"lastEarningsDate"];
    [params setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                NSArray *jsonEarningsHistory = [response objectForKey:@"earningsHistory"];
                NSUInteger count = jsonEarningsHistory.count;
                NSMutableArray *earningsAddUpHistory = [[NSMutableArray alloc] initWithCapacity:count];
                for (int i = 0; i < count; ++i) {
                    NSDictionary *jsonEarningsItem = [jsonEarningsHistory objectAtIndex:i];
                    CurrentEarnings *earnings = [[CurrentEarnings alloc] init];
                    earnings.date = [[jsonEarningsItem objectForKey:@"date"] longValue];
                    earnings.amount = [jsonEarningsItem objectForKey:@"amount"];
                    [earningsAddUpHistory addObject:earnings];
                }
                [subscriber sendNext:earningsAddUpHistory];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)queryCurrentPurchaseConfig:(NSNumber *)currentID {
    NSString *messageId = @"queryCurrentPurchaseConfig";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:currentID forKey:@"currentId"];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                NSDictionary *jsonConfig = [response objectForKey:@"config"];
                CurrentPurchaseConfig *purchaseConfig = [[CurrentPurchaseConfig alloc] init];
                purchaseConfig.beginInterestDate = [[jsonConfig objectForKey:@"beginInterestDate"] longValue];
                purchaseConfig.canPurchaseLimit = [jsonConfig objectForKey:@"canPurchaseLimit"];

                [subscriber sendNext:purchaseConfig];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)purchaseCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    NSString *messageId = @"purchaseCurrent";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:currentID forKey:@"currentId"];
    [params setObject:amount.stringValue forKey:@"amount"];
    [params setObject:payPassword forKey:@"payPassword"];

    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            
            [self statisticInterface:messageId startTime:start];
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME];
            
            RACError *reqResult = [self getResult:result fromResponse:response];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (reqResult.result == ERR_NONE) {
                    NSDictionary *jsonNotice = [response objectForKey:@"purchaseNotice"];
                    CurrentPurchaseNotice *notice = [[CurrentPurchaseNotice alloc] init];
                    notice.purchaseDate = [[jsonNotice objectForKey:@"purchaseDate"] longValue];
                    notice.beginInterestDate = [[jsonNotice objectForKey:@"beginInterestDate"] longValue];
                    notice.earningsReceiveDate = [[jsonNotice objectForKey:@"earningsReceiveDate"] longValue];
                    
                    [subscriber sendNext:notice];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:reqResult];
                }
            });
        }];
        return nil;
    }];
}

- (RACSignal *)queryCurrentRedeemConfig:(NSNumber *)currentID {
    NSString *messageId = @"queryCurrentRedeemConfig";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:currentID forKey:@"currentId"];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            RACError *reqResult = [self getResult:result fromResponse:response];
            if (reqResult.result == ERR_NONE) {
                NSDictionary *jsonConfig = [response objectForKey:@"config"];

                CurrentRedeemConfig *redeemConfig = [[CurrentRedeemConfig alloc] init];
                redeemConfig.redeemApplyDate = [[jsonConfig objectForKey:@"redeemApplyDate"] longValue];
                redeemConfig.earningsReceiveDate = [[jsonConfig objectForKey:@"earningsReceiveDate"] longValue];
                redeemConfig.leftCanRedeemCount = [[jsonConfig objectForKey:@"leftCanRedeemCount"] integerValue];
                redeemConfig.leftCanRedeemAmount = [jsonConfig objectForKey:@"leftCanRedeemAmount"];
                redeemConfig.redeemRulesURL = [jsonConfig objectForKey:@"redeemRulesURL"];

                [subscriber sendNext:redeemConfig];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:reqResult];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)redeemCurrentWithID:(NSNumber *)currentID amount:(NSDecimalNumber *)amount password:(NSString *)payPassword {
    NSString *messageId = @"redeemCurrent";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:messageId forKey:@"messageId"];
    [params setObject:currentID forKey:@"currentId"];
    [params setObject:amount.stringValue forKey:@"amount"];
    [params setObject:payPassword forKey:@"payPassword"];

    double start = [TimeUtils currentTimeMillis];
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *url = [self getHttpUrl:messageId];
        [_httpService post:url shouldAuthenticate:YES params:params result:^(int result, NSDictionary *response) {
            @strongify(self);
            
            [self statisticInterface:messageId startTime:start];
            double delty = [self deltyWithStartTime:start withLimitTime:LIMIT_TIME];
            RACError *reqResult = [self getResult:result fromResponse:response];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delty * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (reqResult.result == ERR_NONE) {
                    CurrentRedeemNotice *notice = [[CurrentRedeemNotice alloc] init];
                    notice.redeemApplyDate = [[response objectForKey:@"redeemApplyDate"] longValue];
                    notice.earningsToBeReceiveDate = [[response objectForKey:@"earningsReceiveDate"] longValue];
                    [subscriber sendNext:notice];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:reqResult];
                }
            });
        }];
        return nil;
    }];
}

#pragma mark - statistics
- (void)sendAppInfo:(MSStatsAppInfo *)appInfo
{
    UInt64 start = [TimeUtils currentTimeMillis];
    NSString *url = [self getHttpUrl:@"sendDataLog"];
    [_httpService post:url shouldAuthenticate:NO params:[appInfo toDictionary] result:^(int result, NSDictionary *response) {
        [self statisticInterface:@"sendDataLog" startTime:start];
        
        RACError *reqResult = [self getResult:result fromResponse:response];
        if (reqResult.result != ERR_NONE) {
            [MSLog error:@"Stats: send app info failed, %d", reqResult.result];
        } else {
            [MSLog debug:@"Stats: send app info succeed, %@", [appInfo toString]];
        }
    }];
}

- (void)sendStatsEvent:(MSStatsEvent *)event
{
    UInt64 start = [TimeUtils currentTimeMillis];
    NSString *url = [self getHttpUrl:@"sendLoginDataLog"];
    [_httpService post:url shouldAuthenticate:NO params:[event toDictionary] result:^(int result, NSDictionary *response) {
        [self statisticInterface:@"sendLoginDataLog" startTime:start];
        
        RACError *reqResult = [self getResult:result fromResponse:response];
        if (reqResult.result != ERR_NONE) {
            [MSLog error:@"Stats: send event failed, %d, event id: %d", reqResult.result, event.eventId];
        } else {
            [MSLog debug:@"Stats: send event succeed, %@", [event toString]];
        }
    }];
}


- (RACError *)getResult:(int)httpResult fromResponse:(NSDictionary *)response {
    RACError *result = [RACError new];
    if (httpResult == ERR_NONE) {
        result.result = [[response objectForKey:@"statusCode"] intValue];
        if (result.result != ERR_NONE) {
            result.message = [response objectForKey:@"statusMessage"];
        }
    } else {
        result.result = httpResult;
        result.message = [response objectForKey:@"statusMessage"];
    }
    return result;
}

- (NSString *)convertProjectInstructionTypeToProtocolType:(int)type
{
    switch (type) {
        case INSTRUCTION_TYPE_COMPANY_INTRODUCTION: return @"A";
        case INSTRUCTION_TYPE_RISK_WARNING: return @"C";
        case INSTRUCTION_TYPE_DISCLAIMER: return @"D";
        case INSTRUCTION_TYPE_TRADING_MANUAL: return @"E";
        default: return @"A";
    }
}

- (NSString *)convertRedEnvelopeTypeToWay:(NSInteger)flag
{
    NSMutableString *isWay = [[NSMutableString alloc] init];
    if (flag & TYPE_VOUCHERS) {
        [isWay appendString:@"0"];
    }

    if (flag & TYPE_PLUS_COUPONS) {
        if (isWay.length > 0) {
            [isWay appendString:@","];
        }
        [isWay appendString:@"1"];
    }

    if (flag & TYPE_EXPERIENS_GOLD) {
        if (isWay.length > 0) {
            [isWay appendString:@","];
        }
        [isWay appendString:@"2"];
    }

    return isWay;
}

- (RedEnvelopeType)convertIntToRedEnvelopeType:(NSInteger)way
{
    if (way == 0) {
        return TYPE_VOUCHERS;
    }
    if (way == 1) {
        return TYPE_PLUS_COUPONS;
    }
    if (way == 2) {
        return TYPE_EXPERIENS_GOLD;
    } else {
    
        [MSLog warning:@"Unknown red envelope way: %d", way];
    }

    return TYPE_NONE;
}

- (NSInteger)convertWayToRedEnvelopeTypes:(NSString *)isWay
{
    if (!isWay || isWay.length == 0) {
        return TYPE_NONE;
    }

    NSInteger flag = 0;
    NSArray *types = [isWay componentsSeparatedByString:@","];
    for (NSString *type in types) {
        int way = [type intValue];
        if (way == 0) {
            flag |= TYPE_VOUCHERS;
        } else if (way == 1) {
            flag |= TYPE_PLUS_COUPONS;
        } else if (way == 2) {
            flag |= TYPE_EXPERIENS_GOLD;
        } else {
            [MSLog warning:@"Unknonw way: %d", way];
        }
    }
    return flag;
}


- (RedEnvelopeType)convertStringToRedEnvelopeType:(NSString *)way
{
    if ([way isEqualToString:@"代金券"]) {
        return TYPE_VOUCHERS;
    }

    if ([way isEqualToString:@"加息券"]) {
        return TYPE_PLUS_COUPONS;
    }

    if ([way isEqualToString:@"体验金"]) {
        return TYPE_EXPERIENS_GOLD;
    }

    [MSLog warning:@"Unknown red envelope way: %@", way];
    return TYPE_NONE;
}

- (NSInteger)convertDebtStatusesToZKStatus:(NSInteger)statuses
{
    if (statuses & STATUS_CAN_BE_TRANSFER) {
        return 0;
    }

    if ((statuses & STATUS_TRANSFERRING) && (statuses & STATUS_TRANSFERRED)) {
        return 19;
    }

    if (statuses & STATUS_TRANSFERRING) {
        return 1;
    }

    if (statuses & STATUS_TRANSFERRED) {
        return 20;
    }

    if (statuses & STATUS_HAS_BOUGHT) {
        return 21;
    }

    [MSLog error:@"Unexpected debt statuses: %d", statuses];
    return -1;
}

- (void)statisticInterface:(NSString *)messageId startTime:(UInt64)start {

    [MSLog verbose:[NSString stringWithFormat:@"[http_test] %@ %llu %llu",messageId,start,[TimeUtils currentTimeMillis]]];
}

- (double)deltyWithStartTime:(double)start withLimitTime:(double)limitTime
{
    double end = [TimeUtils currentTimeMillis];
    double delty = end - start - limitTime;
    NSLog(@"时间间隔==%f",end - start);
    NSLog(@"delty==%f",delty);
    delty = delty > 0 ? 0 : -delty/1000;
    NSLog(@"delty==%f",delty);
    return delty;
}

- (NSString *)getServiceHost {
    switch ([MSUrlManager getHost]) {
        case HOST_ZK:
            return @"http://10.0.110.67:6500/";
        case HOST_TEST:
            return @"http://101.200.156.252:9081/";//功能测试
        case HOST_PERFORMANCE:
            return @"http://mjstest.minshengjf.com:6101/";
        case HOST_PREREALSE:
            return @"https://mjsytc.minshengjf.com:6108/";//准生产
        case HOST_PRODUCT:
        default:
            return @"https://www.mjsfax.com:6108/";
    }
}

- (NSString *)getHttpUrl:(NSString *)messageId {
    NSString *serviceHost = [self getServiceHost];
    return [NSString stringWithFormat:@"%@%@%@", serviceHost, @"message/", messageId];
}

@end
