//
//  MSMoneyController.m
//  Sword
//
//  Created by lee on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInvestController.h"
#import "MSInvestView.h"
#import "MSSecureView.h"
#import "MSSegmentView.h"

@interface MSInvestController ()<UIScrollViewDelegate>
@property (strong, nonatomic) MSSegmentView *segmentView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MSInvestView *investView;
@property (strong, nonatomic) MSSecureView *secureView;
@end

@implementation MSInvestController

#pragma mark - lazy
- (MSInvestView *)investView {
    if (!_investView) {
        _investView = [[MSInvestView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.scrollView.height)];
    }
    return _investView;
}

- (MSSecureView *)secureView {
    if (!_secureView) {
        _secureView = [[MSSecureView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.scrollView.height)];
    }
    return _secureView;
}

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureElement];
    [self addSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[MSAppDelegate getInstance] getNavigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    self.segmentView.type = (scrollView.contentOffset.x <= 0) ? Segment_Invest : Segment_Secure;
    if (self.segmentView.block) {
        self.segmentView.block(self.segmentView.type);
    }
}

#pragma mark - Private
- (void)configureElement {
    @weakify(self);
    self.segmentView = [[MSSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 150, 44)];
    self.tabBarController.navigationItem.titleView = self.segmentView;
    
    self.segmentView.block = ^(SegmentType type) {
        @strongify(self);
        if (type == Segment_Invest) {
            
            self.scrollView.contentOffset = CGPointMake(0, 0);
            if (!self.investView.superview) {
                [self.scrollView addSubview:self.investView];
            }
            
        } else if (type == Segment_Secure){
            [self pageEventWithTitle:@"保险" pageId:210 params:nil];
            self.scrollView.contentOffset = CGPointMake(self.view.width, 0);
            if (!self.secureView.superview) {
                [self.scrollView addSubview:self.secureView];
            }
            
        }
    };
}

- (void)addSubViews {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height - 64 - 49)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.width * 2, 0);
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.investView];
    
}

#pragma mark - 统计
- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 105;
    params.title = @"理财";
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId LoanId:(NSNumber *)loanId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 105;
    params.title = @"理财";
    params.elementId = eId;
    params.elementText = name;
    if (loanId) {
        NSString *key = @"loan_id";
        NSDictionary *dic = @{key:loanId};
        params.params = dic;
    }
    [MJSStatistics sendEventParams:params];
}

@end
