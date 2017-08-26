//
//  MSChargeController.m
//  Sword
//
//  Created by lee on 16/6/14.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSChargeController.h"
#import "MSAppDelegate.h"
#import "MSWebViewController.h"
#import "MSToast.h"
#import "MSCheckInfoUtils.h"
#import "NSString+Ext.h"

@interface MSChargeController()<UITextFieldDelegate, MSWebViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UIButton *chargeBtn;
@property (weak, nonatomic) IBOutlet UITextField *chargeAmount;
@property (weak, nonatomic) IBOutlet UIButton *clearAmount;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic,strong) MSUserModel *userModel;

@end

@implementation MSChargeController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self prepareUI];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (self.type == ChargeType_push) {
        
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonOnClick)];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.chargeAmount becomeFirstResponder];
}

- (void)hidenKeyboard
{
    [self.view endEditing:YES];
}

- (void)backButtonOnClick
{
    if (self.type == ChargeType_push) {
        
    } else {
        [self.chargeAmount resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)onCharge:(id)sender {
 
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:119 control:22 params:nil];
    
    if (![MSCheckInfoUtils amountOfChargeAndCashCheckou:self.chargeAmount.text]) {
        [MSToast show:NSLocalizedString(@"hint_check_input_number", @"")];
        return;
    }
    
    double amount = [self.chargeAmount.text doubleValue];
    if (amount > 1000000.00) {
        [MSToast show:NSLocalizedString(@"hint_alert_charge_amount_beyond", @"")];
        return;
    }
    
    if (amount <= 0) {
        [MSToast show:NSLocalizedString(@"hint_check_charge_input_number", @"")];
        return;
    }
    
    NSString *url = [_userModel queryRechargeWebSite:amount];
    MSWebViewController *webViewController = [MSWebViewController load];
    webViewController.title = NSLocalizedString(@"str_account_charge", @"");
    webViewController.url = url;
    
    if (self.type == ChargeType_push) {
        
    } else {
        webViewController.delegate = self;
    }
    [self.navigationController pushViewController:webViewController animated:YES];
    [self.view endEditing:YES];
}

#pragma mark - delegate
- (void)webViewControllerdDidDismissViewController:(MSWebViewController *)webViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI 

- (void)prepareUI {

    _userModel = [[MSAppDelegate getInstance] getUserModel];
    
    self.navigationItem.title = NSLocalizedString(@"str_account_charge", @"");
    self.balance.text = [NSString convertMoneyFormate:self.userModel.userAccountInfo.assetInfo.balance];
    self.chargeAmount.delegate = self;
    
    [self.chargeBtn setTitle:NSLocalizedString(@"str_confirm_charge", @"") forState:UIControlStateNormal];
    [self.chargeAmount addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (self.chargeMoney > 0) {
        [self.chargeBtn setEnabled:YES];
        self.clearAmount.hidden = NO;
        self.chargeAmount.text = [NSString stringWithFormat:@"%.2f",ceil(self.chargeMoney*100)/100];
    }else{
        [self.chargeBtn setEnabled:NO];
        self.clearAmount.hidden = YES;
    }
    
    NSURL *resourceURL = [[NSBundle mainBundle]URLForResource:@"pay_recharge.webarchive" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:resourceURL];
    NSString *js = @"window.onload = function(){ document.body.style.backgroundColor = '#F8F8F8'; }";
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    [self.webView loadRequest:request];
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    
}

- (void)textFieldDidChange:(UITextField *)textField {

    if (textField.text.length == 0) {
        [self.chargeBtn setEnabled:NO];
    } else {
        self.clearAmount.hidden = NO;
        [self.chargeBtn setEnabled:YES];
    }
}

- (IBAction)deletePhoneNumber:(UIButton *)sender {
    
    self.chargeAmount.text = nil;
    self.clearAmount.hidden = YES;
    [self.chargeBtn setEnabled:NO];
    
}

- (IBAction)touchDownResignKeyboard:(id)sender {
    
    [self.view endEditing:YES];
    
}

@end
