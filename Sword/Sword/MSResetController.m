//
//  MSGetResetCode.m
//  Sword
//
//  Created by lee on 16/6/7.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSResetController.h"
#import "MSTextUtils.h"
#import "MSAppDelegate.h"
#import "MSDoResetController.h"
#import "MSToast.h"
#import "MSItemView.h"
#import "UIColor+StringColor.h"
#import "MSTemporaryCache.h"
#import "MSCommonButton.h"

@interface MSResetController()<MSItemViewDelegate>

@property (copy, nonatomic) NSString *tempPhonenumber;
@property (nonatomic, strong) MSItemView *phoneNumber;
@property (nonatomic, strong) MSCommonButton *completeButton;

@end

@implementation MSResetController

#pragma mark - lifecycle

- (void)viewDidLoad {

    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:130 control:36 params:nil];
    [super viewDidLoad];
    [self prepareUI];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc{
    [MSTemporaryCache clearTemporaryResetLoginPasswordInfo];
    NSLog(@"%s",__func__);
}

#pragma mark - UI
- (void)prepareUI {

    self.navigationItem.title = NSLocalizedString(@"str_title_reset", @"");
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownResignKeyboard)]];
    
    MSItemView *phoneNumber = [[MSItemView alloc] init];
    phoneNumber.backgroundColor = [UIColor whiteColor];
    [phoneNumber itemViewIcon:@"phone" placeholder:NSLocalizedString(@"hint_input_reset_phonenumber", @"")];
    phoneNumber.rightButton.hidden = YES;
    phoneNumber.delegate = self;
    self.phoneNumber = phoneNumber;
    self.phoneNumber.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.phoneNumber];
    [self.phoneNumber setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[text]-0-|" options:0 metrics:nil views:@{@"text":self.phoneNumber}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[text(64)]" options:0 metrics:nil views:@{@"text":self.phoneNumber}]];
    
    self.completeButton = [MSCommonButton buttonWithType:UIButtonTypeCustom];
    [self.completeButton setTitle:NSLocalizedString(@"str_reset_next", @"") forState:UIControlStateNormal];
    self.completeButton.enabled = NO;
    [self.view addSubview:self.completeButton];
    [self.completeButton addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.completeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[text]-16-[button(64)]" options:0 metrics:nil views:@{@"text":self.phoneNumber,@"button":self.completeButton}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[button]-16-|" options:0 metrics:nil views:@{@"button":self.completeButton}]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

#pragma mark - action

- (void)getVerifyCode {
 
    [self eventWithName:@"下一步" elementId:63];
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:130 control:40 params:nil];
    self.completeButton.enabled = NO;
    
    if ([self.phoneNumber.textField phoneNumberFormateError]) {
        self.completeButton.enabled = YES;
        return;
    }
    
    NSMutableDictionary *dict = [MSTemporaryCache getTemporaryResetLoginPasswordInfo];
    if (!dict) {
        [self getVerifyCode:self.phoneNumber.textField.text aim:AIM_RESET_LOGIN_PASSWORD];
    }else{
        
        NSString *temporaryPhoneNumber = dict[@"temporaryPhoneNumber"];
        if (![temporaryPhoneNumber isEqualToString:self.phoneNumber.textField.text]) {
            [MSTemporaryCache clearTemporaryResetLoginPasswordInfo];
            [self getVerifyCode:self.phoneNumber.textField.text aim:AIM_RESET_LOGIN_PASSWORD];
        }else{
            int count = [dict[@"count"] intValue];
            NSDate *date = dict[@"date"];
            int interval = (int)ceil([[NSDate date] timeIntervalSinceDate:date]);
            int val = count - interval;
            if (val > 0) {
                self.completeButton.enabled = YES;
                [self performResetController];
            }else{
                [MSTemporaryCache clearTemporaryResetLoginPasswordInfo];
                [self getVerifyCode:self.phoneNumber.textField.text aim:AIM_RESET_LOGIN_PASSWORD];
            }
        }
    }
}

- (void)touchDownResignKeyboard {
    [self.view endEditing:YES];
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - itemView delegate

- (void)itemViewTextFieldValueChanged:(MSTextField *)textField {

    if ([MSTextUtils isEmpty:self.phoneNumber.textField.text]) {
        self.completeButton.enabled = NO;
        self.phoneNumber.rightButton.hidden = YES;
    } else {
        self.completeButton.enabled = YES;
        self.phoneNumber.rightButton.hidden = NO;
    }
}

- (void)itemViewRightButtonClick:(UIButton *)button {

    self.phoneNumber.textField.text = nil;
    self.completeButton.enabled = NO;
}

#pragma mark - private
- (void)getVerifyCode:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryVerifyCodeByPhoneNumber:phoneNumber aim:aim] subscribeError:^(NSError *error) {
        @strongify(self);
        self.completeButton.enabled = YES;
        RACError *result = (RACError *)error;
        if (![MSTextUtils isEmpty:result.message]) {
            [MSToast show:result.message];
        } else {
            [MSToast show:NSLocalizedString(@"hint_alert_getverifycode_error", @"")];
        }
    } completed:^{
        @strongify(self);
        self.completeButton.enabled = YES;
        [MSToast show:NSLocalizedString(@"hint_verifycode_succeed", @"")];
        [self performResetController];
    }];
}

- (void)performResetController {
    MSDoResetController *doResetVC = [[MSDoResetController alloc] init];
    doResetVC.phoneNumber = self.phoneNumber.textField.text;
    [self.navigationController pushViewController:doResetVC animated:YES];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 130;
    params.title = @"找回密码";
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 130;
    params.title = @"找回密码";
    [MJSStatistics sendPageParams:params];
    
}

@end
