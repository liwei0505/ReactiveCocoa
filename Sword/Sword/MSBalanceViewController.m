//
//  MSBalanceViewController.m
//  Sword
//
//  Created by msj on 2017/6/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBalanceViewController.h"
#import "MSBalanceHeaderView.h"
#import "MSBalanceBankCardView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "MSInputAccessoryView.h"
#import "MSBalanceTextField.h"
#import "MSPayView.h"
#import "MSWebViewController.h"
#import "MSResetTradePasswordA.h"
#import "MSCheckInfoUtils.h"
#import "MSAlertController.h"
#import "MSRechargeOne.h"
#import "MSRechargeTwo.h"
#import "MSRechargeThree.h"
#import "MSDrawCash.h"
#import "NSMutableDictionary+nilObject.h"
#import "MSCurrentInvestController.h"
#import "MSInvestConfirmController.h"
#import "MSAttornConfirmController.h"
#import "NSString+Ext.h"
#import "MSHomeFooterView.h"
#import "MSChargeStatusView.h"
#import "MSCashStatusViewController.h"
#import "RACEmptySubscriber.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height

@interface MSBalanceViewController ()<MSPayViewDelegate>
{
    RACDisposable *_accountInfoSubscription;
    RACDisposable *_assetInfoSubscription;
    RACDisposable *_withdrawConfigSubscription;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MSBalanceHeaderView *headerView;
@property (strong, nonatomic) MSBalanceBankCardView *bankCardView;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbUnit;
@property (strong, nonatomic) MSBalanceTextField *tfMoney;

@property (strong, nonatomic) UIButton *btnCommint;

@property (strong, nonatomic) MSPayView *payView;

@property (strong, nonatomic) BankInfo *bankInfo;
@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) AssetInfo *assertInfo;
@property (strong, nonatomic) WithdrawConfig *withdrawConfig;


@property (copy, nonatomic) NSString *tfChargeText;
@property (copy, nonatomic) NSString *tfCashText;

@property (strong, nonatomic) MSChargeStatusView *chargeStatusView;
@end

@implementation MSBalanceViewController

#pragma mark - lazy
- (MSChargeStatusView *)chargeStatusView {
    if (!_chargeStatusView) {
        _chargeStatusView = [[MSChargeStatusView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        @weakify(self);
        _chargeStatusView.block = ^{
            @strongify(self);
            if (self.getIntoType == MSBalanceGetIntoType_deterCurrentPage) {
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[MSCurrentInvestController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        return ;
                    }
                }
            }
            
            if (self.getIntoType == MSBalanceGetIntoType_deterInvestPage) {
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[MSInvestConfirmController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        return ;
                    }
                }
            }
            
            if (self.getIntoType == MSBalanceGetIntoType_deterLoanPage) {
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[MSAttornConfirmController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        return ;
                    }
                }
            }
            
            if (self.getIntoType == MSBalanceGetIntoType_accountPage) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        };
    }
    return _chargeStatusView;
}

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
    [self subscribe];
    [self queryWithDrawConfigue];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:@"我的余额-充值" pageId:119 params:nil];
    [self.tfMoney becomeFirstResponder];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
    
    if (_assetInfoSubscription) {
        [_assetInfoSubscription dispose];
        _assetInfoSubscription = nil;
    }
    
    if (_withdrawConfigSubscription) {
        [_withdrawConfigSubscription dispose];
        _withdrawConfigSubscription = nil;
    }
}

#pragma mark - query--drawConfigue
- (void)queryWithDrawConfigue {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryWithdrawConfig] subscribeNext:^(WithdrawConfig *withdrawConfig) {
        @strongify(self);
        self.withdrawConfig = withdrawConfig;
        [self updateBankCardView];
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSLog error:@"获取配置信息失败 result: %d", result.result];
        [MSToast show:@"获取配置信息失败"];
    }];
}

#pragma mark - query--BankList
- (void)querySupportBankList:(NSArray *)list{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] querySupportBankListByIds:list] subscribeNext:^(NSArray *supportBanksList) {
        @strongify(self);
        self.bankInfo = (BankInfo *)supportBanksList.firstObject;
        [self updateBankCardView];
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSLog error:@"获取银行卡信息失败 result: %d", result.result];
        [MSToast show:@"获取银行卡信息失败"];
    }];
}

#pragma mark - query--Charge
- (void)queryChargeOneStepMoney:(NSString *)money password:(NSString *)password{
    @weakify(self);
    NSDecimalNumber *amount = [[NSDecimalNumber alloc] initWithString:money];
    [[[MSAppDelegate getServiceManager] verifyRechargeInfoWithAmount:amount payPassword:password] subscribeNext:^(NSString *message) {
        @strongify(self);
        [self queryChargeTwoStep];
        
    } error:^(NSError *error) {
        @strongify(self);
        MSRechargeOne *rechargeOne = (MSRechargeOne *)error;
        if (rechargeOne.result > ERR_NONE) {
            switch (rechargeOne.result) {
                case MSRechargeOneModeError:
                case MSRechargeOneModeFrozen:
                case MSRechargeOneModeNoParams:
                {
                    [self ms_payViewDidCancel];
                    [self.chargeStatusView showWithStyle:MSChargeStatusType_error message:rechargeOne.message];
                    break;
                }
                case MSRechargeOneModePassWordMoreThanMax:
                {
                    [self ms_payViewDidCancel];
                    MSAlertController *alertVc = [MSAlertController alertControllerWithTitle:nil message:@"因交易密码错误多次，账号已锁定，请找回交易密码解锁" preferredStyle:UIAlertControllerStyleAlert];
                    [alertVc msSetMssageColor:[UIColor ms_colorWithHexString:@"#555555"] mssageFont:[UIFont systemFontOfSize:16.0]];
                    MSAlertAction *cancel = [MSAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                    cancel.mstextColor = [UIColor ms_colorWithHexString:@"#666666"];
                    MSAlertAction *sure = [MSAlertAction actionWithTitle:@"立即找回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self resetTradePassword];
                    }];
                    sure.mstextColor = [UIColor ms_colorWithHexString:@"#333092"];
                    [alertVc addAction:sure];
                    [alertVc addAction:cancel];
                    [self presentViewController:alertVc animated:YES completion:nil];
                    break;
                }
                case MSRechargeOneModePassWordError:
                {
                    [MSNotificationHelper notify:NOTIFY_CHECK_TRADEPASSWORDVIEW result:nil];
                    break;
                }
                default:
                    break;
            }
        } else if (rechargeOne.result < ERR_NONE){
            [self ms_payViewDidCancel];
            [MSLog error:@"网络错误  充值失败 result: %d", rechargeOne.result];
            if (rechargeOne.message && rechargeOne.message.length > 0) {
                [MSToast show:rechargeOne.message];
            }else{
                [MSToast show:@"哎呦，网络错误！"];
            }
        }
        
    }];
}

- (void)queryChargeTwoStep{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryRechargeVerifyCode] subscribeNext:^(NSString *message) {
        NSDictionary *dic = @{@"result" : @(MSRechargeTwoModeSuccess)};
        [MSNotificationHelper notify:NOTIFY_GET_VERIFICATIONCODE result:dic];
        
    } error:^(NSError *error) {
        @strongify(self);
        MSRechargeTwo *rechargeTwo = (MSRechargeTwo *)error;
        if (rechargeTwo.result > ERR_NONE) {
            switch (rechargeTwo.result) {
                case MSRechargeTwoModeTooFrequent:
                {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setNoNilObject:@(MSRechargeTwoModeTooFrequent) forKey:@"result"];
                    [dic setNoNilObject:rechargeTwo.message forKey:@"message"];
                    [MSNotificationHelper notify:NOTIFY_GET_VERIFICATIONCODE result:dic];
                    break;
                }
                case MSRechargeTwoModeFrozen:
                case MSRechargeTwoModeNoParams:
                case MSRechargeTwoModeError:
                {
                    [self ms_payViewDidCancel];
                    [self.chargeStatusView showWithStyle:MSChargeStatusType_error message:rechargeTwo.message];
                    break;
                }
                case MSRechargeTwoModeMoreThanRequestMax:
                {
                    [self ms_payViewDidCancel];
                    if (rechargeTwo.message && rechargeTwo.message.length > 0) {
                        [MSToast show:rechargeTwo.message];
                    }else{
                        [MSToast show:@"同一订单号请求验证码次数超过最大次数"];
                    }
                    break;
                }
                default:
                    break;
            }
        } else if(rechargeTwo.result < ERR_NONE) {
            [self ms_payViewDidCancel];
            [MSLog error:@"网络错误  充值失败 result: %d", rechargeTwo.result];
            if (rechargeTwo.message && rechargeTwo.message.length > 0) {
                [MSToast show:rechargeTwo.message];
            }else{
                [MSToast show:@"哎呦，网络错误！"];
            }
        }
    }];
}

- (void)queryChargeThreeStepWithPassword:(NSString *)password{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] rechargeByVerifyCode:password] subscribeNext:^(NSString *message) {
        @strongify(self);
        [self ms_payViewDidCancel];
        NSString *moneyStr = [NSString convertMoneyFormate:self.tfMoney.text.doubleValue];
        NSString *moneyTips = [NSString stringWithFormat:@"成功充值 %@ 元",moneyStr];
        [self.chargeStatusView showWithStyle:MSChargeStatusType_success message:moneyTips];
        [self pageEventWithTitle:@"充值成功" pageId:203 params:nil];
        
    } error:^(NSError *error) {
        @strongify(self);
        MSRechargeThree *rechargeThree = (MSRechargeThree *)error;
        if (rechargeThree.result > ERR_NONE) {
            switch (rechargeThree.result) {
                case MSRechargeThreeModeFrozen:
                case MSRechargeThreeModeError:
                case MSRechargeThreeModeNoParams:
                {
                    [self ms_payViewDidCancel];
                    [self.chargeStatusView showWithStyle:MSChargeStatusType_error message:rechargeThree.message];
                    break;
                }
                case MSRechargeThreeModeVeriCodeError:
                {
                    [MSNotificationHelper notify:NOTIFY_CHECK_VERIFICATIONCODE result:nil];
                    break;
                }
                default:
                    break;
            }
        } else if(rechargeThree.result < ERR_NONE) {
            [self ms_payViewDidCancel];
            [MSLog error:@"网络错误  充值失败 result: %d", rechargeThree.result];
            if (rechargeThree.message && rechargeThree.message.length > 0) {
                [MSToast show:rechargeThree.message];
            }else{
                [MSToast show:@"哎呦，网络错误！"];
            }
        }
    }];
}

#pragma mark - query--Cash
- (void)queryDrawcash:(NSString *)money password:(NSString *)password{
    @weakify(self);
    NSDecimalNumber *amount = [[NSDecimalNumber alloc] initWithString:money];
    [[[MSAppDelegate getServiceManager] withdrawWithAmount:amount payPassword:password] subscribeNext:^(NSString *message) {
        @strongify(self);
        [self ms_payViewDidCancel];
        NSString *moneyStr = [NSString convertMoneyFormate:self.tfMoney.text.doubleValue];
        NSString *moneyTips = [NSString stringWithFormat:@"成功提现 %@ 元",moneyStr];
        MSCashStatusViewController *vc = [[MSCashStatusViewController alloc] init];
        [vc updateWithType:MSCashStatusType_success money:moneyTips message:message];
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        @strongify(self);
        MSDrawCash *drawCash = (MSDrawCash *)error;
        
        if (drawCash.result > ERR_NONE) {
            switch (drawCash.result) {
                case MSDrawCashModeFrozen:
                case MSDrawCashModeNoEnoughBalance:
                case MSDrawCashModeNoParams:
                case MSDrawCashModeNoBindCard:
                {
                    [self ms_payViewDidCancel];
                    MSCashStatusViewController *vc = [[MSCashStatusViewController alloc] init];
                    [vc updateWithType:MSCashStatusType_error money:nil message:drawCash.message];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    break;
                }
                case MSDrawCashModePassWordMoreThanMax:
                {
                    [self ms_payViewDidCancel];
                    MSAlertController *alertVc = [MSAlertController alertControllerWithTitle:nil message:@"因交易密码错误多次，账号已锁定，请找回交易密码解锁" preferredStyle:UIAlertControllerStyleAlert];
                    [alertVc msSetMssageColor:[UIColor ms_colorWithHexString:@"#555555"] mssageFont:[UIFont systemFontOfSize:16.0]];
                    MSAlertAction *cancel = [MSAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                    cancel.mstextColor = [UIColor ms_colorWithHexString:@"#666666"];
                    MSAlertAction *sure = [MSAlertAction actionWithTitle:@"立即找回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self resetTradePassword];
                    }];
                    sure.mstextColor = [UIColor ms_colorWithHexString:@"#333092"];
                    [alertVc addAction:sure];
                    [alertVc addAction:cancel];
                    [self presentViewController:alertVc animated:YES completion:nil];
                    break;
                }
                case MSDrawCashModeCashCountTooMuch:
                {
                    [self ms_payViewDidCancel];
                    if (drawCash.message && drawCash.message.length > 0) {
                        [MSToast show:drawCash.message];
                    }else{
                        [MSToast show:@"今日提现次数已满"];
                    }
                    break;
                }
                case MSDrawCashModePassWordError:
                {
                    [MSNotificationHelper notify:NOTIFY_CHECK_TRADEPASSWORDVIEW result:nil];
                    break;
                }
                case MSDrawCashModeCashBeyondDayLimit:
                {
                    [self ms_payViewDidCancel];
                    [MSToast show:@"提现金额超过单日最大提现限额"];
                    break;
                }
                case MSDrawCashModeCashBeyondMonthLimit:
                {
                    [self ms_payViewDidCancel];
                    [MSToast show:@"提现金额超过单月最大提现限额"];
                    break;
                }
                default:
                    break;
            }
        }else if (drawCash.result < ERR_NONE){
            [self ms_payViewDidCancel];
            [MSLog error:@"网络错误  提现失败 result: %d", drawCash.result];
            if (drawCash.message && drawCash.message.length > 0) {
                [MSToast show:drawCash.message];
            }else{
                [MSToast show:@"哎呦，网络错误！"];
            }
        }
        
    }];
}

#pragma mark - Private
- (void)updateBankCardView {
    if (self.headerView.balanceType == BALANCE_RECHAGE) {
        self.bankCardView.cardViewStyle = MSBalanceBankCardViewStyle_charge;
    } else {
        self.bankCardView.cardViewStyle = MSBalanceBankCardViewStyle_cash;
    }
    [self.bankCardView updateWithBankInfo:self.bankInfo accountInfo:self.accountInfo withdrawConfig:self.withdrawConfig];
}

- (void)subscribe {
    @weakify(self);
    _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
        if (!self.bankInfo) {
            [self querySupportBankList:@[accountInfo.bankId]];
        }else {
            [self updateBankCardView];
        }
    }];
    
    _assetInfoSubscription = [[RACEventHandler subscribe:[AssetInfo class]] subscribeNext:^(AssetInfo *assertInfo) {
        @strongify(self);
        self.assertInfo = assertInfo;
        self.headerView.assertInfo = assertInfo;
    }];
    
    _withdrawConfigSubscription = [[RACEventHandler subscribe:[WithdrawConfig class]] subscribeNext:^(WithdrawConfig *withdrawConfig) {
        @strongify(self);
        self.withdrawConfig = withdrawConfig;
        [self updateBankCardView];
    }];
}

- (void)addSubViews {
    self.navigationItem.title = @"我的余额";
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 64)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self.view addSubview:self.scrollView];
    
    
    @weakify(self);
    self.headerView = [[MSBalanceHeaderView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 125)];
    self.headerView.block = ^(BALANCE_TYPE type) {
        @strongify(self);
        
        [self updateBankCardView];
        
        if (type == BALANCE_RECHAGE) {
            self.lbTitle.text = @"充值金额";
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"请输入要充值的金额" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
            self.tfMoney.attributedPlaceholder = attStr;
            [self.btnCommint setTitle:@"立即充值" forState:UIControlStateNormal];
            
            if (self.tfChargeText && self.tfChargeText.length > 0) {
                self.tfMoney.text = self.tfChargeText;
                self.btnCommint.enabled = YES;
            }else {
                self.tfMoney.text = nil;
                self.btnCommint.enabled = NO;
            }
            
        } else {
            self.lbTitle.text = @"提现金额";
            NSString *placeHolder = [NSString stringWithFormat:@"本次最多可提%@元",[NSString convertMoneyFormate:fmin(self.withdrawConfig.maxCash.doubleValue, self.withdrawConfig.dayCanCashAmount.doubleValue)]];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:placeHolder attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
            self.tfMoney.attributedPlaceholder = attStr;
            [self.btnCommint setTitle:@"确认提现" forState:UIControlStateNormal];
            
            if (self.tfCashText && self.tfCashText.length > 0) {
                self.tfMoney.text = self.tfCashText;
                self.btnCommint.enabled = YES;
            }else {
                self.tfMoney.text = nil;
                self.btnCommint.enabled = NO;
            }
        }
    };
    [self.scrollView addSubview:self.headerView];
    
    self.bankCardView = [[MSBalanceBankCardView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+8, self.view.width, 88)];
    self.bankCardView.cardViewStyle = MSBalanceBankCardViewStyle_charge;
    [self.scrollView addSubview:self.bankCardView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bankCardView.frame)+8, self.view.width, 96)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.contentView];
    self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.view.width - 32, 17)];
    self.lbTitle.font = [UIFont systemFontOfSize:12];
    self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbTitle.textAlignment = NSTextAlignmentLeft;
    self.lbTitle.text = @"充值金额";
    [self.contentView addSubview:self.lbTitle];
    
    self.lbUnit = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.lbTitle.frame)+14, 18, 33)];
    self.lbUnit.font = [UIFont systemFontOfSize:24];
    self.lbUnit.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbUnit.textAlignment = NSTextAlignmentCenter;
    self.lbUnit.text = @"￥";
    [self.contentView addSubview:self.lbUnit];
    
    self.tfMoney = [[MSBalanceTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lbUnit.frame)+8, 0, self.view.width - CGRectGetMaxX(self.lbUnit.frame) - 32, 30)];
    self.tfMoney.centerY = self.lbUnit.centerY;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"请输入要充值的金额" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
    self.tfMoney.attributedPlaceholder = attStr;
    self.tfMoney.keyboardType = UIKeyboardTypeDecimalPad;
    self.tfMoney.clearButtonMode = UITextFieldViewModeAlways;
    [self.tfMoney.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        self.btnCommint.enabled = (text.length > 0);
        if (self.headerView.balanceType == BALANCE_RECHAGE) {
            self.tfChargeText = text;
        }else {
            self.tfCashText = text;
        }
        
    }];
    [self.contentView addSubview:self.tfMoney];
    self.tfMoney.inputAccessoryView = [[MSInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
    
    self.btnCommint = [[UIButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.contentView.frame)+16, self.view.width - 32, 48)];
    [self.btnCommint setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.btnCommint setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.btnCommint setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    [self.btnCommint setTitle:@"立即充值" forState:UIControlStateNormal];
    self.btnCommint.layer.masksToBounds = YES;
    self.btnCommint.layer.cornerRadius = 24;
    self.btnCommint.enabled = NO;
    [[self.btnCommint rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.headerView.balanceType == BALANCE_RECHAGE) {
            [self charge];
        }else {
            [self cash];
        }
    }];
    [self.scrollView addSubview:self.btnCommint];
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.btnCommint.frame));
    
    self.tfCashText = nil;
    
    if (self.chargeMoney > 0) {
        self.btnCommint.enabled = YES;
        self.tfMoney.text = [NSString stringWithFormat:@"%.2f",ceil(self.chargeMoney*100)/100];
        self.tfChargeText = self.tfMoney.text;
    }else{
        self.btnCommint.enabled = NO;
        self.tfChargeText = nil;
    }
    
    MSHomeFooterView *footerView = [[MSHomeFooterView alloc] initWithFrame:CGRectMake(0, screenHeight - 64 - 40, self.view.width, 25)];
    footerView.tips = @"账户安全保障中";
    [self.scrollView addSubview:footerView];
}

- (void)charge {
    
    [self.tfMoney resignFirstResponder];
    
    if (![MSCheckInfoUtils amountOfChargeAndCashCheckou:self.tfMoney.text]) {
        [MSToast show:NSLocalizedString(@"hint_check_input_number", @"")];
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:119 params:@{@"error_msg":NSLocalizedString(@"hint_check_input_number", @"")}];
        return;
    }
    
    double amount = [self.tfMoney.text doubleValue];
    
    if (self.bankInfo.singleLimit > 0) {
        if (amount > self.bankInfo.singleLimit) {
            NSString *message = @"金额超过银行卡单笔限额，请修改充值金额。如需超额充值请到官网（mjsfax.com）进行网银充值";
            [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:119 params:@{@"error_msg":message}];
            MSAlertController *alertVc = [MSAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertVc msSetMssageColor:[UIColor ms_colorWithHexString:@"#555555"] mssageFont:[UIFont systemFontOfSize:16.0]];
            MSAlertAction *sure = [MSAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
            sure.mstextColor = [UIColor ms_colorWithHexString:@"#333092"];
            [alertVc addAction:sure];
            [self presentViewController:alertVc animated:YES completion:nil];
            return;
        }
    }
    
    if (amount <= 0) {
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:119 params:@{@"error_msg":NSLocalizedString(@"hint_check_charge_input_number", @"")}];
        [MSToast show:NSLocalizedString(@"hint_check_charge_input_number", @"")];
        return;
    }
    
    self.payView = [[MSPayView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.payView.delegate = self;
    self.payView.payMode = MSPayModeCharge;
    [self.payView updateMoney:[NSString stringWithFormat:@"充值%@元",self.tfMoney.text] protocolName:@"快捷支付服务协议" phoneNumber:self.accountInfo.cardBindPhone];
    [self.navigationController.view addSubview:self.payView];
    [self.payView pageEvent:154 title:@"输入交易密码"];
}

- (void)cash {
  
    [self.tfMoney resignFirstResponder];
    
    if (self.withdrawConfig.canCashCount <= 0) {
        NSString *tips = [NSString stringWithFormat:@"为了您的资金安全，每日可申请%ld次提现，请明日再试",(long)self.withdrawConfig.dayCashCountLimit];
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:@{@"error_msg":tips}];
        [MSToast show:tips];
        return;
    }
    
    if (![MSCheckInfoUtils amountOfChargeAndCashCheckou:self.tfMoney.text]) {
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:@{@"error_msg":NSLocalizedString(@"hint_check_input_number", @"")}];
        [MSToast show:NSLocalizedString(@"hint_check_input_number", @"")];
        return;
    }
    
    double amount = [self.tfMoney.text doubleValue];
    double min = self.withdrawConfig.minCash.doubleValue;
    double max = self.withdrawConfig.maxCash.doubleValue;
    double balance = self.assertInfo.balance.doubleValue;
    NSDecimalNumber *dayCanCashAmount = self.withdrawConfig.dayCanCashAmount;
    NSDecimalNumber *monthCanCashAmount = self.withdrawConfig.monthCanCashAmount;
    
    if (amount > balance) {
        NSString *message = @"您账户可提余额不足，请重新输入";
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:@{@"error_msg":message}];
        [MSToast show:message];
        return;
    }
    
    if (amount > max) {
        NSString *moneyStr;
        if (max >= 10000) {
            max = max / 10000;
            moneyStr = [NSString stringWithFormat:@"%.2f万",max];
        }else{
            moneyStr = [NSString stringWithFormat:@"%.2f",max];
        }
        NSString *tips = [NSString stringWithFormat:@"单笔最大提现金额为%@元，请重新输入",moneyStr];
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:@{@"error_msg":tips}];
        [MSToast show:tips];
        return;
    }
    
    if (amount < min) {
        NSString *tips = [NSString stringWithFormat:@"最小提现金额为%.2f元，请重新输入",min];
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:@{@"error_msg":tips}];
        [MSToast show:tips];
        return;
    }
    
    if (amount > dayCanCashAmount.integerValue) {
        NSString *message = @"提现金额超过单日最大提现限额";
        [MSToast show:message];
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:@{@"error_msg":message}];
        return;
    }
    
    if (amount > monthCanCashAmount.integerValue) {
        NSString *message = @"提现金额超过单月最大提现限额";
        [MSToast show:message];
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:@{@"error_msg":message}];
        return;
    }
    
    self.payView = [[MSPayView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.payView.delegate = self;
    self.payView.payMode = MSPayModeCash;
    [self.payView updateMoney:[NSString stringWithFormat:@"提现%@元",self.tfMoney.text] protocolName:nil phoneNumber:nil];
    [self.navigationController.view addSubview:self.payView];
    [self.payView pageEvent:153 title:nil];
}

- (void)resetTradePassword {
    MSResetTradePasswordA *resetTradePassword = [[MSResetTradePasswordA alloc] init];
    [self.navigationController pushViewController:resetTradePassword animated:YES];
}

#pragma mark - MSPayViewDelegate
- (void)ms_payViewDidCancel {
    [self.payView removeFromSuperview];
    self.payView = nil;
}

- (void)ms_payViewDidInputTradePassword:(NSString *)tradePassword {
    if (self.headerView.balanceType == BALANCE_RECHAGE) {
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:119 params:nil];
        [self queryChargeOneStepMoney:self.tfMoney.text password:[NSString desWithKey:tradePassword key:nil]];
    }else {
        [self eventWithName:@"确认" elementId:22 title:self.navigationItem.title pageId:120 params:nil];
        [self queryDrawcash:self.tfMoney.text password:[NSString desWithKey:tradePassword key:nil]];
    }
}

- (void)ms_payViewDidForgetTradePassword {
    [self ms_payViewDidCancel];
    [self resetTradePassword];
}

- (void)ms_payViewDidLookProtocol {
    [self ms_payViewDidCancel];
    MSWebViewController *webViewController = [MSWebViewController load];
    webViewController.url = [[MSAppDelegate getServiceManager] getSysConfigs].rechargeProtocolUrl;
    webViewController.title = @"快捷支付服务协议";
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)ms_payViewDidClickConfirmButton:(NSString *)verificationCode {
    [self queryChargeThreeStepWithPassword:verificationCode];
}

- (void)ms_payViewNeedVerificationCode {
    [self eventWithName:@"获取验证码" elementId:151 title:self.navigationItem.title pageId:119 params:nil];
    [self queryChargeTwoStep];
}

@end
