//
//  MSDoResetController.m
//  Sword
//
//  Created by lee on 16/6/12.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSDoResetController.h"
#import "MSTextUtils.h"
#import "MSItemView.h"
#import "UILabel+Custom.h"
#import "RACError.h"
#import "MSCountDownView.h"
#import "MSVerifyCodeTextField.h"
#import "MSCheckInfoUtils.h"
#import "NSString+Ext.h"
#import "NSMutableDictionary+nilObject.h"
#import "MSTemporaryCache.h"
#import "MSCommonButton.h"

typedef NS_ENUM(NSInteger, ItemControlTag) {

    ITEM_ONE = 1,
    ITEM_TWO = 2,
    ITEM_THREE = 3,
    ITEM_FOUR = 4,
    
};

@interface MSDoResetController()<UITextFieldDelegate,MSItemViewDelegate>

@property (strong, nonatomic) MSVerifyCodeTextField *verifyCodeTextField;
@property (strong, nonatomic) MSCountDownView *countDownView;
@property (nonatomic, strong) MSItemView *midView;
@property (nonatomic, strong) MSItemView *bottomView;
@property (nonatomic, strong) UIButton *completeButton;

@end

@implementation MSDoResetController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [MSNotificationHelper addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:self.verifyCodeTextField];
    [self prepareUI];
    [self getTemporaryResetLoginPasswordInfo];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [self saveTemporaryResetLoginPasswordInfo];
}

- (void)dealloc {
    [self.countDownView invalidate];
    [MSNotificationHelper removeObserver:self];
    NSLog(@"%s",__func__);
}

#pragma mark - UI
- (void)getTemporaryResetLoginPasswordInfo {
    NSMutableDictionary *dict = [MSTemporaryCache getTemporaryResetLoginPasswordInfo];
    if (dict) {
        
        int count = [dict[@"count"] intValue];
        NSDate *date = dict[@"date"];
        int interval = (int)ceil([[NSDate date] timeIntervalSinceDate:date]);
        int val = count - interval;
        MSCountDownViewMode mode = val > 0 ? MSCountDownViewModeCountDown : MSCountDownViewModeNormal;
        if (mode == MSCountDownViewModeCountDown) {
            [self.countDownView invalidate];
        }
        [self.countDownView startCountdownWithMode:mode temporaryCount:val];
        if (val > 0) {
            self.midView.textField.text = dict[@"password"];
            self.bottomView.textField.text = dict[@"checkPassword"];
            self.verifyCodeTextField.text = dict[@"code"];
        } else {
            [MSTemporaryCache clearTemporaryResetLoginPasswordInfo];
        }
        self.completeButton.enabled = ![self textFieldEmptyCheckout];
    }
}

- (void)saveTemporaryResetLoginPasswordInfo {
    
    if (self.countDownView.currentMode == MSCountDownViewModeCountDown) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setNoNilObject:self.verifyCodeTextField.text forKey:@"code"];
        [dict setNoNilObject:self.midView.textField.text forKey:@"password"];
        [dict setNoNilObject:self.bottomView.textField.text forKey:@"checkPassword"];
        [dict setNoNilObject:[NSDate date] forKey:@"date"];
        [dict setNoNilObject:@(self.countDownView.count) forKey:@"count"];
        [dict setNoNilObject:self.phoneNumber forKey:@"temporaryPhoneNumber"];
        [MSTemporaryCache saveTemporaryResetLoginPasswordInfo:dict];
    }
}

- (void)prepareUI {
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownResignKeyboard)]];
    self.navigationItem.title = NSLocalizedString(@"str_title_reset_check", @"");
    UILabel *titleLabel = [UILabel labelWithText:NSLocalizedString(@"hint_input_reset_title", @"") textSize:14.0 textColor:@"#323232"];
    [self.view addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:15]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10]];

    CGFloat width = self.view.bounds.size.width - 20;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 45, width, 150)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    
    self.verifyCodeTextField = [[MSVerifyCodeTextField alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    self.verifyCodeTextField.font = [UIFont systemFontOfSize:14];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"请输入短信验证码" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"CFCFCF"]}];
    self.verifyCodeTextField.attributedPlaceholder = attStr;
    self.verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    leftView.image = [UIImage imageNamed:@"czmm_07"];
    self.verifyCodeTextField.leftView = leftView;
    self.verifyCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.countDownView = [[MSCountDownView alloc] initWithFrame:CGRectMake(0, 0, 90, 36)];
    self.countDownView.currentMode = MSCountDownViewModeCountDown;
    @weakify(self);
    self.countDownView.willBeginCountdown = ^{
        @strongify(self);
        [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:130 control:41 params:nil];
        [self eventWithName:@"获取验证码" elementId:64];
        [self getVerifyCode:self.phoneNumber aim:AIM_RESET_LOGIN_PASSWORD];
    };
    self.verifyCodeTextField.rightView = self.countDownView;
    self.verifyCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    [contentView addSubview:self.verifyCodeTextField];
    
    UIView *lineOne = [[UIView alloc] initWithFrame:CGRectMake(10, 50, width - 20, 0.5)];
    lineOne.backgroundColor = [UIColor ms_colorWithHexString:@"#DCDCDC"];
    [contentView addSubview:lineOne];
    
    
    MSItemView *midView = [[MSItemView alloc] initWithFrame:CGRectMake(0, 51, width, 49)];
    [midView itemsViewIcon:@"lock" placeholder:NSLocalizedString(@"hint_input_regist_password", @"")];
    midView.delegate = self;
    midView.leftButton.hidden = YES;
    midView.textField.secureTextEntry = YES;
    midView.textField.tag = ITEM_TWO;
    midView.rightButton.tag = ITEM_TWO;
    midView.leftButton.tag = ITEM_TWO;
    self.midView = midView;
    [contentView addSubview:midView];
    
    UIView *lineOther = [[UIView alloc] initWithFrame:CGRectMake(10, 99, width - 20, 0.5)];
    lineOther.backgroundColor = [UIColor ms_colorWithHexString:@"#DCDCDC"];
    [contentView addSubview:lineOther];
    
    MSItemView *bottomView = [[MSItemView alloc] initWithFrame:CGRectMake(0, 100, width, 50)];
    [bottomView itemsViewIcon:@"lock" placeholder:NSLocalizedString(@"hint_input_reset_newpassword", @"")];
    bottomView.delegate = self;
    bottomView.leftButton.hidden = YES;
    bottomView.textField.secureTextEntry = YES;
    bottomView.textField.tag = ITEM_THREE;
    bottomView.rightButton.tag = ITEM_THREE;
    bottomView.leftButton.tag = ITEM_THREE;
    self.bottomView = bottomView;
    [contentView addSubview:bottomView];
    
    self.completeButton = [MSCommonButton buttonWithType:UIButtonTypeCustom];
    [self.completeButton setTitle:NSLocalizedString(@"str_complete", @"") forState:UIControlStateNormal];
    [self.view addSubview:self.completeButton];
    self.completeButton.enabled = NO;
    [self.completeButton addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.completeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[button]-16-|" options:0 metrics:nil views:@{@"button":self.completeButton}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[content]-25-[button(64)]" options:0 metrics:nil views:@{@"content":contentView,@"button":self.completeButton}]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

#pragma mark - action

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetPassword {
    
    [self eventWithName:@"完成" elementId:65];
    
    if ([MSCheckInfoUtils checkCode:self.verifyCodeTextField.text]) {
        return;
    }
    if ([self.midView.textField spacingCheckout]) {
        return;
    }
    if ([self.midView.textField passwordFormateError]) {
        return;
    }
    if (![self.midView.textField.text isEqualToString:self.bottomView.textField.text]) {
        [MSToast show:NSLocalizedString(@"hint_alert_password_diff", @"")];
        return;
    }
    
    [self reset:self.phoneNumber password:self.midView.textField.text veryfyCode:self.verifyCodeTextField.text];
    
}

- (void)touchDownResignKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - itemView delegete

- (void)itemViewTextFieldValueChanged:(MSTextField *)textField {

    switch (textField.tag) {
        case ITEM_ONE: {
        }
            break;
        case ITEM_TWO: {
            if (textField.text.length) {
                self.midView.leftButton.hidden = NO;
                self.completeButton.enabled = ![self textFieldEmptyCheckout];
            } else {
                self.midView.leftButton.hidden = YES;
                self.completeButton.enabled = NO;
            }
        }
            break;
        case ITEM_THREE: {
            if (textField.text.length) {
                self.bottomView.leftButton.hidden = NO;
                self.completeButton.enabled = ![self textFieldEmptyCheckout];
            } else {
                self.bottomView.leftButton.hidden = YES;
                self.completeButton.enabled = NO;
            }
        }
            break;
        default:
            break;
    }
}

- (void)itemViewLeftButtonClick:(UIButton *)button {

    switch (button.tag) {
        case ITEM_TWO: {
            self.midView.textField.text = nil;
            self.midView.leftButton.hidden = YES;
        }
            break;
        case ITEM_THREE: {
            self.bottomView.textField.text = nil;
            self.bottomView.leftButton.hidden = YES;
        }
        default:
            break;
    }
    self.completeButton.enabled = NO;
    
}

- (void)itemViewRightButtonClick:(UIButton *)button {

    switch (button.tag) {
        case ITEM_ONE: {
        }
            break;
        case ITEM_TWO: {
            button.selected = !button.selected;
            self.midView.textField.enabled = NO;
            self.midView.textField.secureTextEntry = !self.midView.textField.secureTextEntry;
            self.midView.textField.enabled = YES;
        }
            break;
        case ITEM_THREE: {
            button.selected = !button.selected;
            self.bottomView.textField.enabled = NO;
            self.bottomView.textField.secureTextEntry = !self.bottomView.textField.secureTextEntry;
            self.bottomView.textField.enabled = YES;
        }
            break;
        default:
            break;
    }

}

#pragma mark - notification
- (void)textChange{
    self.completeButton.enabled = ![self textFieldEmptyCheckout];
}

#pragma mark - private
- (void)getVerifyCode:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryVerifyCodeByPhoneNumber:phoneNumber aim:aim] subscribeError:^(NSError *error) {
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

- (void)reset:(NSString *)username password:(NSString *)password veryfyCode:(NSString *)code {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] resetLoginPasswordWithPhoneNumber:username password:[NSString desWithKey:password key:nil] verifyCode:code] subscribeError:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
    } completed:^{
        @strongify(self);
        self.countDownView.currentMode = MSCountDownViewModeNormal;
        [MSTemporaryCache clearTemporaryResetLoginPasswordInfo];
        [MSToast show:NSLocalizedString(@"hint_reset_succeed", @"")];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (BOOL)textFieldEmptyCheckout {
    
    return [self.verifyCodeTextField.text isEqualToString:@""] || [self.midView.textField.text isEqualToString:@""] || [self.bottomView.textField.text isEqualToString:@""];
    
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 131;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
    
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 131;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
    
}

@end
