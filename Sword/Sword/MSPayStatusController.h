//
//  MSPayStatusSubController.h
//  Sword
//
//  Created by msj on 2016/12/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, MSPayStatusSubMode) {
    MSPayStatusSubModeCash,  //提现
    MSPayStatusSubModeCharge,//充值
    MSPayStatusSubModeInvest,//投标
    MSPayStatusSubModeLoan,//认购
    MSPayStatusSubModeResetTradePassword,//重置交易密码
    MSPayStatusSubModeSetTradePassword,//设置交易密码
    MSPayStatusSubModeBindBank//绑卡
};

typedef NS_ENUM(NSInteger, MSPayStatusMode) {
    MSPayStatusModeSuccess,
    MSPayStatusModeFail
};

@interface MSPayStatusController : MSBaseViewController
/**
 *  @param payStatusSubMode 具体业务类型 (必传)
 *  @param payStatusMode 成功或失败 (必传)
 *  @param message 成功或失败信息（可选）
 */
- (void)updatePayStatusSubMode:(MSPayStatusSubMode)payStatusSubMode payStatusMode:(MSPayStatusMode)payStatusMode withMessage:(NSString *)message;
/**
 如果直接返回（pop）上一级，则不用实现该block
 如果是其他操作则实现该block
 **/
@property (copy, nonatomic) void (^backActionBlock)();
@end
