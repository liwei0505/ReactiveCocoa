//
//  MSRiskHomeViewController.m
//  Sword
//
//  Created by msj on 2016/12/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRiskHomeViewController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "UIImage+color.h"
#import "MSRiskTopicViewController.h"
#import "MSAppDelegate.h"
#import "MSAlertController.h"
#import "MSUserInfoController.h"

#define screenHeight  [UIScreen mainScreen].bounds.size.height
#define screenWidth  [UIScreen mainScreen].bounds.size.width

@interface MSRiskHomeViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnBegin;
@end

@implementation MSRiskHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#EEEEEE"];
    self.navigationItem.title = [NSString stringWithFormat:@"风险测评"];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self addImageView];
    [self addBeginButton];
    [self addBackItem];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)addImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, screenWidth, screenHeight)];
    if (screenHeight >= 736) {
        self.imageView.image = [UIImage imageNamed:@"risk_introduce_6p"];
    }else if (screenHeight >= 667){
        self.imageView.image = [UIImage imageNamed:@"risk_introduce_6"];
    }else if (screenHeight >= 568){
        self.imageView.image = [UIImage imageNamed:@"risk_introduce_5"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"risk_introduce_4"];
    }
    [self.view addSubview:self.imageView];
}

- (void)addBeginButton
{
    self.btnBegin = [[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight - 64 - 50, screenWidth, 50)];
    [self.btnBegin setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.btnBegin setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.btnBegin setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    [self.btnBegin setTitle:@"开始测试" forState:UIControlStateNormal];
    [self.btnBegin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnBegin addTarget:self action:@selector(beginTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnBegin];
}

- (void)addBackItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"risk_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonOnClick)];
}

- (void)backButtonOnClick
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    __weak typeof(self)weakSelf = self;
    MSAlertController *vc = [MSAlertController alertControllerWithTitle:@"提示" message:@"本次风险偏好测试还未完成，退出后将不保存当前进度，确定退出吗?" preferredStyle:UIAlertControllerStyleAlert];
    [vc msSetMssageColor:[UIColor ms_colorWithHexString:@"#000000"] mssageFont:[UIFont systemFontOfSize:14.0]];
    [vc msSetTitleColor:[UIColor ms_colorWithHexString:@"#000000"] titleFont:[UIFont boldSystemFontOfSize:17.0]];
    MSAlertAction *sure = [MSAlertAction actionWithTitle:@"继续测评" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self eventWithName:@"继续评测" elementId:107];
    }];
    sure.mstextColor = [UIColor ms_colorWithHexString:@"#2C90FD"];
    MSAlertAction *cancel = [MSAlertAction actionWithTitle:@"立即退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self eventWithName:@"立即退出" elementId:107];
        [MSAppDelegate getServiceManager].topics = nil;
        [weakSelf pop];
    }];
    sure.mstextColor = [UIColor ms_colorWithHexString:@"#007AFF"];
    [vc addAction:sure];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)pop {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[MSUserInfoController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return ;
        }
    }
}

- (void)beginTest
{
    [self eventWithName:@"开始测试" elementId:93];
    MSRiskTopicViewController *topicViewController = [[MSRiskTopicViewController alloc] init];
    [self.navigationController pushViewController:topicViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 145;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
    
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 145;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
