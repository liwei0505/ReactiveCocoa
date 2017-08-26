//
//  MSInvestRecordController.m
//  Sword
//
//  Created by msj on 2017/6/12.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestRecordController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "MSRefreshHeader.h"
#import "MSAppDelegate.h"
#import "MSInvestRecordList.h"
#import "MSInvestRecordCell.h"

@interface MSInvestRecordController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSInvestRecordList *investRecordList;
@end

@implementation MSInvestRecordController

#pragma mark - Life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configElement];
    [self addSubViews];
    [self setupHeaderView];
    [self setupRefreshHeader];
    [self setupRefreshFooter];
    [self configPageStateView];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.navigationItem.title pageId:173 params:nil];
}

- (void)dealloc {
    self.tableView.delegate = nil;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.mj_footer.hidden = !self.investRecordList.hasMore;
    return self.investRecordList.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSInvestRecordCell *cell = [MSInvestRecordCell cellWithTableView:tableView];
    cell.recordInfo = self.investRecordList.records[indexPath.row];
    return cell;
}

#pragma mark - query
- (void)queryInvestRecords:(NSNumber *)loanId requestType:(NSInteger)requestType{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryLoanInvestorListByType:requestType loanId:loanId] subscribeNext:^(NSNumber *loanId_) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.investRecordList = [[MSAppDelegate getServiceManager] getInvestRecords:self.loanId];
        [self.tableView reloadData];
        
        NSInteger count = self.investRecordList.records.count;
        if (count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        } else {
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
        RACError *result = (RACError *)error;
        [MSLog error:@"Query invest record list failed, result: %d", result.result];
    }];
}

#pragma mark - Private
- (void)configElement {
    self.navigationItem.title = @"投资记录";
}

- (void)addSubViews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 52;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)setupHeaderView {

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 45)];
    tableHeaderView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.tableView.tableHeaderView = tableHeaderView;
    
    CGFloat width = (self.view.width - 32) / 3.0;
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, width, tableHeaderView.height)];
    lbTitle.font = [UIFont systemFontOfSize:12];
    lbTitle.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbTitle.textAlignment = NSTextAlignmentLeft;
    lbTitle.text = @"投资人";
    [tableHeaderView addSubview:lbTitle];
    
    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(16 + width, 0, width, tableHeaderView.height)];
    lbTime.font = [UIFont systemFontOfSize:12];
    lbTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbTime.textAlignment = NSTextAlignmentCenter;
    lbTime.text = @"投资时间";
    [tableHeaderView addSubview:lbTime];
    
    UILabel *lbMoney = [[UILabel alloc] initWithFrame:CGRectMake(16 + width * 2, 0, width, tableHeaderView.height)];
    lbMoney.font = [UIFont systemFontOfSize:12];
    lbMoney.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbMoney.textAlignment = NSTextAlignmentRight;
    lbMoney.text = @"投资金额";
    [tableHeaderView addSubview:lbMoney];
}

- (void)setupRefreshHeader {
    @weakify(self);
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryInvestRecords:self.loanId requestType:LIST_REQUEST_NEW];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryInvestRecords:self.loanId requestType:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryInvestRecords:self.loanId requestType:LIST_REQUEST_NEW];
    };
    [self.pageStateView showInView:self.view];
}

@end
