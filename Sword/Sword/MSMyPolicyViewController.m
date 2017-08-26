//
//  MSMyPolicyViewController.m
//  Sword
//
//  Created by msj on 2017/8/9.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSMyPolicyViewController.h"
#import "MSHistoryPolicyViewController.h"
#import "MSPolicyDetailViewController.h"
#import "MSMyPolicyCell.h"

@interface MSMyPolicyViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSListWrapper *list;
@end

@implementation MSMyPolicyViewController

#pragma mark -life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
    [self configureElement];
    [self setupRefreshHeader];
    [self setupRefreshFooter];
    [self configPageStateView];
    [MSNotificationHelper addObserver:self selector:@selector(reloadPolicyList) name:NOTIFY_POLICY_LIST_RELOAD object:nil];
    [self queryPolicyList:LIST_REQUEST_NEW];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.navigationItem.title pageId:216 params:nil];
}

- (void)dealloc {
    [MSNotificationHelper removeObserver:self];
    NSLog(@"%s",__func__);
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.list.count;
    self.tableView.mj_footer.hidden = !self.list.hasMore;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        MSMyPolicyCell *cell = [MSMyPolicyCell cellWithTableView:tableView];
        NSString *orderId = [self.list getItemWithIndex:indexPath.row];
        InsurancePolicy *policy = [[MSAppDelegate getServiceManager] getInsurancePolicyInfoWithId:orderId];
        cell.insurancePolicy = policy;
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        MSPolicyDetailViewController *vc = [[MSPolicyDetailViewController alloc] init];
        NSString *orderId = [self.list getItemWithIndex:indexPath.row];
        InsurancePolicy *policy = [[MSAppDelegate getServiceManager] getInsurancePolicyInfoWithId:orderId];
        [vc updateWithOrderId:policy.orderId type:MSPolicyDetailViewFromType_policyList];
        [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notification
- (void)reloadPolicyList {
    [self queryPolicyList:LIST_REQUEST_NEW];
}

#pragma mark - query
- (void)queryPolicyList:(ListRequestType)requestType {
    @weakify(self);
    NSUInteger status = POLICY_STATUS_TOBE_PAID | POLICY_STATUS_TOBE_PUBLISH | POLICY_STATUS_TOBE_ACTIVE | POLICY_STATUS_ACTIVE;
    [[[MSAppDelegate getServiceManager] queryMyInsurancePolicyListWithStatus:status reqeustType:requestType] subscribeNext:^(MSListWrapper *list) {
        @strongify(self);
        self.list = list;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (list.count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        } else {
            [self configPageStateView];
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
}

#pragma mark - private
- (void)configureElement {
    self.navigationItem.title = @"我的保单";
    @weakify(self);
    UIButton *btnHistory = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 16)];
    [btnHistory setTitle:@"历史保单" forState:UIControlStateNormal];
    [btnHistory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnHistory.titleLabel.font = [UIFont systemFontOfSize:12];
    btnHistory.showsTouchWhenHighlighted = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnHistory];
    [[btnHistory rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        MSHistoryPolicyViewController *historyPolicy = [[MSHistoryPolicyViewController alloc] init];
        [self.navigationController pushViewController:historyPolicy animated:YES];
    }];
}

- (void)addSubviews {
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 96;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    [self.view addSubview:self.tableView];
    
}

- (void)setupRefreshHeader {
    
    @weakify(self);
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryPolicyList:LIST_REQUEST_NEW];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryPolicyList:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryPolicyList:LIST_REQUEST_NEW];
    };
    [self.pageStateView showInView:self.view];
}

@end
