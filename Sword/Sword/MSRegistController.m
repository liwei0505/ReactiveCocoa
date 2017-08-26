//
//  MSMSRegistController.m
//  Sword
//
//  Created by lee on 16/5/9.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRegistController.h"
#import "MSLog.h"
#import "MSAppDelegate.h"
#import "NSString+Ext.h"
#import "MJSNotifications.h"
#import "RACError.h"
#import "MSTextUtils.h"
#import "MSToast.h"
#import "MSWebViewController.h"
#import "MSUrlManager.h"
#import "MSTextField.h"
#import "MSConfig.h"
#import "MSCountDownView.h"
#import "NSMutableDictionary+nilObject.h"
#import "MSTemporaryCache.h"

@interface MSRegistController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MSTextField *phoneNum;
@property (weak, nonatomic) IBOutlet MSTextField *verifyCode;
@property (weak, nonatomic) IBOutlet MSTextField *passWord;
@property (weak, nonatomic) IBOutlet MSTextField *checkPassWord;
@property (weak, nonatomic) IBOutlet MSCountDownView *countDownView;
@property (weak, nonatomic) IBOutlet UIButton *registButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPhone;
@property (weak, nonatomic) IBOutlet UIButton *clearPassWord;
@property (weak, nonatomic) IBOutlet UIButton *hidePassword;
@property (weak, nonatomic) IBOutlet UIButton *hideCheckPassword;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *clearCheckPassWord;
@property (weak, nonatomic) IBOutlet UIButton *terms;
@property (weak, nonatomic) IBOutlet UIButton *privacy;
@property (weak, nonatomic) IBOutlet UILabel *agree;
@property (weak, nonatomic) IBOutlet UILabel *and;
@property (weak, nonatomic) IBOutlet UIButton *login;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHeight;

@end

@implementation MSRegistController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self getTemporaryRegisterInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self saveTemporaryRegisterInfo];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self.countDownView invalidate];
}

#pragma mark - UI
- (void)getTemporaryRegisterInfo {
    
    NSMutableDictionary *dict = [MSTemporaryCache getTemporaryRegisterInfo];
    if (dict) {
    
        int count = [dict[@"count"] intValue];
        NSDate *date = dict[@"date"];
        int interval = (int)ceil([[NSDate date] timeIntervalSinceDate:date]);
        int val = count - interval;
        MSCountDownViewMode mode = val > 0 ? MSCountDownViewModeCountDown : MSCountDownViewModeNormal;
        [self.countDownView startCountdownWithMode:mode temporaryCount:val];
        if (val > 0) {
            self.phoneNum.text = dict[@"accountName"];
            self.verifyCode.text = dict[@"code"];
            self.passWord.text = dict[@"password"];
            self.checkPassWord.text = dict[@"checkPassWord"];
            
        }else{
            [MSTemporaryCache clearTemporaryRegisterInfo];
        }
        
        self.registButton.enabled = ![self checkRegistButtonByAgree];
    }
}

- (void)saveTemporaryRegisterInfo {
    if (self.countDownView.currentMode == MSCountDownViewModeCountDown) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setNoNilObject:self.phoneNum.text forKey:@"accountName"];
        [dict setNoNilObject:self.verifyCode.text forKey:@"code"];
        [dict setNoNilObject:self.passWord.text forKey:@"password"];
        [dict setNoNilObject:self.checkPassWord.text forKey:@"checkPassWord"];
        [dict setNoNilObject:[NSDate date] forKey:@"date"];
        [dict setNoNilObject:@(self.countDownView.count) forKey:@"count"];
        [MSTemporaryCache saveTemporaryRegisterInfo:dict];
    }
}

- (void)prepareUI {
    
    self.scrollHeight.constant = self.view.bounds.size.height;
    self.navigationItem.title = NSLocalizedString(@"str_regist", @"");
    self.phoneNum.placeholder = NSLocalizedString(@"hint_input_regist_phonenumber", @"");
    self.verifyCode.placeholder = NSLocalizedString(@"hint_input_verifycode", @"");
    self.passWord.placeholder = NSLocalizedString(@"hint_input_regist_password", @"");
    self.checkPassWord.placeholder = NSLocalizedString(@"hint_input_regist_repassword", @"");
    [self.registButton setTitle:NSLocalizedString(@"str_regist_now", @"") forState:UIControlStateNormal];
    [self.terms setTitle:NSLocalizedString(@"str_title_terms", @"") forState:UIControlStateNormal];
    [self.privacy setTitle:NSLocalizedString(@"str_title_privacy", @"") forState:UIControlStateNormal];
    
    NSString *string = @"已有账户？立即登录";
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(string.length-4, 4)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1/1.0] range:NSMakeRange(0, string.length-4)];
    [self.login setAttributedTitle:attributeString forState:UIControlStateNormal];
    [self.login addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.agree.text = NSLocalizedString(@"str_regist_agree", @"");
    self.and.text = NSLocalizedString(@"str_regist_and", @"");
    self.passWord.delegate = self;
    self.phoneNum.delegate = self;
    self.registButton.enabled = NO;
    self.clearPhone.hidden = YES;
    self.clearPassWord.hidden = YES;
    self.clearCheckPassWord.hidden = YES;
    self.agreeButton.selected = PROTOCOL_AUTO_SELECTED;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    self.navigationItem.leftBarButtonItem = backItem;
    [self.phoneNum addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passWord addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.checkPassWord addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.verifyCode addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    @weakify(self);
    self.countDownView.willBeginCountdown = ^{
        @strongify(self);
        NSString *name = @"获取验证码";
        int eventId = 59;
        if ([self.phoneNum phoneNumberFormateError]) {
            [self eventWithName:name elementId:eventId message:NSLocalizedString(@"hint_alert_phonenumber_error", @"")];
            self.countDownView.currentMode = MSCountDownViewModeNormal;
            return;
        }
        [self eventWithName:name elementId:eventId message:nil];
        [self getVerifyCode:self.phoneNum.text passWord:self.passWord.text aim:AIM_REGISTER];
    };

}

- (void)textFieldDidChange:(UITextField *)textField {
    
    NSUInteger length = textField.text.length;
    self.registButton.enabled = length ? ![self checkRegistButtonByAgree] : NO;
    switch (textField.tag) {
        case 0: {
            self.clearPhone.hidden = !length;
        }
            break;
        case 2: {
            self.clearPassWord.hidden = !length;
        }
            break;
        case 3: {
            self.clearCheckPassWord.hidden = !length;
        }
            break;
        default:
            break;
    }    
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - IBAction
- (IBAction)onRegistButtonPress:(UIButton *)sender {
    
    NSString *name = @"立即注册";
    int eventId = 62;
    if ([self.phoneNum phoneNumberFormateError]) {
        [self eventWithName:name elementId:eventId message:NSLocalizedString(@"hint_alert_phonenumber_error", @"")];
        return;
    }
    
    if ([self.verifyCode verifyCodeFormateError]) {
        [self eventWithName:name elementId:eventId message:NSLocalizedString(@"hint_input_correct_verifycode", @"")];
        return;
    }
    
    if ([self.passWord spacingCheckout]) {
        [self eventWithName:name elementId:eventId message:NSLocalizedString(@"hint_password_has_spacing", @"")];
        return;
    }
    
    if ([self.passWord passwordFormateError]) {
        [self eventWithName:name elementId:eventId message:NSLocalizedString(@"hint_alert_password_error", @"")];
        return;
    }
    
    if (![self.passWord.text isEqualToString:self.checkPassWord.text]) {
        NSString *hint = NSLocalizedString(@"hint_alert_password_diff", @"");
        [self eventWithName:name elementId:eventId message:hint];
        [MSToast show:NSLocalizedString(@"hint_alert_password_diff", @"")];
        return;
    }
    if (self.agreeButton.selected == NO) {
        NSString *hint = NSLocalizedString(@"hint_alert_regist_agree", @"");
        [self eventWithName:name elementId:eventId message:hint];
        [MSToast show:NSLocalizedString(@"hint_alert_regist_agree", @"")];
        return;
    }
    
    [self eventWithName:name elementId:eventId message:nil];
    [self.registButton setEnabled:NO];
    [self regist:self.phoneNum.text password:self.passWord.text veryfyCode:self.verifyCode.text];
    
}

- (IBAction)showRegistTerms:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0: {
            //隐私条款
            [self eventWithName:@"隐私规则" elementId:61 message:nil];
            MSWebViewController *webView = [MSWebViewController load];
            webView.title = NSLocalizedString(@"str_title_privacy", @"");
            webView.url = [MSUrlManager getRegistPrivacyTerms];
            webView.pageId = 134;
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 1: {
            //使用条款
            [self eventWithName:@"服务协议" elementId:60 message:nil];
            MSWebViewController *webView = [MSWebViewController load];
            webView.title = NSLocalizedString(@"str_title_terms", @"");
            webView.url = [MSUrlManager getRegistUseTerms];
            webView.pageId = 133;
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)changeToLogin:(id)sender {
    [self backButtonClick];
}

- (IBAction)deletePhoneNumber:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0: {
            self.phoneNum.text = nil;
            self.clearPhone.hidden = YES;
        }
            break;
        case 1: {
            self.verifyCode.text = nil;
        }
            break;
        case 2: {
            self.passWord.text = nil;
            self.clearPassWord.hidden = YES;
        }
            break;
        case 3: {
            self.checkPassWord.text = nil;
            self.clearCheckPassWord.hidden = YES;
        }
            break;
        default:
            break;
    }
    self.registButton.enabled = NO;
    
}

- (IBAction)showPassword:(UIButton *)sender {

    sender.selected = !sender.selected;
    switch (sender.tag) {
        case 0: {
            self.checkPassWord.enabled = NO;
            self.checkPassWord.secureTextEntry = !self.checkPassWord.secureTextEntry;
            self.checkPassWord.enabled = YES;
        }
            break;
        case 1: {
            self.passWord.enabled = NO;
            self.passWord.secureTextEntry = !self.passWord.secureTextEntry;
            self.passWord.enabled = YES;
        }
            break;
        default:
            break;
    }
}

- (IBAction)chooseAgree:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.registButton.enabled = ![self checkRegistButtonByAgree];
}

#pragma mark - private
- (void)getVerifyCode:(NSString *)phoneNumber passWord:(NSString *)password aim:(GetVerifyCodeAim)aim{
    @weakify(self);
   [[[MSAppDelegate getServiceManager] queryVerifyCodeByPhoneNumber:phoneNumber aim:aim] subscribeError:^(NSError *error) {
       RACError *result = (RACError *)error;
       @strongify(self);
       if (![MSTextUtils isEmpty:result.message]) {
           [MSToast show:result.message];
       } else {
           [MSToast show:NSLocalizedString(@"hint_alert_getverifycode_error", @"")];
       }
       self.countDownView.currentMode = MSCountDownViewModeNormal;
   } completed:^{
       @strongify(self);
       [MSToast show:NSLocalizedString(@"hint_verifycode_succeed", @"")];
       self.countDownView.currentMode = MSCountDownViewModeCountDown;
   }];
}

- (void)regist:(NSString *)username password:(NSString *)password veryfyCode:(NSString *)code{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] registerWithPhoneNumber:username password:password verifyCode:code] subscribeError:^(NSError *error) {
        RACError *result = (RACError *)error;
        if (![MSTextUtils isEmpty:result.message]) {
            [MSToast show:result.message];
        } else {
            [MSToast show:NSLocalizedString(@"hint_regist_error", @"")];
        }
        self.registButton.enabled = YES;
    } completed:^{
        @strongify(self);
        [MSTemporaryCache clearTemporaryRegisterInfo];
        [MSToast show:NSLocalizedString(@"hint_regist_succeed", @"")];
        self.registButton.enabled = YES;
        if (self.registerSuccess) {
            self.registerSuccess(username,password);
        }
    }];
}

- (BOOL)checkRegistButtonByAgree {
    return  [MSTextUtils isEmpty:self.phoneNum.text] || [MSTextUtils isEmpty:self.verifyCode.text] || [MSTextUtils isEmpty:self.passWord.text] || [MSTextUtils isEmpty:self.checkPassWord.text] || !self.agreeButton.selected;
}

- (void)eventWithName:(NSString *)name elementId:(int)eId message:(NSString *)message {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 132;
    params.title = @"注册";
    params.elementId = eId;
    params.elementText = name;
    if (![message isEqualToString:@""] && message) {
        NSDictionary *dic = @{@"error_msg":message};
        params.params = dic;
    }
    [MJSStatistics sendEventParams:params];
    
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 132;
    params.title = @"注册";
    [MJSStatistics sendPageParams:params];
    
}

@end
