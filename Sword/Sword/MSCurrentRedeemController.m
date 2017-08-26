//
//  MSCurrentRedeemController.m
//  Sword
//
//  Created by msj on 2017/4/6.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentRedeemController.h"
#import "MSWebViewController.h"
#import "UIView+FrameUtil.h"
#import "MSCurrentTextField.h"
#import "MSInputAccessoryView.h"
#import "NSDate+Add.h"
#import "MSCheckInfoUtils.h"
#import "MSPayView.h"
#import "MSResetTradePasswordA.h"
#import "NSString+Ext.h"
#import "MSCurrentResultController.h"
#import "UINavigationController+removeAtIndex.h"
#import "UIImage+color.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height

@interface MSCurrentRedeemController ()<MSPayViewDelegate>
@property (strong, nonatomic) UIButton *btnRule;
@property (strong, nonatomic) MSCurrentTextField *textField;
@property (strong, nonatomic) UILabel *lbConfigue;
@property (strong, nonatomic) UIButton *btnSure;
@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) MSPayView *payView;

@property (strong, nonatomic) CurrentRedeemConfig *redeemConfig;
@end

@implementation MSCurrentRedeemController

#pragma mark - Lazy
- (MSPayView *)payView{
    
    if (!_payView) {
        _payView = [[MSPayView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        _payView.delegate = self;
    }
    return _payView;
}

#pragma mark - LifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configueElement];
    [self addSubViews];
    [self queryCurrentRedeemConfig];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - MSPayViewDelegate
- (void)ms_payViewDidCancel{
    [self.payView removeFromSuperview];
    self.payView = nil;
}

- (void)ms_payViewDidInputTradePassword:(NSString *)tradePassword{
    [self redeemCurrentWithTradePassword:tradePassword];
}

- (void)ms_payViewDidForgetTradePassword{
    [self ms_payViewDidCancel];
    [self resetTradePassword];
}

- (void)resetTradePassword {
    MSResetTradePasswordA *resetTradePassword = [[MSResetTradePasswordA alloc] init];
    [self.navigationController pushViewController:resetTradePassword animated:YES];
}

#pragma mark - Private
- (void)configueElement {
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    self.navigationItem.title = @"赎回至余额";
    self.btnRule = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 14)];
    self.btnRule.showsTouchWhenHighlighted = YES;
    [self.btnRule setTitle:@"规则说明" forState:UIControlStateNormal];
    self.btnRule.titleLabel.font = [UIFont systemFontOfSize:13];
    self.btnRule.hidden = YES;
    @weakify(self);
    [[self.btnRule rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        MSWebViewController *webVC = [MSWebViewController load];
        webVC.url = self.redeemConfig.redeemRulesURL;
        webVC.navigationItem.title = @"规则说明";
        [self.navigationController pushViewController:webVC animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnRule];
}

- (void)addSubViews {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    [self.view addSubview:scrollView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, 125)];
    topView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:topView];
    
    self.textField = [[MSCurrentTextField alloc] initWithFrame:CGRectMake(20, 32, self.view.width - 40, 40)];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"请输入赎回金额" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#C9D0D5"]}];
    self.textField.attributedPlaceholder = attStr;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    UILabel *leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    leftView.text = @"元";
    leftView.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    leftView.textAlignment = NSTextAlignmentCenter;
    leftView.font = [UIFont systemFontOfSize:14];
    self.textField.rightView = leftView;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    self.textField.inputAccessoryView = [[MSInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    @weakify(self);
    [self.textField.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        self.btnSure.enabled = (text.length > 0);
    }];
    [topView addSubview:self.textField];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textField.frame) + 10, 16, 16)];
    imageView.image = [UIImage imageNamed:@"can_redeem"];
    [topView addSubview:imageView];
    
    self.lbConfigue = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 8, 0, self.view.width - (CGRectGetMaxX(imageView.frame) + 8) - 20, 14)];
    self.lbConfigue.centerY = imageView.centerY;
    self.lbConfigue.textAlignment = NSTextAlignmentLeft;
    self.lbConfigue.font = [UIFont systemFontOfSize:11];
    self.lbConfigue.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbConfigue.text = @"本次可赎回：--元，剩余--次";
    [topView addSubview:self.lbConfigue];
    
    self.btnSure = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame)+20, self.view.width, 44)];
    [self.btnSure setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#FC646A"] withSize:CGSizeMake(self.view.width, 44)] forState:UIControlStateNormal];
    [self.btnSure setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#F0F0F0"] withSize:CGSizeMake(self.view.width, 44)] forState:UIControlStateDisabled];
    [self.btnSure setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#E5494F"] withSize:CGSizeMake(self.view.width, 44)] forState:UIControlStateHighlighted];
    [self.btnSure setTitle:@"确认赎回" forState:UIControlStateNormal];
    [self.btnSure setTitleColor:[UIColor ms_colorWithHexString:@"#ADADAD"] forState:UIControlStateDisabled];
    [self.btnSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnSure.enabled = NO;
    [scrollView addSubview:self.btnSure];
    [[self.btnSure rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self redeem];
    }];
    
    self.lbTime = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.btnSure.frame) + 12, self.view.width - 24, 12)];
    self.lbTime.textAlignment = NSTextAlignmentLeft;
    self.lbTime.font = [UIFont systemFontOfSize:11];
    self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbTime.text = @"预计----到达账户余额";
    [scrollView addSubview:self.lbTime];
}

- (void)redeem {
    
    if (![MSCheckInfoUtils amountOfChargeAndCashCheckou:self.textField.text]) {
        [MSToast show:@"输入金额不正确"];
        return;
    }
    
    if (self.redeemConfig.leftCanRedeemCount <= 0) {
        [MSToast show:@"超过赎回次数"];
        return;
    }
    
    if (self.textField.text.doubleValue > self.redeemConfig.leftCanRedeemAmount.doubleValue) {
        [MSToast show:@"超过本次最多可赎回金额"];
        return;
    }
    
    self.payView.payMode = MSPayModeCurrentRedeem;
    [self.payView updateMoney:[NSString stringWithFormat:@"赎回%@元",self.textField.text] protocolName:nil phoneNumber:nil];
    [self.navigationController.view addSubview:self.payView];
}

- (void)updateUI {
    self.btnRule.hidden = NO;
    self.lbConfigue.text = [NSString stringWithFormat:@"本次可赎回：%.2f元，剩余%ld次",self.redeemConfig.leftCanRedeemAmount.doubleValue,(long)self.redeemConfig.leftCanRedeemCount];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.redeemConfig.earningsReceiveDate];
    self.lbTime.text = [NSString stringWithFormat:@"预计%ld-%02ld-%02ld到达账户余额",(long)date.year,(long)date.month,(long)date.day];
}

- (void)redeemCurrentWithTradePassword:(NSString *)tradePassword {
    @weakify(self);
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.textField.text];
    [[[MSAppDelegate getServiceManager] redeemCurrentWithID:self.currentDetail.baseInfo.currentID amount:amount password:[NSString desWithKey:tradePassword key:nil]] subscribeNext:^(CurrentRedeemNotice *notice) {
        @strongify(self);
        [self ms_payViewDidCancel];
        MSCurrentResultController *vc = [[MSCurrentResultController alloc] init];
        [vc updateWithTimes:@[@(notice.redeemApplyDate), @(notice.earningsToBeReceiveDate)] mode:MSCurrentResultModeRedeem];
        [self.navigationController pushViewController:vc animated:YES];
        [self.navigationController removeViewcontrollerAtIndex:self.navigationController.viewControllers.count - 2];
    } error:^(NSError *error) {
        @strongify(self);
        [self ms_payViewDidCancel];
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
    } completed:^{
        
    }];
}

- (void)queryCurrentRedeemConfig {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryCurrentRedeemConfig:self.currentDetail.baseInfo.currentID] subscribeNext:^(CurrentRedeemConfig *redeemConfig) {
        @strongify(self);
        self.redeemConfig = redeemConfig;
        [self updateUI];
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
    } completed:^{
        
    }];
}
@end
