//
//  MSPatternSetController.m
//  Sword
//
//  Created by haorenjie on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPatternSetController.h"
#import "MSGestureView.h"
#import "MSPatternLockThumbnail.h"
#import "MSUtils.h"
#import "MSSettings.h"
#import "UILabel+Shake.h"
#import "MSMainController.h"
#import "MSPasswordManageController.h"
#import "MSCheckInfoUtils.h"
#import "UIButton+Custom.h"
#import "UIColor+StringColor.h"
#import "MSRiskHomeViewController.h"
#import "MSRiskResultViewController.h"

const unsigned int LOCK_PASSWORD_MIN_LEN = 4;

@interface MSPatternSetController () <IGestureInputResultDelegate>

@property (copy, nonatomic) NSString *tempPassword;
@property (strong, nonatomic) UILabel *lbHint;
@property (strong, nonatomic) MSPatternLockThumbnail *lockThumbnail;
@property (strong, nonatomic) MSGestureView *vGesture;
@property (strong, nonatomic) UIButton *resetButton;

@end

@implementation MSPatternSetController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"str_more_set_pattern_lock", nil);
    self.view.backgroundColor = UIColorFromRGBDecValue(251.f, 250.f, 249.f);

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat widthScale = screenSize.width / 375;
    CGFloat heightScale = screenSize.height / 667;
    CGFloat centerX = self.view.center.x;
    
    // Init pattern lock thumbnail.
    self.lockThumbnail = [[MSPatternLockThumbnail alloc] init];
    self.lockThumbnail.frame = CGRectMake(centerX - 20, heightScale * 50, 40, 40);
    [self.view addSubview:self.lockThumbnail];

    // Init title label
    self.lbHint = [[UILabel alloc] init];
    self.lbHint.font = [UIFont systemFontOfSize:18.f];
    [self.lbHint setTextAlignment:NSTextAlignmentCenter];
    self.lbHint.frame = CGRectMake(0, 0, screenSize.width, 18);
    self.lbHint.center = CGPointMake(centerX, heightScale * 138);
    [self.lbHint setPatternLockHintText:NSLocalizedString(@"hint_patternLock_draw", @"")];
    [self.view addSubview:self.lbHint];

    // Init lock view
    self.vGesture = [[MSGestureView alloc] init];
    CGFloat width = widthScale * 255;
    self.vGesture.frame = CGRectMake(centerX - width * 0.5, heightScale * 188, width, width);
    self.vGesture.delegate = self;
    self.vGesture.clip = NO;
    [self.view addSubview:self.vGesture];
    
    //测试按钮
    UIButton *reset = [UIButton ms_createPatternButton:NSLocalizedString(@"hint_patternLock_reset", @"")];
    reset.frame = CGRectMake(0, 0, 200, 30);
    CGFloat buttonY = heightScale * 530;
    reset.center = CGPointMake(centerX, buttonY);
    [reset addTarget:self action:@selector(resetGestureInput) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reset];
    reset.hidden = YES;
    self.resetButton = reset;
    
    if (self.canJumpOver) {
        [self showJumpButton];
    }
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    if (self.showBackItem) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonOnClick)];
        self.navigationItem.leftBarButtonItem = backItem;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [MSLog warning:@"didReceiveMemoryWarning"];
}

- (void)setCanJumpOver:(BOOL)canJumpOver
{
    _canJumpOver = canJumpOver;
    if (_canJumpOver) {
        [self showJumpButton];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

#pragma mark - IGestureInputResultDelegate
- (void)onGestureInputResult:(NSArray *)password {
    
    NSString *lockPassword = [self convertPasswordToString:password];
    self.resetButton.hidden = NO;
    
    if (self.tempPassword) {
        if ([self.tempPassword isEqualToString:lockPassword]) {
            
            MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
            config.patternLock = lockPassword;
            config.switchStatus = YES;
            [MSSettings saveLocalConfig:config];
            
            [self.lockThumbnail showPatternLock:password];
            [self.lbHint setPatternLockHintText:NSLocalizedString(@"hint_patternLock_draw_succeed", @"")];
            
            if (self.patternLockSetBlock) {
                self.patternLockSetBlock();
                return;
            }
            //修改手势密码
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            self.vGesture.lockStatus = PATTERN_LOCK_ST_ERROR;
            [self.lbHint setShakeText:NSLocalizedString(@"hint_patternLock_draw_diffrent", @"")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.vGesture.lockStatus = PATTERN_LOCK_ST_NORMAL;
            });
        }
    } else {
        
        if ([self isLockPasswordLegal:lockPassword]) {
            self.tempPassword = lockPassword;
            self.vGesture.lockStatus = PATTERN_LOCK_ST_NORMAL;
            [self.lockThumbnail showPatternLock:password];
            [self.lbHint setPatternLockHintText:NSLocalizedString(@"hint_patternLock_draw_again", @"")];
            
        } else {
            self.vGesture.lockStatus = PATTERN_LOCK_ST_ERROR;
            [self.lbHint setShakeText:NSLocalizedString(@"hint_patternLock_draw_error", @"")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.vGesture.lockStatus = PATTERN_LOCK_ST_NORMAL;
            });
        }
    }
}

#pragma mark - actions
- (void)onJumpButtonClicked:(id)sender {
    
    MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
    config.patternLock = @"";
    config.switchStatus = NO;
    [MSSettings saveLocalConfig:config];
    
    if (self.patternLockSetBlock) {
        self.patternLockSetBlock();
        
    } else {
        [self jumpToAccountPage];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - private
- (void)showJumpButton
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"str_jump_over", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onJumpButtonClicked:)];
    self.navigationItem.rightBarButtonItem = item;
    [self.navigationItem setLeftBarButtonItem:nil];
    self.navigationItem.hidesBackButton = YES;
}

- (NSString *)convertPasswordToString:(NSArray *)password {

    NSInteger count = password.count;
    NSMutableString *lockPassword = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < count; i++) {
        [lockPassword appendFormat:@"%@", password[i]];
    }
    return lockPassword;
}

- (void)backButtonOnClick {

    MSPasswordManageController *manage = self.navigationController.childViewControllers[1];
    [self.navigationController popToViewController:manage animated:YES];
}

- (void)jumpToAccountPage {

    UITabBarController *controller = [[MSAppDelegate getInstance] getNavigationController].childViewControllers[0];
    [controller setTitle:NSLocalizedString(@"str_title_account", @"")];
    controller.selectedIndex = 2;
}

- (void)resetGestureInput {

    [self.lockThumbnail clearPatternLock];
    [self.lbHint setPatternLockHintText:NSLocalizedString(@"hint_patternLock_draw", @"")];
    self.tempPassword = nil;
    self.resetButton.hidden = YES;
}

- (BOOL)isLockPasswordLegal:(NSString *)password {
    
    return (!password || password.length < LOCK_PASSWORD_MIN_LEN) ? NO : YES;
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 156;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
}

@end
