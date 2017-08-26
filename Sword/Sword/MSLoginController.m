//
//  MSLoginController.m
//  Sword
//
//  Created by lee on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSLoginController.h"
#import "MSAppDelegate.h"
#import "NSString+Ext.h"
#import "MSRegistController.h"
#import "MJSNotifications.h"
#import "RACError.h"
#import "MSMainController.h"
#import "MSAccountController.h"
#import "MSToast.h"
#import "MSSettings.h"
#import "MSPatternSetController.h"
#import "MSTextUtils.h"
#import "MSTextField.h"
#import "MSResetController.h"
#import "MSRiskResultViewController.h"
#import "MSRiskHomeViewController.h"
#import "MSRegistController.h"
#import "MSStoryboardLoader.h"
#import "MSTemporaryCache.h"

@interface MSLoginController ()<UINavigationBarDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MSTextField *userName;
@property (weak, nonatomic) IBOutlet MSTextField *passWord;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPhone;
@property (weak, nonatomic) IBOutlet UIButton *clearPassWord;
@property (weak, nonatomic) IBOutlet UIButton *registNow;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHeight;

@end

@implementation MSLoginController

#pragma mark - lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"str_login", @"");
    [self prepareUI];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    if (self.loginType == TYPE_PATTERN_FORGET) {
        [self.navigationItem setHidesBackButton:YES];
        self.navigationItem.leftBarButtonItem = nil;
    } else {
        self.backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonOnClick)];
        self.navigationItem.leftBarButtonItem = self.backItem;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [MSTemporaryCache clearTemporaryRegisterInfo];
}

#pragma mark - UI
- (void)prepareUI {

    self.scrollHeight.constant = self.view.bounds.size.height;
    self.loginButton.enabled = NO;
    self.clearPhone.hidden = YES;
    self.clearPassWord.hidden = YES;
    self.userName.placeholder = NSLocalizedString(@"hint_input_login_phonenumber", @"");
    self.passWord.placeholder = NSLocalizedString(@"hint_input_login_password", @"");
    [self.registNow setTitle:NSLocalizedString(@"str_regist_now", @"") forState:UIControlStateNormal];
    [self.forgotPassword setTitle:NSLocalizedString(@"str_forgot_password", @"") forState:UIControlStateNormal];
    
    if (!self.loginType || self.loginType == TYPE_ACCOUNT || self.loginType == TYPE_RISK) {
        MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
        self.userName.text = config.phoneNumber;
    }
    
    @weakify(self);
    RACSignal *usernameSignal = [self.userName.rac_textSignal map:^id(NSString *value) {
        BOOL username = [MSTextUtils isEmpty:value];
        @strongify(self);
        self.clearPhone.hidden = username;
        return @(!username);
    }];
    
    RACSignal *passwordSignal = [self.passWord.rac_textSignal map:^id(NSString *value) {
        BOOL password = [MSTextUtils isEmpty:value];
        @strongify(self);
        self.clearPassWord.hidden = password;
        return @(!password);
    }];
    
    RACSignal *loginSignal = [RACSignal combineLatest:@[usernameSignal, passwordSignal] reduce:^id(NSNumber *username, NSNumber *password){
        return @([username boolValue] && [password boolValue]);
    }];
    [loginSignal subscribeNext:^(id x) {
        @strongify(self);
        self.loginButton.enabled = [x boolValue];
    }];
    
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:129 control:34 params:nil];
        
        if ([self.passWord passwordLengthError]) {
            return;
        }
        [self.loginButton setEnabled:NO];
        [self login:self.userName.text passWord:self.passWord.text];
    }];
    
    [[self.forgotPassword rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self eventWithName:@"忘记密码" elementId:36];
        MSResetController *reset = [[MSResetController alloc] init];
        [self.navigationController pushViewController:reset animated:YES];
    }];
    
    [[self.registNow rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self eventWithName:@"立即注册" elementId:35];
        MSRegistController *registerVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"regist"];
        registerVc.registerSuccess = ^(NSString *accountNumber, NSString *password){
            NSLog(@"%@===%@",accountNumber,password);
            @strongify(self);
            [self login:accountNumber passWord:password];
        };
        [self.navigationController pushViewController:registerVc animated:YES];
        
    }];
    
}

- (void)backButtonOnClick {
    if (self.backButtonBlock) {
        self.backButtonBlock();
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.loginType && self.loginType != TYPE_ACCOUNT && self.loginType != TYPE_RISK) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - IBAction

- (IBAction)deletePhoneNumber:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0: {
            self.userName.text = nil;
            self.clearPhone.hidden = YES;
        }
            break;
        case 1: {
            self.passWord.text = nil;
            self.clearPassWord.hidden = YES;
        }
            break;
        default:
            break;
    }
    self.loginButton.enabled = NO;
    
}

- (IBAction)showPassWord:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.passWord.enabled = NO;
    self.passWord.secureTextEntry = !self.passWord.secureTextEntry;
    self.passWord.enabled = YES;
}

#pragma mark - private
- (void)login:(NSString *)userName passWord:(NSString *)passWord{
    
    @weakify(self);
    [[[MSAppDelegate getServiceManager] loginWithUserName:userName password:[NSString desWithKey:passWord key:nil]] subscribeNext:^(MSLoginInfo *loginInfo) {
        @strongify(self);
        self.loginButton.enabled = YES;
        __weak typeof(self)weakSelf = self;
        //开关打开，手势密码为空
        BOOL showPattern = [MSSettings shouldShowPatternLockSettingView:loginInfo.userId];
        if (showPattern) {
            
            if (self.loginType == TYPE_ACCOUNT) {
                [self pushPatternLockSetCanJump:YES complete:^{
                    [weakSelf setTabbarControllerIndex:2];
                    [weakSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
                }];
                
            } else if (self.loginType == TYPE_RISK) {
                
                [self pushPatternLockSetCanJump:YES complete:^{
                    //jump to risk
                    RiskResultInfo *userRiskInfo = [MSAppDelegate getServiceManager].riskResultInfo;
                    if (userRiskInfo.type == EVALUATE_NOT) {
                        MSRiskHomeViewController *riskHomeViewController = [[MSRiskHomeViewController alloc] init];
                        [weakSelf dismissViewControllerAnimated:NO completion:^{
                            [[[MSAppDelegate getInstance] getNavigationController] pushViewController:riskHomeViewController animated:YES];
                        }];
                    }else{
                        MSRiskResultViewController *resultViewController = [[MSRiskResultViewController alloc] init];
                        resultViewController.resultInfo = userRiskInfo;
                        [weakSelf dismissViewControllerAnimated:NO completion:^{
                            [[[MSAppDelegate getInstance] getNavigationController] pushViewController:resultViewController animated:YES];
                        }];
                    }
                }];
                
            } else if (self.loginType == TYPE_PATTERN_FORGET) {
                
                [self pushPatternLockSetCanJump:YES complete:^{
                    UITabBarController *controller = weakSelf.navigationController.childViewControllers[0];
                    if ([controller isKindOfClass:[MSMainController class]]) {
                        controller.selectedIndex = 0;
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
                
            } else {
                //投资情况是否需要返回账户页
                [self pushPatternLockSetCanJump:YES complete:^{
                    [weakSelf setTabbarControllerIndex:2];
                    [weakSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
                }];
            }
        } else {
        
            if (self.loginType == TYPE_CHANGE_USER) {
                
                [self pushPatternLockSetCanJump:YES complete:^{
                    [self setTabbarControllerIndex:2];
                    [weakSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
                }];
                
            } else if (self.loginType == TYPE_PATTERN_FORGET) {
                //waiting test
                
                [self pushPatternLockSetCanJump:NO complete:^{
                    UITabBarController *controller = weakSelf.navigationController.childViewControllers[0];
                    if ([controller isKindOfClass:[MSMainController class]]) {
                        controller.selectedIndex = 0;
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }

                }];
                
            } else if (self.loginType == TYPE_ACCOUNT) {
                
                [self setTabbarControllerIndex:2];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else if (self.loginType == TYPE_RISK) {
                RiskResultInfo *userRiskInfo = [MSAppDelegate getServiceManager].riskResultInfo;
                if (userRiskInfo.type == EVALUATE_NOT) {
                    MSRiskHomeViewController *riskHomeViewController = [[MSRiskHomeViewController alloc] init];
                    [self dismissViewControllerAnimated:NO completion:^{
                        [[[MSAppDelegate getInstance] getNavigationController] pushViewController:riskHomeViewController animated:YES];
                    }];
                }else{
                    MSRiskResultViewController *resultViewController = [[MSRiskResultViewController alloc] init];
                    resultViewController.resultInfo = userRiskInfo;
                    [self dismissViewControllerAnimated:NO completion:^{
                        [[[MSAppDelegate getInstance] getNavigationController] pushViewController:resultViewController animated:YES];
                    }];
                }
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        RACError *result = (RACError *)error;
         self.loginButton.enabled = YES;
        if (![MSTextUtils isEmpty:result.message]) {
            [MSToast show:result.message];
            [self handleRegistErrorPopRegistController];
        } else {
            //手势密码错误后登陆失败，跳转主页
            if (self.loginType) {
                NSArray *controllers = [[MSAppDelegate getInstance] getNavigationController].childViewControllers;
                MSMainController *main = controllers[0];
                main.selectedIndex = 0;
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                //登录失败提示
                [MSToast show:NSLocalizedString(@"hint_login_error", @"")];
                [self handleRegistErrorPopRegistController];
            }
        }
    } completed:^{
    }];
}

- (void)pushPatternLockSetCanJump:(BOOL)can complete:(void(^)(void))complete {

    MSPatternSetController *setController = [[MSPatternSetController alloc] init];
    setController.canJumpOver = can;
    setController.patternLockSetBlock = complete;
    [self.navigationController pushViewController:setController animated:YES];
    
}

- (void)handleRegistErrorPopRegistController {
    if ([self.navigationController.childViewControllers.lastObject isKindOfClass:[MSRegistController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 129;
    params.title = @"登录";
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 129;
    params.title = @"登录";
    [MJSStatistics sendPageParams:params];
    
}

@end
