//
//  MSNewPointController.m
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNewPointController.h"
#import "MSNewPointCell.h"
#import "MSNewPointHeaderView.h"
#import "MSRefreshHeader.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "MSNewPointShopController.h"
#import "MSStoryboardLoader.h"
#import "MSRulesAlertView.h"
#import "MSNewPointRulesView.h"

@interface MSNewPointController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSNewPointHeaderView *headerView;
@end

@implementation MSNewPointController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"str_account_score", @"");
    [self addSubviews];
    [self setupRefreshHeader];
    [self setupRefreshFooter];
    
    [self refreshNewData];
    
    [MSNotificationHelper addObserver:self selector:@selector(refreshNewData) name:NOTIFY_PRODUCT_EXCHANGE_SUCCESS];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc{
    [MSNotificationHelper removeObserver:self];
    NSLog(@"%s",__func__);
}

- (void)addSubviews{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.headerView = [[MSNewPointHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 240)];
    self.tableView.tableHeaderView = self.headerView;
    
    @weakify(self);
    self.headerView.enterPointShop = ^{
        @strongify(self);
        [self eventWithName:@"积分商城" elementId:20];
        MSNewPointShopController *pointShopController = [[MSNewPointShopController alloc] init];
        [self.navigationController pushViewController:pointShopController animated:YES];
    };
    
    self.headerView.showRules = ^{
        @strongify(self);
        [self eventWithName:@"积分规则" elementId:79];
        MSRulesAlertView *alertView = [[MSRulesAlertView alloc] init];
        MSNewPointRulesView *rulesView = [[MSNewPointRulesView alloc] initWithFrame:CGRectMake(0, 0, 280 , 260)];
        [alertView setContainerView:rulesView];
        alertView.buttonTitles = @[NSLocalizedString(@"str_confirm", @"")];
        [alertView show];
    };
}

- (void)setupRefreshHeader{
    __weak typeof(self)weakSelf = self;
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refreshNewData];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter{
    __weak typeof(self)weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf refreshMoreData];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)refreshNewData{
    [self queryMyPoints];
    [self queryMyPointList:LIST_REQUEST_NEW];
}

- (void)refreshMoreData{
    [self queryMyPointList:LIST_REQUEST_MORE];
}

#pragma mark - tableview datasource and delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MSNewPointCell *cell = [MSNewPointCell cellWithTableView:tableView];
    cell.pointRecord = [[MSAppDelegate getServiceManager] getPointList][indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = [[MSAppDelegate getServiceManager] getPointList].count;
    BOOL isHasMorePointData = [[MSAppDelegate getServiceManager] hasMorePointData];
    self.tableView.mj_footer.hidden = !isHasMorePointData;
    return count;
}

#pragma mark - Private
- (void)queryMyPoints{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyPoints] subscribeNext:^(UserPoint *userPoint) {
        @strongify(self);
        self.headerView.userPoint = userPoint;
    } error:^(NSError *error) {
        [MSLog error:@"usermodel error during query my points!"];
    }];
}

- (void)queryMyPointList:(ListRequestType)requestType{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyPointDetailsByType:requestType] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 117;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
    
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 117;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
