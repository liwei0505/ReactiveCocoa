//
//  MSTransferApplyController.m
//  Sword
//
//  Created by haorenjie on 16/6/29.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSTransferApplyController.h"
#import "MSLog.h"
#import "MSAppDelegate.h"
#import "MSNotificationHelper.h"
#import "MSTextUtils.h"
#import "MSToast.h"
#import "MSAlert.h"
#import "MSConfig.h"
#import "MSWebViewController.h"
#import "MSUrlManager.h"
#import "MJSStatistics.h"
#import "SystemConfigs.h"

@interface MSTransferApplyController () <UITextFieldDelegate>
{
    double _debtValue;
}

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbOrignalValue;
@property (weak, nonatomic) IBOutlet UILabel *lbCanTrasnferAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbLeftTerm;
@property (weak, nonatomic) IBOutlet UILabel *lbReceivedInterest;
@property (weak, nonatomic) IBOutlet UILabel *lbIncomingInterest;
@property (weak, nonatomic) IBOutlet UILabel *lbDiscountRate;
@property (weak, nonatomic) IBOutlet UILabel *lbFee;
@property (weak, nonatomic) IBOutlet UITextField *tfTransferPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnProtocolCheck;
@property (weak, nonatomic) IBOutlet UIButton *btnProtocol;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@end

@implementation MSTransferApplyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"str_transfer_apply", nil);
    DebtTradeInfo *attornInfo = [[MSAppDelegate getServiceManager] getCanTransferDebt:self.debtId];
    [self updateAttornInfo:attornInfo];
    
    [self.btnConfirm setBackgroundImage:[UIImage imageNamed:@"button_disable"] forState:UIControlStateDisabled];
    [self.btnConfirm setBackgroundImage:[UIImage imageNamed:@"button_all"] forState:UIControlStateNormal];
    self.btnConfirm.enabled = NO;
    self.btnProtocolCheck.selected = PROTOCOL_AUTO_SELECTED;
    [self makeSureConfirmBtnCanTapWithString:self.tfTransferPrice.text];
    self.tfTransferPrice.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [MSNotificationHelper addObserver:self selector:@selector(textFieldTextChange:) name:UITextFieldTextDidChangeNotification];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)]];
   
}

- (void)hidenKeyboard
{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[MSAppDelegate getServiceManager] getSysConfigs]) {
        [self querySystemConfig];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc
{
    [MSNotificationHelper removeObserver:self];
    NSLog(@"%s",__func__);
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.tfTransferPrice resignFirstResponder];
    return YES;
}

#pragma mark - actions
- (IBAction)onProtocolCheckButtonClicked:(id)sender
{
    self.btnProtocolCheck.selected = !self.btnProtocolCheck.selected;
    [self makeSureConfirmBtnCanTapWithString:self.tfTransferPrice.text];
}

- (void)makeSureConfirmBtnCanTapWithString:(NSString *)string
{
    if (self.btnProtocolCheck.selected && string.length > 0) {
        self.btnConfirm.enabled = YES;
    }else{
        self.btnConfirm.enabled = NO;
    }
}

- (IBAction)onProtocolButtonClicked:(id)sender
{
    MSWebViewController *viewController = [MSWebViewController load];
    viewController.title = NSLocalizedString(@"str_transfer_protocol_name", nil);
    NSString *urlStr = [[MSAppDelegate getServiceManager] getInvestAgreementById:self.debtId];
    viewController.url = urlStr;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onTransferConfirmButtonClicked:(id)sender
{
    
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:135 control:19 params:nil];
    NSString *inputText = self.tfTransferPrice.text;
    if ([MSTextUtils isEmpty:inputText]) {
        [MSToast show:NSLocalizedString(@"hint_input_transfer_price", nil)];
        return;
    }

    double amount = [inputText doubleValue];
    if (amount > _debtValue) {
        [MSToast show:NSLocalizedString(@"hint_transfer_price_not_more_than_the_value", nil)];
        return;
    }


    double discountRate = amount / _debtValue * 100.f;
    
    SystemConfigs *systemConfig = [[MSAppDelegate getServiceManager] getSysConfigs];
    
    if (discountRate < systemConfig.minDiscountRate) {
        double minPrice = _debtValue * systemConfig.minDiscountRate / 100.f;
        NSString *hintFmt = NSLocalizedString(@"hint_transfer_price_must_more_than", nil);
        [MSToast show:[NSString stringWithFormat:hintFmt, minPrice]];
        return;
    }

    if (discountRate > systemConfig.maxDiscountRate) {
        double maxPrice = _debtValue * systemConfig.maxDiscountRate / 100.f;
        NSString *hintFmt = NSLocalizedString(@"hint_trasnfer_price_must_less_than", nil);
        [MSToast show:[NSString stringWithFormat:hintFmt, maxPrice]];
        return;
    }

    [self sellDebt:self.debtId discount:amount];
}

#pragma mark - notifications
- (void)textFieldTextChange:(NSNotification *)notification
{
    self.tfTransferPrice = (UITextField *)notification.object;
    NSString *text = self.tfTransferPrice.text;
    if (text.length > 11) {
        text = [text substringWithRange:NSMakeRange(0, 11)];
        self.tfTransferPrice.text = text;
        [MSToast show:@"最多输入11位"];
    }
    
    [self updateDiscountRate:[text doubleValue]];
    [self makeSureConfirmBtnCanTapWithString:text];
    
}

#pragma mark - privates
- (void)querySystemConfig {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] querySystemConfig] subscribeNext:^(id x) {
        @strongify(self);
        NSString *text = self.tfTransferPrice.text;
        if (text) {
            [self updateDiscountRate:[text doubleValue]];
        }
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSLog error:@"Query system configs failed: %d", result.result];
    }];
}

- (void)sellDebt:(NSNumber *)debtId discount:(double)discount
{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] sellDebtById:debtId discount:@(discount)] subscribeNext:^(NSDictionary *dic) {
        @strongify(self);
        
        NSNumber *debtId_ = dic[KEY_DEBT_ID];
        if (![self.debtId isEqualToNumber:debtId_]) {
            return;
        }
        
        [MSAlert showWithTitle:@"" message:NSLocalizedString(@"hint_transfer_success", nil)buttonClickBlock:^(NSInteger buttonIndex) {
            [MSNotificationHelper notify:NOTIFY_INVEST_LIST_RELOAD result:nil];
            [MSNotificationHelper notify:NOTIFY_MY_ATTORN_LIST_RELOAD result:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } cancelButtonTitle:NSLocalizedString(@"str_confirm", nil) otherButtonTitles:nil];
        
    } error:^(NSError *error) {
       [MSToast show:NSLocalizedString(@"hint_transfer_failed", nil)];
    }];
}

- (void)updateAttornInfo:(DebtTradeInfo *)attornInfo
{
    self.lbTitle.text = attornInfo.debtInfo.loanInfo.baseInfo.title;
    double totalAmount = attornInfo.receivedInterest + attornInfo.receivedPrincipal + attornInfo.incomingInterest + attornInfo.incomingPrincipal;
    self.lbOrignalValue.text = [NSString stringWithFormat:@"%.2f", totalAmount];
    _debtValue = [attornInfo.debtInfo.value doubleValue];
    self.lbCanTrasnferAmount.text = attornInfo.debtInfo.value;
    self.lbLeftTerm.text = attornInfo.debtInfo.termCount;
    NSString *amountFmt = NSLocalizedString(@"fmt_reward_amount", nil);
    self.lbReceivedInterest.text = [NSString stringWithFormat:amountFmt, attornInfo.receivedInterest];
    self.lbIncomingInterest.text = [NSString stringWithFormat:amountFmt, attornInfo.incomingInterest];
    self.lbDiscountRate.text = @"--";
    self.lbFee.text = @"--";
}

- (void)updateDiscountRate:(double)amount
{
    SystemConfigs *systemConfig = [[MSAppDelegate getServiceManager] getSysConfigs];
    
    double fee = amount * systemConfig.transferFee / 100.f;
    if (fee < systemConfig.minFee) {
        fee = systemConfig.minFee;
    } else if (fee > systemConfig.maxFee) {
        fee = systemConfig.maxFee;
    }
    NSString *amountFmt = NSLocalizedString(@"fmt_reward_amount", nil);
    self.lbFee.text = [NSString stringWithFormat:amountFmt, fee];

    double discountRate = amount / _debtValue * 100.f;
    self.lbDiscountRate.text = [NSString stringWithFormat:@"%.2f%%", discountRate];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 135;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
}

@end
