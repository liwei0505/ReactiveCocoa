//
//  MSPatternLockController.m
//  Sword
//
//  Created by haorenjie on 16/7/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPatternLockController.h"
#import "MSGestureView.h"
#import "MSLog.h"
#import "MSUtils.h"
#import "MSSettings.h"
#import "MSLoginController.h"
#import "MSStoryboardLoader.h"
#import "MSAppDelegate.h"
#import "MSTextUtils.h"
#import "UIButton+Custom.h"
#import "UILabel+Shake.h"
#import "MSTemporaryCache.h"

@interface MSPatternLockController () <IGestureInputResultDelegate>

@property (strong, nonatomic) UILabel *lbPhoneNumber;
@property (strong, nonatomic) UIImageView *ivPortrait;
@property (strong, nonatomic) MSGestureView *vGesture;
@property (copy, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UILabel *lbPatternErrorHint;

@end

@implementation MSPatternLockController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGBDecValue(251.f, 250.f, 249.f);

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;

    // Init lock view
    self.vGesture = [[MSGestureView alloc] init];
    CGFloat centerX = screenWidth / 2;
    CGFloat scaleRatio = screenWidth / 375.f;
    CGFloat margin = 52.5f * scaleRatio;
    CGFloat centerY = 225 * scaleRatio + (screenWidth - margin * 2) * 0.5;
    self.vGesture.center = CGPointMake(centerX, centerY);
    self.vGesture.delegate = self;
    self.vGesture.clip = NO;
    [self.view addSubview:self.vGesture];

    // Init title label
    self.lbPhoneNumber = [[UILabel alloc] init];
    self.lbPhoneNumber.font = [UIFont systemFontOfSize:17.f];
    [self.lbPhoneNumber setTextAlignment:NSTextAlignmentCenter];
    self.lbPhoneNumber.frame = CGRectMake(0, 0, screenWidth, 14);
    self.lbPhoneNumber.center = CGPointMake(screenWidth / 2, screenHeight / 6 + 35 + 20 - 12);
    self.lbPhoneNumber.textColor = UIColorFromRGBDecValue(51.f, 51.f, 51.f);
    [self.view addSubview:self.lbPhoneNumber];
    
    // Init pattern lock error hint
    self.lbPatternErrorHint = [[UILabel alloc] init];
    self.lbPatternErrorHint.font = [UIFont systemFontOfSize:14.f];
    [self.lbPatternErrorHint setTextAlignment:NSTextAlignmentCenter];
    self.lbPatternErrorHint.frame = CGRectMake(0, 0, screenWidth, 14);
    self.lbPatternErrorHint.center = CGPointMake(screenWidth / 2, screenWidth / 6 + 115);
//    self.lbPatternErrorHint.textColor = UIColorFromRGBDecValue(218.f, 27.f, 39.f);
    [self.view addSubview:self.lbPatternErrorHint];

    // Init portrait image
    self.ivPortrait = [[UIImageView alloc] init];
    self.ivPortrait.frame = CGRectMake(0.f, 0.f, 70.f, 70.f);
    self.ivPortrait.center = CGPointMake(screenWidth / 2, screenHeight / 6 - 12);
    NSString *userIcon = [MSTemporaryCache getTemporaryUserIcon] ?: @"user_icon_normal_1";
    [self.ivPortrait setImage:[UIImage imageNamed:userIcon]];
    self.ivPortrait.layer.borderWidth = 0;
    self.ivPortrait.layer.cornerRadius = 35;
    self.ivPortrait.clipsToBounds = YES;
    [self.view addSubview:self.ivPortrait];

    // Init forget password button
    UIButton *btnForgetPwd = [UIButton ms_createPatternButton:NSLocalizedString(@"str_forget_pattern_password", nil)];
    btnForgetPwd.frame = CGRectMake(margin, screenHeight - 60 + 11, screenWidth / 2, 20);
    [btnForgetPwd setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnForgetPwd addTarget:self action:@selector(onForgetPasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnForgetPwd];

    // Init switch account button
    UIButton *btnSwitchAccount = [UIButton ms_createPatternButton:NSLocalizedString(@"str_switch_account", nil)];
    btnSwitchAccount.frame = CGRectMake(screenWidth / 2 - margin, screenHeight - 60 + 11, screenWidth / 2, 20);
    [btnSwitchAccount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btnSwitchAccount addTarget:self action:@selector(onSwitchAccountButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSwitchAccount];

    MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
    self.phoneNumber = config.phoneNumber;
    if (!self.phoneNumber) {
        [MSLog error:@"user phone number is nil when patter lock login"];
    }
    
    if (![MSTextUtils isEmpty:self.phoneNumber]) {
        self.lbPhoneNumber.text = [self.phoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    
    if (config.patternLockErrorCount) {
        [self.lbPatternErrorHint setShakeText:[NSString stringWithFormat:@"密码错误,还可以输入%d次",(PATTERNLOCK_PASSWORD_ERROR_COUNT-config.patternLockErrorCount)]];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (self.window) {
        self.window.windowLevel = UIWindowLevelAlert;
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    if (self.window) {
        self.window.windowLevel = UIWindowLevelNormal;
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    [MSLog warning:@"didReceiveMemoryWarning"];
}

#pragma mark - IGestureInputResultDelegate
- (void)onGestureInputResult:(NSArray *)password {
    
    NSInteger count = password.count;
    NSMutableString *lockPassword = [[NSMutableString alloc] init];
    for (int i=0; i<count; i++) {
        [lockPassword appendFormat:@"%@", password[i]];
    }
    
    if (lockPassword.length < PATTERNLOCK_PASSWORD_LENGTH) {
        [self.lbPatternErrorHint setShakeText:NSLocalizedString(@"hint_patternLock_draw_error", @"")];
        [self patternLockError];
        return;
    }
    
    MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
    
    if (![config.patternLock isEqualToString:lockPassword]) {
        
        config.patternLockErrorCount++;
        [self.lbPatternErrorHint setShakeText:[NSString stringWithFormat:@"密码错误,还可以输入%d次",(PATTERNLOCK_PASSWORD_ERROR_COUNT-config.patternLockErrorCount)]];
        if (config.patternLockErrorCount == PATTERNLOCK_PASSWORD_ERROR_COUNT) {
            
            config.patternLockErrorCount = 0;
            config.patternLock = nil;
            [MSSettings saveLocalConfig:config];
            [MSSettings clearCurrentLoginUserId];
            
            MSLoginController *loginController = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
            loginController.backItem = nil;
            loginController.loginType = TYPE_PATTERN_FORGET;
            [[MSAppDelegate getServiceManager] logout];
            [self.navigationController pushViewController:loginController animated:YES];
            
        } else {
            
            [MSSettings saveLocalConfig:config];
            [self patternLockError];
        }
        
        return;
    }

    config.patternLockErrorCount = 0;
    [MSSettings saveLocalConfig:config];
    
    if (self.patternLockInputBlock) {
        self.patternLockInputBlock();
    }
    
}

#pragma mark - actions
- (void)onForgetPasswordButtonClicked:(id)sender {
    
    [self eventWithName:@"忘记手势密码" elementId:94];
    MSLoginController *loginController = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
    loginController.loginType = TYPE_PATTERN_FORGET;
    MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
    config.patternLock = nil;
    [MSSettings saveLocalConfig:config];
    [self.navigationController pushViewController:loginController animated:YES];
    
}

- (void)onSwitchAccountButtonClicked:(id)sender {
    
    [self eventWithName:@"切换账户" elementId:95];
    MSLoginController *loginController = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
    loginController.loginType = TYPE_CHANGE_USER;
    [self.navigationController pushViewController:loginController animated:YES];

}

#pragma mark - private

- (void)patternLockError {
    self.vGesture.lockStatus = PATTERN_LOCK_ST_ERROR;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.vGesture.lockStatus = PATTERN_LOCK_ST_NORMAL;
    });
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = (self.title) ? 182 : 160;
    if (self.title) {
        params.title = self.title;
    } else {
        params.title = @"验证手势密码";
    }
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = (self.title) ? 143 : 160;
    if (self.title) {
        params.title = self.title;
    } else {
        params.title = @"验证手势密码";
    }
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
