//
//  MSFundsFlowController.m
//  Sword
//
//  Created by lw on 16/6/20.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSFundsFlowController.h"
#import "MSAppDelegate.h"
#import "FundsFlow.h"
#import "MSLog.h"
#import "MSFundsFlowCell.h"
#import "UIView+FrameUtil.h"
#import "MSRefreshHeader.h"
#import "MSFundsFlowView.h"


@interface MSFundsFlowController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) int recordTypeIndex;
@property (strong, nonatomic) MSFundsFlowView *flowView;
@property (strong, nonatomic) UIButton *btnSelected;
@end

@implementation MSFundsFlowController
#pragma mark - lazy
- (MSFundsFlowView *)flowView {
    if (!_flowView) {
        @weakify(self);
        _flowView = [[MSFundsFlowView alloc] initWithFrame:[UIScreen mainScreen].bounds point:CGPointMake(self.btnSelected.centerX, 64)];
        _flowView.blcok = ^(int recordTypeIndex) {
            @strongify(self);
            self.recordTypeIndex = recordTypeIndex;
            [self.tableView.mj_header beginRefreshing];
        };
    }
    return _flowView;
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureElement];
    [self addSubViews];
    
    [self configPageStateView];
    [self refreshNewData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = [[MSAppDelegate getServiceManager] getFundsFlowList].count;
    self.tableView.mj_footer.hidden = ![[MSAppDelegate getServiceManager] hasMoreFundsFlow];
    if (count > 0) {
        [self hideEmptyView];
    } else {
        [self showEmptyView];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSFundsFlowCell *fundsCell = [MSFundsFlowCell cellWithTableView:tableView];
    fundsCell.fundsFlow = [[MSAppDelegate getServiceManager] getFundsFlowList][indexPath.row];
    return fundsCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}

#pragma mark - Private
- (void)configureElement {
    @weakify(self);
    self.navigationItem.title = @"交易记录";
    self.recordTypeIndex = TYPE_ALL;
    self.btnSelected = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
    [self.btnSelected setTitle:@"筛选" forState:UIControlStateNormal];
    self.btnSelected.titleLabel.font = [UIFont systemFontOfSize:12];
    self.btnSelected.showsTouchWhenHighlighted = YES;
    [[self.btnSelected rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
       [self eventWithName:@"流水类型" elementId:74];
        [self.view.window addSubview:self.flowView];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnSelected];
}

- (void)addSubViews {
    
    @weakify(self);
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self.view addSubview:self.tableView];
    
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self refreshNewData];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self refreshMoreData];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)refreshMoreData {
    [self queryMyFundsFlow:LIST_REQUEST_MORE recordType:self.recordTypeIndex timeType:ALL];
}

- (void)refreshNewData {
    [self queryMyFundsFlow:LIST_REQUEST_NEW recordType:self.recordTypeIndex timeType:ALL];
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self refreshNewData];
    };
    [self.pageStateView showInView:self.view];
}

- (void)showEmptyView {
    [super showEmptyView];
    self.emptyView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height);
    [self.tableView addSubview:self.emptyView];
}

- (void)hideEmptyView {
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
}

#pragma mark - query
- (void)queryMyFundsFlow:(ListRequestType)requestType recordType:(FlowType)type timeType:(Period)time{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyFundsFlowByType:requestType typeCategory:type timeCategory:time] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        NSInteger count = [[MSAppDelegate getServiceManager] getFundsFlowList].count;
        if (count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        } else {
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
        
    } error:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
}

#pragma mark - 统计
- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 115;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 115;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
