//
//  MSCashController.m
//  Sword
//
//  Created by lee on 16/6/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSCashController.h"
#import "MSAppDelegate.h"
#import "MSStoryboardLoader.h"
#import "MSWebViewController.h"
#import "MSToast.h"
#import "MSCheckInfoUtils.h"
#import "NSString+Ext.h"

@interface MSCashController()<UITextFieldDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UIButton *cashBtn;
@property (weak, nonatomic) IBOutlet UITextField *cashAmount;
@property (weak, nonatomic) IBOutlet UIButton *clearAmount;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *cashTime;
@property (nonatomic,strong) MSUserModel *userModel;

@end

@implementation MSCashController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    _userModel = [[MSAppDelegate getInstance] getUserModel];
    [self prepareUI];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.cashAmount becomeFirstResponder];
}

- (void)hidenKeyboard
{
    [self.view endEditing:YES];
}

- (IBAction)onCash:(id)sender {
  
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:120 control:23 params:nil];
    
    if (self.userModel.userAccountInfo.canCashCount <= 0) {
        [MSToast show:NSLocalizedString(@"str_account_cash_time", @"")];
        return;
    }
    
    if (![MSCheckInfoUtils amountOfChargeAndCashCheckou:self.cashAmount.text]) {
        [MSToast show:NSLocalizedString(@"hint_check_input_number", @"")];
        return;
    }
    
    double amount = [self.cashAmount.text doubleValue];
    double min = self.userModel.userAccountInfo.minCash;
    double max = self.userModel.userAccountInfo.maxCash;
    double balance = self.userModel.userAccountInfo.assetInfo.balance;
    double maxAmount = (balance > max) ? max:balance;
    if (amount > maxAmount) {
        NSString *hintStr = [NSString stringWithFormat:NSLocalizedString(@"fmt_account_cash_max", @""),maxAmount];
        [MSToast show:hintStr];
        return;
        
    } else if (amount < min) {
        NSString *hintStr = [NSString stringWithFormat:NSLocalizedString(@"fmt_account_cash_min", @""),min];
        [MSToast show:hintStr];
        return;
    }
    NSString *url = [_userModel queryCashWebSite:amount];
    MSWebViewController *webViewController = [MSWebViewController load];
    webViewController.title = NSLocalizedString(@"str_account_cash", @"");
    webViewController.url = url;
    [self.navigationController pushViewController:webViewController animated:YES];
    [self.view endEditing:YES];

}

#pragma mark - UI

- (void)prepareUI {
    
    self.navigationItem.title = NSLocalizedString(@"str_account_cash", @"");
    [self.cashBtn setTitle:NSLocalizedString(@"str_confirm_cash", @"") forState:UIControlStateNormal];
    self.balance.text = [NSString convertMoneyFormate:self.userModel.userAccountInfo.assetInfo.balance];
    self.cashAmount.delegate = self;
    self.webView.delegate = self;
    [self.cashBtn setEnabled:NO];
    self.clearAmount.hidden = YES;
    [self.cashAmount addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.cashTime.text = [NSString stringWithFormat:NSLocalizedString(@"fmt_account_cash_time", @""),self.userModel.userAccountInfo.canCashCount];
    
    NSURL *resourceURL = [[NSBundle mainBundle]URLForResource:@"pay_cash.webarchive" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:resourceURL];
    NSString *js = @"window.onload = function(){ document.body.style.backgroundColor = '#F8F8F8'; }";
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    [self.webView loadRequest:request];
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length == 0) {
        [self.cashBtn setEnabled:NO];
    } else {
        self.clearAmount.hidden = NO;
        [self.cashBtn setEnabled:YES];
    }
}

- (IBAction)deletePhoneNumber:(UIButton *)sender {
    
    self.cashAmount.text = nil;
    self.clearAmount.hidden = YES;
    [self.cashBtn setEnabled:NO];
    
}

- (IBAction)touchDownResignKeyboard:(id)sender {
    
    [self.cashAmount resignFirstResponder];
    
}


@end
