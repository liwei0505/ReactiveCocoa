//
//  MSCurrentIncomeDetail.m
//  Sword
//
//  Created by lee on 17/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentIncomeDetail.h"
#import "MSRefreshHeader.h"
#import "MSCurrentIncomeDetailCell.h"

@interface MSCurrentIncomeDetail ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSNumber *currentId;

@end

@implementation MSCurrentIncomeDetail

#pragma mark - lifecycle

- (instancetype)initWithCurrentId:(NSNumber *)currentId {
    if (self = [super init]) {
        _currentId = currentId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
}

- (void)prepareUI {
    
    self.title = @"历史收益";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 52;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self prepareHeaderView];
    
    __weak typeof(self)weakSelf = self;
    MSRefreshHeader *refreshHeader = [MSRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf onPullToUpdateList];
    }];
    self.tableView.mj_header = refreshHeader;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf queryCurrentEarningsHistory:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self onPullToUpdateList];
    
}

- (void)prepareHeaderView {
    float width = self.view.frame.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    headerView.backgroundColor = [UIColor ms_colorWithHexString:@"#EBEBF2"];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, 30)];
    timeLabel.font = [UIFont systemFontOfSize:11.f];
    timeLabel.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    timeLabel.text = @"收益日期";
    [headerView addSubview:timeLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-70, 0, 50, 30)];
    moneyLabel.font = [UIFont systemFontOfSize:11.f];
    moneyLabel.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    moneyLabel.text = @"到账金额";
    [headerView addSubview:moneyLabel];
    
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - tableview datasource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    MSListWrapper *listWrapper = [[MSAppDelegate getServiceManager] getCurrentEarningsHistory:self.currentId];
    self.tableView.mj_footer.hidden = !listWrapper.hasMore;
    if ([listWrapper getList].count) {
        [self hideEmptyView];
    } else {
        [self showEmptyView];
    }
    return [listWrapper getList].count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MSListWrapper *listWrapper = [[MSAppDelegate getServiceManager] getCurrentEarningsHistory:self.currentId];
    MSCurrentIncomeDetailCell *cell = [MSCurrentIncomeDetailCell cellWithTable:tableView];
    cell.earnings = listWrapper.getList[indexPath.row];
    return cell;
}

#pragma mark - query data

- (void)onPullToUpdateList {
    [self queryCurrentEarningsHistory:LIST_REQUEST_NEW];
}

- (void)queryCurrentEarningsHistory:(ListRequestType)type {
    @weakify(self);
    
    [[[MSAppDelegate getServiceManager] queryCurrentEarningsHistoryByType:type WithID:self.currentId] subscribeError:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        RACError *result = (RACError *)error;
        if (result.message) {
            [MSToast show:result.message];
        }
    } completed:^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }];

}

- (void)showEmptyView {
    [super showEmptyView];
    self.emptyView.frame = CGRectMake(0, 30, self.tableView.frame.size.width, self.tableView.frame.size.height-30);
    [self.tableView addSubview:self.emptyView];
}

- (void)hideEmptyView {
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
}

@end
