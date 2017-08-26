//
//  MJSNotifications.h
//  Sword
//
//  Created by haorenjie on 16/5/31.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#ifndef MJSNotifications_h
#define MJSNotifications_h

#import <Foundation/Foundation.h>
#import "MSNotificationHelper.h"

extern NSString * const NOTIFY_INVEST_LIST_RELOAD;
extern NSString * const NOTIFY_MY_ATTORN_LIST_RELOAD;
extern NSString * const NOTIFY_INVERANCE_LIST_RELOAD;
extern NSString * const NOTIFY_POLICY_LIST_RELOAD;

extern NSString * const NOTIFY_NETWORK_STATUS_CHANGED;
extern NSString * const KEY_LOAN_ID;
extern NSString * const KEY_INSTRUCTION_TYPE;
extern NSString * const KEY_CONTRACT_CONTENT;
extern NSString * const KEY_DEBT_ID;
extern NSString * const KEY_INVEST_AMOUNT;
extern NSString * const KEY_RED_ENVELOPE_LIST;

extern NSString * const KEY_MY_INVEST_STATUS;
extern NSString * const NOTIFY_MY_ATTORN_LIST;
extern NSString * const KEY_MY_ATTORN_CATEGORY;
extern NSString * const KEY_MY_REDBAG_CATEGORY;
extern NSString * const NOTIFY_PRODUCT_EXCHANGE;
extern NSString * const NOTIFY_PRODUCT_EXCHANGE_SUCCESS;

extern NSString * const NOTIFY_USER_LOGOUT;
extern NSString * const NOTIFY_USER_KICK;

extern NSString * const KEY_OLD_URL;
extern NSString * const KEY_UPDATED_URL;

extern NSString * const NOTIFY_RISK_COMPLETION;

//支付校验
extern NSString * const NOTIFY_GET_VERIFICATIONCODE;
extern NSString * const NOTIFY_CHECK_VERIFICATIONCODE;
extern NSString * const NOTIFY_CHECK_TRADEPASSWORDVIEW;

#endif /* MJSNotifications_h */
