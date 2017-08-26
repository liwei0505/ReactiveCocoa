//
//  MSPasswordManageController.m
//  Sword
//
//  Created by lee on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPasswordManageController.h"
#import "MSPatternSetController.h"
#import "MSPatternLockController.h"
#import "MSPasswordModifyController.h"
#import "MSSettings.h"
#import "UILabel+Custom.h"
#import "MSSetTradePassword.h"
#import "MSBindCardController.h"
#import "MSResetTradePasswordA.h"

@interface MSPasswordManageController ()
{
    RACDisposable *_accountInfoSubscription;
}

@property (strong, nonatomic) UISwitch *patternSwitch;
@property (strong, nonatomic) UIView *modifyView;
@property (strong, nonatomic) AccountInfo *accountInfo;

@end

@implementation MSPasswordManageController

#pragma mark - lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self prepareUI];

    @weakify(self);
    _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
    
    BOOL isLockOpened = config.switchStatus;
    [self.patternSwitch setOn:isLockOpened];
    if (isLockOpened) {
        self.modifyView.hidden = NO;
    } else {
        self.modifyView.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
    NSLog(@"%s",__func__);
}

#pragma mark - UI

- (void)prepareUI {

    self.title = NSLocalizedString(@"str_more_password", @"");
    CGFloat width = self.view.bounds.size.width;
    float margin = 16;
    float height = 64;
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, width, 33)];
    lbTitle.text = @"设置锁屏和解锁方式";
    lbTitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    lbTitle.textColor =  [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    [self.view addSubview:lbTitle];
    
    //手势密码
    UIView *patternView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbTitle.frame), width, height+1)];
    patternView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:patternView];
    
    UILabel *patternLabel = [UILabel labelWithText:NSLocalizedString(@"str_more_password_patternlock", @"") textSize:14.0 textColor:@"333333"];
    [patternView addSubview:patternLabel];
    [patternLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [patternView addConstraint:[NSLayoutConstraint constraintWithItem:patternLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:patternView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:margin]];
    [patternView addConstraint:[NSLayoutConstraint constraintWithItem:patternLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:patternView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    self.patternSwitch = [[UISwitch alloc] init];
    self.patternSwitch.onTintColor = [UIColor ms_colorWithHexString:@"4945B7"];
    [self.patternSwitch addTarget:self action:@selector(patternSwitchChange:) forControlEvents:UIControlEventValueChanged];
    [patternView addSubview:self.patternSwitch];
    [self.patternSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
    [patternView addConstraint:[NSLayoutConstraint constraintWithItem:self.patternSwitch attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:patternView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-margin]];
    [patternView addConstraint:[NSLayoutConstraint constraintWithItem:self.patternSwitch attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:patternView attribute:NSLayoutAttributeTop multiplier:1.0 constant:margin]];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(margin, height, width, 1)];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [patternView addSubview:line];
    
    //修改手势密码
    self.modifyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(patternView.frame), width, height)];
    self.modifyView.backgroundColor = [UIColor whiteColor];
    [self.modifyView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modifyPatternLock:)]];
    [self.view addSubview:self.modifyView];
    
    UILabel *modifyLabel = [UILabel labelWithText:NSLocalizedString(@"str_more_password_modify_patternlock", @"") textSize:14.0 textColor:@"333333"];
    [self.modifyView addSubview:modifyLabel];
    [modifyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.modifyView addConstraint:[NSLayoutConstraint constraintWithItem:modifyLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.modifyView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:margin]];
    [self.modifyView addConstraint:[NSLayoutConstraint constraintWithItem:modifyLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.modifyView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    UIImageView *modifyArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow"]];
    [self.modifyView addSubview:modifyArrow];
    [modifyArrow setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.modifyView addConstraint:[NSLayoutConstraint constraintWithItem:modifyArrow attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.modifyView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-margin]];
    [self.modifyView addConstraint:[NSLayoutConstraint constraintWithItem:modifyArrow attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.modifyView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
}

#pragma mark - IBAction

- (void)patternSwitchChange:(UISwitch *)sender {
 
    [self eventWithName:@"手势密码开关" elementId:84];
    if (sender.on) {
        
        MSPatternSetController *patternSet = [[MSPatternSetController alloc] init];
        patternSet.canJumpOver = NO;
        [self.navigationController pushViewController:patternSet animated:YES];
       
    } else {
    
        MSPatternLockController *patternLock = [[MSPatternLockController alloc] init];
        __weak typeof(self)weakSelf = self;
        patternLock.patternLockInputBlock = ^{
            MSUserLocalConfig *config = [MSSettings getLocalConfig:[MSSettings getLastLoginInfo].userId];
            config.switchStatus = NO;
            config.patternLock = @"";
            [MSSettings saveLocalConfig:config];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        patternLock.title = NSLocalizedString(@"str_title_patternLock_check", @"");
        [self.navigationController pushViewController:patternLock animated:YES];
    }
}

- (void)modifyPatternLock:(UIButton *)sender {
  
    [self eventWithName:@"手势密码" elementId:32];
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:143 control:33 params:nil];
    MSPatternLockController *patternSet = [[MSPatternLockController alloc] init];
    patternSet.title = NSLocalizedString(@"str_title_patternLock_check", @"");
    __weak typeof(self)weakSelf = self;
    patternSet.patternLockInputBlock = ^{
        MSPatternSetController *setPattern = [[MSPatternSetController alloc] init];
        setPattern.showBackItem = YES;
        setPattern.patternLockSetBlock = ^{
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        };
        [weakSelf.navigationController pushViewController:setPattern animated:YES];
    };
    [self.navigationController pushViewController:patternSet animated:YES];
    
}

#pragma mark - private

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 181;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
    
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 181;
    params.title = self.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
