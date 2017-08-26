//
//  MSRiskResultViewController.m
//  Sword
//
//  Created by msj on 2016/12/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRiskResultViewController.h"
#import "MSRiskTopicViewController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "UIImage+color.h"
#import "UIImageView+WebCache.h"
#import "MSAppDelegate.h"
#import "MSConfig.h"
#import "MSUserInfoController.h"

#define screenHeight  [UIScreen mainScreen].bounds.size.height
#define screenWidth  [UIScreen mainScreen].bounds.size.width

#pragma mark - MSRiskResultViewController
@interface MSRiskResultViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbRisk;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *lbTips;

@property (strong, nonatomic) UIButton *btnReapet;
@end

@implementation MSRiskResultViewController

#pragma mark - Life Style
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configElement];
    [self addScrollView];
    [self addBackItem];
    [self configPageStateView];
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

#pragma mark - Private
- (void)configElement {
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#EEEEEE"];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"风险测评"];
}

- (void)addScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollView.width - 160)/2.0, 35 * scaleY, 160, 160)];
    self.imageView.image = [UIImage imageNamed:@"risk_result_placeholder"];
    [self.scrollView addSubview:self.imageView];
    
    self.lbRisk = [[UILabel alloc] initWithFrame:CGRectMake((self.scrollView.width - 100)/2.0, CGRectGetMaxY(self.imageView.frame) + 25, 100, 27)];
    self.lbRisk.font = [UIFont boldSystemFontOfSize:20];
    self.lbRisk.textColor = [UIColor ms_colorWithHexString:@"#333092"];
    self.lbRisk.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:self.lbRisk];
    
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(35, 0, (self.scrollView.width - 170)/2.0, 1)];
    leftLine.centerY = self.lbRisk.centerY;
    leftLine.backgroundColor = [UIColor ms_colorWithHexString:@"#333092"];
    [self.scrollView addSubview:leftLine];
    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lbRisk.frame), 0, (self.scrollView.width - 170)/2.0, 1)];
    rightLine.centerY = self.lbRisk.centerY;
    rightLine.backgroundColor = [UIColor ms_colorWithHexString:@"#333092"];
    [self.scrollView addSubview:rightLine];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbRisk.frame) + 20, self.scrollView.width, 0)];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.contentView];
    
    self.btnReapet = [[UIButton alloc] initWithFrame:CGRectMake(0, self.scrollView.height - 50, self.scrollView.width, 50)];
    [self.btnReapet setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.btnReapet setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.btnReapet setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    [self.btnReapet setTitle:@"重新测试" forState:UIControlStateNormal];
    [self.btnReapet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnReapet addTarget:self action:@selector(repeatAnswer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnReapet];
    
    self.lbTips = [[UILabel alloc] initWithFrame:CGRectMake(0, self.btnReapet.y - 30, self.scrollView.width, 20)];
    self.lbTips.textAlignment =  NSTextAlignmentCenter;
    self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#555555"];
    self.lbTips.font = [UIFont systemFontOfSize:12];
    self.lbTips.text = @"测评结果仅供参考";
    [self.scrollView addSubview:self.lbTips];
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryRiskConfigueWithRiskType:self.resultInfo.type];
    };
    [self.pageStateView showInView:self.view];
}

- (void)addBackItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"risk_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonOnClick)];
}

- (void)backButtonOnClick
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [MSAppDelegate getServiceManager].topics = nil;
    [self pop];
}

- (void)pop {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[MSUserInfoController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return ;
        }
    }
}

- (void)repeatAnswer
{
    [self eventWithName:@"重新评测" elementId:106];
    MSRiskTopicViewController *topicViewController = [[MSRiskTopicViewController alloc] init];
    [self.navigationController pushViewController:topicViewController animated:YES];
}

- (void)updateUI
{
    if (self.resultInfo.title) {
        
        self.pageStateView.state = MSPageStateMachineType_loaded;
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.resultInfo.icon] placeholderImage:[UIImage imageNamed:@"risk_result_placeholder"] options:SDWebImageRetryFailed];
        self.lbRisk.text = self.resultInfo.title;
        
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        NSArray *strArr = [self.resultInfo.desc componentsSeparatedByString:@"\\n"];
        for (int i = 0; i < strArr.count; i++) {
            MSRiskContainView *riskContentView = [[MSRiskContainView alloc] init];
            if (i == 0) {
                riskContentView.frame = CGRectMake(0, 0, self.contentView.width, 0);
            }else{
                MSRiskContainView *lastRiskContentView = (MSRiskContainView *)self.contentView.subviews.lastObject;
                riskContentView.frame = CGRectMake(0, CGRectGetMaxY(lastRiskContentView.frame) + 15, self.contentView.width, 0);
            }
            riskContentView.content = strArr[i];
            [self.contentView addSubview:riskContentView];
            if (i == strArr.count - 1) {
                MSRiskContainView *lastRiskContentView = (MSRiskContainView *)self.contentView.subviews.lastObject;
                self.contentView.height = CGRectGetMaxY(lastRiskContentView.frame);
            }
        }
        
        if (CGRectGetMaxY(self.contentView.frame) > self.btnReapet.y - 30) {
            self.lbTips.y = CGRectGetMaxY(self.contentView.frame) + 30;
        }else{
            self.lbTips.y = self.btnReapet.y - 30;
        }
        self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.lbTips.frame) + 10);
        
    } else {
        self.pageStateView.state = MSPageStateMachineType_loading;
        [self queryRiskConfigueWithRiskType:self.resultInfo.type];
    }
}

- (void)queryRiskConfigueWithRiskType:(RiskType)type{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryRiskInfoByType:type] subscribeNext:^(RiskResultInfo *userRiskInfo) {
        @strongify(self);
        self.resultInfo = userRiskInfo;
        [self updateUI];
    } error:^(NSError *error) {
        @strongify(self);
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 146;
    params.title = @"风险测评结果";
    [MJSStatistics sendPageParams:params];
    
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 146;
    params.title = @"风险测评结果";
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end


#pragma mark - MSRiskContainView
@implementation MSRiskContainView
-(void)setContent:(NSString *)content
{
    _content = content;
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(98 * [UIScreen mainScreen].bounds.size.width / 320.0, 6, 6, 6)];
    cornerView.layer.cornerRadius = 3;
    cornerView.layer.masksToBounds = YES;
    cornerView.backgroundColor = [UIColor ms_colorWithHexString:@"#666666"];
    [self addSubview:cornerView];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(cornerView.frame) - 35;
    CGSize size = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cornerView.frame) + 12, 0, width, size.height)];
    lbTitle.text = content;
    lbTitle.numberOfLines = 0;
    lbTitle.font = [UIFont systemFontOfSize:15];
    lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    lbTitle.textAlignment = NSTextAlignmentLeft;
    [self addSubview:lbTitle];
    
    self.height = lbTitle.height;
}

@end
