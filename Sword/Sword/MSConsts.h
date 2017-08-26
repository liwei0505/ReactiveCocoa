//
//  MSConsts.h
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

// 通用错误码表
typedef NS_ENUM(NSInteger, ErrorCode) {
    ERR_NONE = 0,
    ERR_UNKNOWN = -1,
    ERR_NETWORK = -2,
    ERR_JSON_PARSE = -3,
    ERR_ALREADY_EXISTS = -4,
    ERR_SERVER = -5,
    ERR_NOT_LOGIN = -6,
    ERR_INPUT_EMPTY = -7,
    ERR_INPUT_INVALID = -8,
    ERR_NOT_EXISTS = -9,
    ERR_NOT_AUTHENTICATED = -10,
    ERR_LOGIN_KICK = -11,               // 账号在别处登录，被迫下线
    ERR_NOT_SUPPORT = -12,              // 不支持
    ERR_TOO_FREQUENT = -13,             // 访问太频繁
    ERR_NO_PAY_PASSWORD = -14,
    ERR_CANCELLED = -15,
    ERR_INVALID_STATE = -16,
    ERR_BUY_FROM_SELF = -30,            // 买自己的标的
    ERR_NOT_TIRO = -31,                 // 不是新手
    ERR_ZERO_AMOUNT = -32,              // 金额为零
    ERR_EXCEED_SUBJECT_AMOUNT = -33,    // 超出剩余金额
    ERR_EXCEED_MAX_LIMIT = -34,         // 超过最大限额
    ERR_INSUFFICIENT_BALANCE = -35,     // 余额不足
    ERR_MISMATCHED_AMOUNT = -36,        // 不合要求的金额
    ERR_AMOUNT_NOT_EQUAL = -37,         // 剩余可投金额小于起投金额 且 投资额不等于剩余可投金额
    ERR_TRADE_PASSWORD_EXIST = -38,     // 交易密码已经存在
    ERR_BIND_CARD_ERROR = -39           // 3：银行卡认证用处理鉴权记录异常 5：银行卡认证后台业务处理异常
    
};

typedef NS_ENUM(NSInteger, HOST_TYPE) {
    HOST_ZK,
    HOST_TEST,
    HOST_PERFORMANCE,
    HOST_PREREALSE,
    HOST_PRODUCT,
};

typedef NS_ENUM(NSUInteger, MSLoginStatus) {
    STATUS_NOT_LOGIN, // 未登录
    STATUS_LOGINING,  // 登录中
    STATUS_LOGINED    // 已登录
};

// 获取验证码目的类型
typedef NS_ENUM(NSInteger, GetVerifyCodeAim) {
    AIM_REGISTER = 1,         // 注册
    AIM_RESET_LOGIN_PASSWORD, // 重置登录密码
    AIM_BIND_BANK_CARD,       // 绑定银行卡
    AIM_RESET_TRADE_PASSWORD = 5, // 重置交易密码
};

// 投资状态
typedef NS_ENUM(NSInteger, InvestStatus) {
    STATUS_ALL = 0,     // 全部
    STATUS_FUNDRAISING, // 筹款中
    STATUS_BACKING,     // 回款中
    STATUS_FINISHED,    // 已完成
};

// 债权状态
typedef NS_ENUM(NSInteger, DebtStatus) {
    STATUS_CAN_BE_TRANSFER = 0x01, // 可转让
    STATUS_TRANSFERRING = 0x02,    // 转让中
    STATUS_TRANSFERRED = 0x04,     // 已转让
    STATUS_HAS_BOUGHT = 0x08,      // 已购买
};

typedef NS_ENUM(NSInteger, FlowType) {
    TYPE_ALL = 0,                       // 全部
    TYPE_REDEEM = 60,                   // 活期赎回
    TYPE_CHARGE = 100,                  // 充值
    TYPE_RECOVER_PRINCIPAL = 220,       // 回收本金
    TYPE_RECOVER_INTEREST = 230,        // 回收利息
    TYPE_RECEIVED_LATE_PENALTY = 260,   // 收到逾期罚息
    TYPE_BORROWING_SUCCESS = 300,       // 借款成功
    TYPE_DEBT_TRANSFER = 600,           // 债权转让
    TYPE_BIDS = 650,                    // 流标
    TYPE_WITHDRAW = 1100,               // 提现
    TYPE_REPAYMENT_OF_P_AND_I = 1200,   // 偿还本息
    TYPE_LOANS_OVERDUE_PENALTY = 1260,  // 借款逾期罚息
    TYPE_INVEST = 1350,                 // 投标
    TYPE_DEBT_TRANSFER_FEE = 1400,      // 债权转让手续费
    TYPE_LOANS_FEE = 1500,              // 借款手续费
    TYPE_LOANS_OVERDUE_FINES = 1510,    // 借款逾期滞纳金
    TYPE_RISK_MARGIN = 1550,            // 风险保证金
    TYPE_OTHER = -1,                    // 其他类型

};

typedef NS_ENUM(NSUInteger, Period) {
    SEVEN_DAYS = 0,             // 7天
    ONE_MONTH = 1,              // 1个月
    TWO_MONTHS = 2,             // 2个月
    THREE_MONTHS = 3,           // 3个月
    ALL = 4,                    // 全部

};

// 红包状态
typedef NS_ENUM(NSInteger, RedEnvelopeStatus) {
    STATUS_NONE = 0,        // 全部
    STATUS_AVAILABLE = 20,  // 未使用
    STATUS_USED,            // 已使用
    STATUS_EXPIRED = 50,    // 已过期
};

// 红包类型
typedef NS_ENUM(NSInteger, RedEnvelopeType) {
    TYPE_NONE = 0x00,               // 不支持
    TYPE_VOUCHERS = 0x01,           // 代金券
    TYPE_PLUS_COUPONS = 0x02,       // 加息券
    TYPE_EXPERIENS_GOLD = 0x04,     // 体验金
};

typedef NS_ENUM(NSInteger, NoticeType) {
    TYPE_NOTICE = 0, //平台公告
    TYPE_HELP = 1,   //帮助中心
    TYPE_ABOUT = 2,  //关于我们
};

//分享类型
typedef NS_ENUM(NSInteger, ShareType) {
    SHARE_INVITE = 1, //邀请
    SHARE_INVEST = 2, //分享标的
};

//三方支付类型
typedef NS_ENUM(NSInteger, PayType) {
    Pay_Ali = 1, // 支付宝支付
    Pay_Wx = 2,  // 微信支付
};

// 请求数据列表类型
typedef NS_ENUM(NSInteger, ListRequestType) {
    LIST_REQUEST_NEW,  //重新请求
    LIST_REQUEST_MORE, //请求更多
};

typedef NS_ENUM(NSInteger, ControllerJumpType) {
    
    TYPE_PATTERN_FORGET = 1,    //忘记手势密码
    TYPE_CHANGE_USER = 2,       //切换用户
    TYPE_ACCOUNT = 5,           //账户页
    TYPE_RISK = 6,              //跳到风险评测
  
};

typedef NS_ENUM(NSInteger, ProjectInstructionType) {
    INSTRUCTION_TYPE_NONE,
    INSTRUCTION_TYPE_RISK_WARNING,   // 风险揭示
    INSTRUCTION_TYPE_DISCLAIMER,     // 免责声明
    INSTRUCTION_TYPE_TRADING_MANUAL, // 产品说明
    INSTRUCTION_TYPE_COMPANY_INTRODUCTION, // 公司介绍（已废弃）
    INSTRUCTION_TYPE_INVEST_CONTRACT, // 协议合同模板
    INSTRUCTION_TYPE_INVESTMENT_RECORD //投资记录
};
//风险评测
typedef NS_ENUM(NSInteger, RiskType) {
    EVALUATE_NOT = 0,       //未评测
    EVALUATE_UNKNOWN = 1,   //未知型
    EVALUATE_OLD = 2,       //保守型
    EVALUATE_STEADY = 3,    //稳重型
    EVALUATE_RISK = 4,      //积极型
};

//设置交易密码
typedef NS_ENUM(NSInteger, TradePassword) {
    TRADE_PASSWORD_SET = 0,     //设置交易密码
    TRADE_PASSWORD_RESET = 1,   //重置交易密码
};

// 关系
typedef NS_ENUM(NSUInteger, Relationship) {
    RELATIONSHIP_SELF = 1,   // 本人
    RELATIONSHIP_PARENT = 2, // 父母
    RELATIONSHIP_CHILD = 3,  // 子女
    RELATIONSHIP_SPOUSE = 4, // 配偶
    RELATIONSHIP_OTHER = 9,  // 其他
};

// 证件类型
typedef NS_ENUM(NSUInteger, CertificateType) {
    CERTIFICATE_TYPE_ID_CARD = 1, // 身份证
};

// 保单类型
typedef NS_ENUM(NSUInteger, InsurancePolicyStatus) {
    POLICY_STATUS_ALL = 0x00,          // 全部
    POLICY_STATUS_TOBE_PAID = 0x01,    // 待支付
    POLICY_STATUS_TOBE_PUBLISH = 0x02, // 待出单
    POLICY_STATUS_TOBE_ACTIVE = 0x04,  // 待生效
    POLICY_STATUS_ACTIVE = 0x08,       // 保障中
    POLICY_STATUS_INACTIVE = 0x10,     // 已失效
    POLICY_STATUS_FAILED = 0x20,       // 投保失败
    POLICY_STATUS_CANCELLED = 0x40,    // 已取消
};

// 保险内容类型
typedef NS_ENUM(NSUInteger, InsuranceContentType) {
    INSURACE_CONTENT_TYPE_INTRODUCTION = 1,   // 产品简介
    INSURACE_CONTENT_TYPE_CLAIM_PROCESS = 2,  // 理赔流程
    INSURACE_CONTENT_TYPE_COMMON_PROBLEMS = 3,// 常见问题
};

