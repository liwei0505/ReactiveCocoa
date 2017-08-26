//
//  MSResetTradePasswordA.m
//  Sword
//
//  Created by lee on 16/12/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSResetTradePasswordA.h"
#import "MSItemView.h"
#import "UIColor+StringColor.h"
#import "UIButton+Custom.h"
#import "MSResetTradePasswordB.h"
#import "MSCountDownView.h"
#import "MSCheckInfoUtils.h"
#import "NSMutableDictionary+nilObject.h"
#import "MSTemporaryCache.h"
#import "MSCommonButton.h"

@interface MSResetTradePasswordA ()
{
    RACDisposable *_accountInfoSubscription;
}

@property (strong, nonatomic) UITextField *verifyCodeTextField;
@property (strong, nonatomic) MSCountDownView *countDownView;
@property (strong, nonatomic) MSCommonButton *completeButton;

@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) UILabel *lbPhone;

@end

@implementation MSResetTradePasswordA

- (void)viewDidLoad {
    [super viewDidLoad];
    [MSNotificationHelper addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:self.verifyCodeTextField];
    [self prepareUI];
    @weakify(self);
    _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
        [self getTemporaryResetTradePasswordInfo];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self saveTemporaryResetTradePasswordInfo];
}

- (void)dealloc {
    [MSNotificationHelper removeObserver:self];
    [self.countDownView invalidate];
    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
    NSLog(@"%s",__func__);
}

#pragma mark - UI
- (void)getTemporaryResetTradePasswordInfo {
    NSMutableDictionary *dict = [MSTemporaryCache getTemporaryResetTradePasswordInfo];
    if (dict) {
        int count = [dict[@"count"] intValue];
        NSDate *date = dict[@"date"];
        int interval = (int)ceil([[NSDate date] timeIntervalSinceDate:date]);
        int val = count - interval;
        MSCountDownViewMode mode = val > 0 ? MSCountDownViewModeCountDown : MSCountDownViewModeNormal;
        [self.countDownView startCountdownWithMode:mode temporaryCount:val];
        if (val > 0) {
            self.lbPhone.text = dict[@"phone"];
            self.verifyCodeTextField.text = dict[@"code"];
        } else {
            [MSTemporaryCache clearTemporaryResetTradePasswordInfo];
            self.lbPhone.text = [self getTextWithPhone:self.accountInfo.phoneNumber];
            self.countDownView.currentMode = MSCountDownViewModeIntermediate;
            [self getVerifyCode];
        }
        [self textChange];
    }else {
        self.lbPhone.text = [self getTextWithPhone:self.accountInfo.phoneNumber];
        self.countDownView.currentMode = MSCountDownViewModeIntermediate;
        [self getVerifyCode];
    }
}

- (void)saveTemporaryResetTradePasswordInfo {
    if (self.countDownView.currentMode == MSCountDownViewModeCountDown) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setNoNilObject:self.lbPhone.text forKey:@"phone"];
        [dict setNoNilObject:self.verifyCodeTextField.text forKey:@"code"];
        [dict setNoNilObject:[NSDate date] forKey:@"date"];
        [dict setNoNilObject:@(self.countDownView.count) forKey:@"count"];
        [MSTemporaryCache saveTemporaryResetTradePasswordInfo:dict];
    }
}

- (void)prepareUI {
    
    self.title = NSLocalizedString(@"str_title_reset_trade_password", @"");
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownResignKeyboard)]];
    float margin = 16;
    float width = self.view.bounds.size.width;
    float itemHeight = 48;
    
    UILabel *lbPhone = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, width-margin, itemHeight)];
    lbPhone.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    lbPhone.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    self.lbPhone = lbPhone;
    [self.view addSubview:self.lbPhone];
    
    self.verifyCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbPhone.frame), width, itemHeight)];
    self.verifyCodeTextField.backgroundColor = [UIColor whiteColor];
    self.verifyCodeTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"请输入短信验证码" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"CFCFCF"]}];
    self.verifyCodeTextField.attributedPlaceholder = attStr;
    self.verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, margin, itemHeight)];
    self.verifyCodeTextField.leftView = leftView;
    self.verifyCodeTextField.leftViewMode = UITextFieldViewModeAlways;

    self.countDownView = [[MSCountDownView alloc] initWithFrame:CGRectMake(0, 0, 90, 36)];
    @weakify(self);
    self.countDownView.willBeginCountdown = ^{
        @strongify(self);
        [self getVerifyCode];
    };
    self.verifyCodeTextField.rightView = self.countDownView;
    self.verifyCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.verifyCodeTextField];
    
    self.completeButton = [MSCommonButton buttonWithType:UIButtonTypeCustom];
    [self.completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.completeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.completeButton setTitle:NSLocalizedString(@"str_reset_next", @"") forState:UIControlStateNormal];
    self.completeButton.frame = CGRectMake(margin, CGRectGetMaxY(self.verifyCodeTextField.frame)+margin, width-2*margin, 64);
    [self.completeButton addTarget:self action:@selector(completeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.completeButton setEnabled:NO];
    [self.view addSubview:self.completeButton];
    
//    float btnW = 200;
//    UIButton *btnGetCode = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnGetCode.frame = CGRectMake((width-btnW)*0.5, CGRectGetMaxY(self.completeButton.frame)+margin, btnW, 20);
//    btnGetCode.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:12];
//    [btnGetCode setTitleColor:[UIColor ms_colorWithHexString:@"F3091C"] forState:UIControlStateNormal];
//    [btnGetCode setTitle:@"收不到验证码？" forState:UIControlStateNormal];
//    [btnGetCode addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btnGetCode];
    
}

#pragma mark - action
- (void)completeButtonClick {
    
    if ([MSCheckInfoUtils checkCode:self.verifyCodeTextField.text]) {
        return;
    }
    [self.completeButton setEnabled:NO];
    [self resetTradePasswordVerifyCode:self.verifyCodeTextField.text];
    
}

- (void)touchDownResignKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - notification
- (void)textChange {
    self.completeButton.enabled = (self.verifyCodeTextField.text.length > 0) ? YES : NO;
}

#pragma mark - private
- (void)getVerifyCode {
    NSString *phone = self.accountInfo.phoneNumber;
    if (![MSCheckInfoUtils phoneNumCheckout:phone]) {
        [MSToast show:@"获取手机号出错，请退出重新获取"];
        self.countDownView.currentMode = MSCountDownViewModeNormal;
        return;
    }
    
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryVerifyCodeByPhoneNumber:phone aim:AIM_RESET_TRADE_PASSWORD] subscribeError:^(NSError *error) {
        @strongify(self);
        self.countDownView.currentMode = MSCountDownViewModeNormal;
        RACError *result = (RACError *)error;
        if (result.message) {
            [MSToast show:result.message];
        } else {
            [MSToast show:NSLocalizedString(@"hint_alert_getverifycode_error", @"")];
        }
    } completed:^{
        @strongify(self);
        self.countDownView.currentMode = MSCountDownViewModeCountDown;
        [MSToast show:NSLocalizedString(@"hint_verifycode_succeed", @"")];
    }];
}

- (void)resetTradePasswordVerifyCode:(NSString *)code {
    NSString *phone = self.accountInfo.phoneNumber;
    @weakify(self);
    [[[MSAppDelegate getServiceManager] verifyPayBoundPhoneNumber:phone verifyCode:code] subscribeNext:^(id x) {
        @strongify(self);
        [self.completeButton setEnabled:YES];
        MSResetTradePasswordB *reset = [[MSResetTradePasswordB alloc] init];
        reset.backBlock = ^{
            @strongify(self);
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [self popSelf];
        };
        [self.navigationController pushViewController:reset animated:YES];
        self.countDownView.currentMode = MSCountDownViewModeNormal;
        [MSTemporaryCache clearTemporaryResetTradePasswordInfo];
    } error:^(NSError *error) {
        @strongify(self);
        [self.completeButton setEnabled:YES];
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
    } completed:^{
    }];
}

- (void)popSelf {

    __block NSUInteger index;
    [self.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == self) {
            index = idx;
        }
    }];
    [self.navigationController popToViewController:self.navigationController.childViewControllers[index-1] animated:YES];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 151;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
    
}

- (NSString *)getTextWithPhone:(NSString *)number {
    number = [number stringByReplacingCharactersInRange:NSMakeRange(3, 6) withString:@"******"];
    return [NSString stringWithFormat:@"已将验证码发送至号码%@",number];
}

@end
