//
//  MSAttornConfirmController.m
//  Sword
//
//  Created by haorenjie on 16/6/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSAttornConfirmController.h"
#import "MSLog.h"
#import "MSToast.h"
#import "MSConfig.h"
#import "MSUrlManager.h"
#import "MSAppDelegate.h"
#import "MSBalanceViewController.h"
#import "MSStoryboardLoader.h"
#import "MSWebViewController.h"
#import "MSNotificationHelper.h"
#import "MSNavigationController.h"
#import "MSPayView.h"
#import "MSResetTradePasswordA.h"
#import "NSString+Ext.h"
#import "MSPayStatusController.h"
#import "MSAlertController.h"
#import "DebtAgreementInfo.h"
#import "DebtDetail.h"
#import "MSBuyDebt.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height

@interface MSAttornConfirmController ()<MSPayViewDelegate>
{
    RACDisposable *_accountInfoSubscription;
    RACDisposable *_assetInfoSubscription;
}

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbEarnings;
@property (weak, nonatomic) IBOutlet UILabel *lbTerm;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbBalance;
@property (weak, nonatomic) IBOutlet UILabel *lbPayment;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UIButton *btnProtocol;
@property (weak, nonatomic) IBOutlet UILabel *protocol;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (strong, nonatomic) MSPayView *payView;
@property (strong, nonatomic) DebtAgreementInfo *debtAgreementInfo;
@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) AssetInfo *assetInfo;

@end

@implementation MSAttornConfirmController

- (MSPayView *)payView
{
    if (!_payView) {
        _payView = [[MSPayView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        _payView.delegate = self;
    }
    return _payView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnProtocol.hidden = YES;

    self.title = NSLocalizedString(@"str_attorn_confirm_info", nil);

    DebtDetail *debtInfo = [[MSAppDelegate getServiceManager] getDebtInfo:self.debtId];
    self.lbTitle.text = debtInfo.baseInfo.loanInfo.baseInfo.title;
    NSString *format = NSLocalizedString(@"fmt_term_day", nil);
    self.lbTerm.text = [NSString stringWithFormat:format, debtInfo.baseInfo.leftTermCount];
    self.protocol.text = NSLocalizedString(@"str_regist_agree", @"");
    NSString *amountFormat = NSLocalizedString(@"fmt_reward_amount", nil);
    self.lbAmount.text = [NSString stringWithFormat:amountFormat, debtInfo.payAmount];
    self.lbPayment.text = self.lbAmount.text;
    
    double amount = debtInfo.expectedEarning;
    if (amount >= 10000) {
        amount /= 10000.00;
        self.lbEarnings.text = [NSString stringWithFormat:@"%.2f万", amount];
    } else {
    
        self.lbEarnings.text = [NSString stringWithFormat:amountFormat, amount];
    }
    
    self.btnCheck.selected = PROTOCOL_AUTO_SELECTED;
    self.btnConfirm.enabled = self.btnCheck.selected;
    
    [self.btnConfirm setBackgroundImage:[UIImage imageNamed:@"button_disable"] forState:UIControlStateDisabled];
    [self.btnConfirm setBackgroundImage:[UIImage imageNamed:@"button_all"] forState:UIControlStateNormal];
    
    [self queryDebtAgreementInfo:self.debtId];

    @weakify(self);
    _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
    }];
    
    _assetInfoSubscription = [[RACEventHandler subscribe:[AssetInfo class]] subscribeNext:^(AssetInfo *assetInfo) {
        @strongify(self);
        self.assetInfo = assetInfo;
        [self updateBalanceInfo];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
    if (_assetInfoSubscription) {
        [_assetInfoSubscription dispose];
        _assetInfoSubscription = nil;
    }
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 138;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
    
}

#pragma mark - actions
- (IBAction)onRechargeButtonClicked:(id)sender
{
    MSBalanceViewController *vc = [[MSBalanceViewController alloc] init];
    vc.getIntoType = MSBalanceGetIntoType_deterLoanPage;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onCheckedButtonClicked:(id)sender
{
    self.btnCheck.selected = !self.btnCheck.selected;
    self.btnConfirm.enabled = self.btnCheck.selected;
}

- (IBAction)onProtocolButtonClicked:(id)sender
{
    MSWebViewController *viewController = [MSWebViewController load];
    viewController.title = self.debtAgreementInfo.contractTitle,
    viewController.url = self.debtAgreementInfo.url;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onAttornConfirmButtonClicked:(id)sender
{
    DebtDetail *debtInfo = [[MSAppDelegate getServiceManager] getDebtInfo:self.debtId];
    if (self.assetInfo.balance.doubleValue < debtInfo.payAmount) {
        
        [MSToast show:NSLocalizedString(@"hint_balance_not_enough", nil)];
        
        MSBalanceViewController *vc = [[MSBalanceViewController alloc] init];
        vc.getIntoType = MSBalanceGetIntoType_deterLoanPage;
        vc.chargeMoney = debtInfo.payAmount - self.assetInfo.balance.doubleValue;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    self.payView.payMode = MSPayModeLoan;
    [self.payView updateMoney:[NSString stringWithFormat:@"支付%@",self.lbPayment.text] protocolName:nil phoneNumber:nil];
    [self.navigationController.view addSubview:self.payView];

}

#pragma mark - MSPayViewDelegate
- (void)ms_payViewDidCancel
{
    [self.payView removeFromSuperview];
    self.payView = nil;
}
- (void)ms_payViewDidInputTradePassword:(NSString *)tradePassword
{
    [self queryBuyDebt:self.debtId.stringValue password:[NSString desWithKey:tradePassword key:nil]];
}
- (void)ms_payViewDidForgetTradePassword
{
    [self ms_payViewDidCancel];
    [self resetTradePassword];
    
}

#pragma mark - Private
- (void)resetTradePassword {
    MSResetTradePasswordA *resetTradePassword = [[MSResetTradePasswordA alloc] init];
    [self.navigationController pushViewController:resetTradePassword animated:YES];
}

- (void)updateBalanceInfo {
    NSString *amountFormat = NSLocalizedString(@"fmt_reward_amount", nil);
    self.lbBalance.text = [NSString stringWithFormat:amountFormat, self.assetInfo.balance];
}

- (void)queryDebtAgreementInfo:(NSNumber *)debtId{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryDebtAgreementById:debtId] subscribeNext:^(DebtAgreementInfo *debtAgreementInfo) {
        @strongify(self);
        self.btnProtocol.hidden = NO;
        self.debtAgreementInfo = debtAgreementInfo;
        NSString *title = [NSString stringWithFormat:@"《%@》",debtAgreementInfo.contractTitle];
        [self.btnProtocol setTitle:title forState:UIControlStateNormal];
    } error:^(NSError *error) {
        self.btnProtocol.hidden = YES;
    }];
}

- (void)updatePayStatusSubMode:(MSPayStatusSubMode)subMode payStatusMode:(MSPayStatusMode)payStatusMode withMessage:(NSString *)message {
    
    MSPayStatusController *vc = [[MSPayStatusController alloc] init];
    [vc updatePayStatusSubMode:subMode payStatusMode:payStatusMode withMessage:message];
    vc.backActionBlock = ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)queryBuyDebt:(NSString *)debtId password:(NSString *)password{
    @weakify(self);
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    NSNumber *buyDebtId = [format numberFromString:debtId];
    [[[MSAppDelegate getServiceManager] buyDebtOfId:buyDebtId payPassword:password] subscribeNext:^(NSString *message) {
        @strongify(self);
        [self ms_payViewDidCancel];
        [MSNotificationHelper notify:NOTIFY_INVEST_LIST_RELOAD result:nil];
        [self updatePayStatusSubMode:MSPayStatusSubModeLoan payStatusMode:MSPayStatusModeSuccess withMessage:message];

    } error:^(NSError *error) {
        @strongify(self);
        MSBuyDebt *buyDebt = (MSBuyDebt *)error;
        if (buyDebt.result > ERR_NONE) {
            switch (buyDebt.result) {
                case MSBuyDebtModeError:
                case MSBuyDebtModeNoSupport:
                case MSBuyDebtModeNoEnoughBalance:
                case MSBuyDebtModeNoParams:
                {
                    [self ms_payViewDidCancel];
                    [self updatePayStatusSubMode:MSPayStatusSubModeLoan payStatusMode:MSPayStatusModeFail withMessage:buyDebt.message];
                    break;
                }
                case MSBuyDebtModePassWordMoreThanMax:
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
                case MSBuyDebtModePassWordError:
                {
                    [MSNotificationHelper notify:NOTIFY_CHECK_TRADEPASSWORDVIEW result:nil];
                    break;
                }
                default:
                    break;
            }
        } else if (buyDebt.result < ERR_NONE) {
            [self ms_payViewDidCancel];
            [MSLog error:@"网络错误  认购失败 result: %d", buyDebt.result];
            if (buyDebt.message && buyDebt.message.length > 0) {
                [MSToast show:buyDebt.message];
            }else{
                [MSToast show:@"哎呦，网络错误！"];
            }
        }
    }];
}

@end
