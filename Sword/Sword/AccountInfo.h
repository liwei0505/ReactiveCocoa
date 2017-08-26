//
//  AccountInfo.h
//  mobip2p
//
//  Created by lee on 16/5/27.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetInfo.h"
#import "WithdrawConfig.h"

//用户角色
typedef enum {
    INVESTOR = 0,  //投资者
    BORROWER = 1   //借款者
} UserRole;


typedef NS_ENUM(NSInteger, PayStatus) {
    STATUS_PAY_NOT_REGISTER = 0,
    STATUS_PAY_REGISTERING = 1,
    STATUS_PAY_NO_PASSWORD = 2,
    STATUS_PAY_PASSWORD_SET = 3
};

@interface AccountInfo : NSObject

// 当前登录用户ID
@property (assign, nonatomic) int uId;
// 昵称
@property (copy, nonatomic) NSString *nickName;
// 姓名
@property (copy, nonatomic) NSString *realName;
// 身份证号
@property (copy, nonatomic) NSString *idcardNum;
// 手机号码 (参考usermodel)
@property (copy, nonatomic) NSString *phoneNumber;
// 邮箱
@property (copy, nonatomic) NSString *mail;
// 角色 1投资者 2借款者
@property (assign, nonatomic) UserRole role;
// 用户投资次数
@property (assign, nonatomic) int investCount;
// 保障中保单数
@property (assign, nonatomic) int effectivePolicyCount;
// 绑卡状态
@property (assign, nonatomic) PayStatus payStatus;

// 风险评测
@property (assign, nonatomic) int isRiskEvaluated;

// 银行卡号
@property (copy, nonatomic) NSString *cardId;
// 银行卡预留手机号
@property (copy, nonatomic) NSString *cardBindPhone;
// 开户行ID
@property (copy, nonatomic) NSString *bankId;
// 开户行名称
@property (copy, nonatomic) NSString *bankName;
//可用红包个数
@property (assign, nonatomic) NSInteger canUseRedEnvelopeNumber;

@end


