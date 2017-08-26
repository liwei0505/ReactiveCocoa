//
//  MSRedEnvelopeController.m
//  Sword
//
//  Created by lee on 16/6/24.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRedEnvelopeController.h"
#import "MSAppDelegate.h"
#import "MJSNotifications.h"
#import "MSLog.h"
#import "MSRulesAlertView.h"
#import "UIView+FrameUtil.h"
#import "MSRedEnvelopeView.h"
#import "MSRedEnvelopHeaderView.h"
#import "MSRedEnvelopeRuleView.h"

@interface MSRedEnvelopeController ()
@property (strong, nonatomic) MSRedEnvelopHeaderView *headerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MSRedEnvelopeView *availableRedEnvelopeView;
@property (strong, nonatomic) MSRedEnvelopeView *historyRedEnvelopeView;
@end

@implementation MSRedEnvelopeController
#pragma mark - lazy
- (MSRedEnvelopeView *)availableRedEnvelopeView {
    if (!_availableRedEnvelopeView) {
        _availableRedEnvelopeView = [[MSRedEnvelopeView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.scrollView.height)];
        _availableRedEnvelopeView.status = STATUS_AVAILABLE;
    }
    return _availableRedEnvelopeView;
}

- (MSRedEnvelopeView *)historyRedEnvelopeView {
    if (!_historyRedEnvelopeView) {
        _historyRedEnvelopeView = [[MSRedEnvelopeView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.scrollView.height)];
        _historyRedEnvelopeView.status = STATUS_EXPIRED;
    }
    return _historyRedEnvelopeView;
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureElement];
    [self addSubViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - Private
- (void)configureElement {
    @weakify(self);
    self.navigationItem.title = @"我的卡券";
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [btn setTitle:@"使用规则" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    btn.showsTouchWhenHighlighted = YES;
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self eventWithName:@"使用规则" elementId:78];
        MSRedEnvelopeRuleView *ruleView = [[MSRedEnvelopeRuleView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height)];
        [self.view.window addSubview:ruleView];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)addSubViews {
    
    @weakify(self);
    self.headerView = [[MSRedEnvelopHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 48)];
    [self.view addSubview:self.headerView];
    self.headerView.block = ^(RedEnvelopeStatus status) {
        @strongify(self);
        if (status == STATUS_AVAILABLE) {
            if (!self.availableRedEnvelopeView.superview) {
                [self.scrollView addSubview:self.availableRedEnvelopeView];
            }
            self.scrollView.contentOffset = CGPointMake(0, 0);
        } else if (status == STATUS_EXPIRED){
            if (!self.historyRedEnvelopeView.superview) {
                [self.scrollView addSubview:self.historyRedEnvelopeView];
            }
            self.scrollView.contentOffset = CGPointMake(self.view.width, 0);
        }
    };

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.view.width, [UIScreen mainScreen].bounds.size.height - 64 - self.headerView.height)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.width * 2, 0);
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
    self.scrollView.pagingEnabled = NO;
    self.scrollView.scrollEnabled = NO;
    [self.scrollView addSubview:self.availableRedEnvelopeView];
}

#pragma mark - 统计
- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 116;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 116;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
