//
//  MSPolicyDetailViewController.m
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPolicyDetailViewController.h"
#import "MSPolicyDetailViewModel.h"
#import "MSProjectFileController.h"
#import "MSInsuranceDetailController.h"
#import "MSPolicyHeaderView.h"
#import "MSPolicyFooterView.h"
#import "MSPolicyDetailCell.h"
#import "MSWebViewController.h"
#import "MSUrlManager.h"
#import "NSString+URLEncoding.h"

@interface MSPolicyDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) MSPolicyDetailViewModel *viewModel;
@property (copy  , nonatomic) NSString *orderId;
@property (assign, nonatomic) MSPolicyDetailViewFromType type;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSPolicyHeaderView *headerView;
@property (strong, nonatomic) MSPolicyFooterView *footerView;
@end

@implementation MSPolicyDetailViewController

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
    [self setupRefreshHeader];
    [self configPageStateView];
    [MSNotificationHelper addObserver:self selector:@selector(reloadPolicyList) name:NOTIFY_POLICY_LIST_RELOAD object:nil];
    [self queryPolicyDetail];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.navigationItem.title pageId:218 params:nil];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - Notification
- (void)reloadPolicyList {
    [self queryPolicyDetail];
}

#pragma mark - Public
- (void)updateWithOrderId:(NSString *)orderId type:(MSPolicyDetailViewFromType)type {
    self.orderId = orderId;
    self.type = type;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel.datas[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSPolicyDetailCell *cell = [MSPolicyDetailCell cellWithTableView:tableView];
    cell.model = self.viewModel.datas[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MSPolicyDetailModel *model = self.viewModel.datas[indexPath.section][indexPath.row];
    if (model.type == MSPolicyDetailModel_productDetail) {
        MSInsuranceDetailController *vc = [[MSInsuranceDetailController alloc] init];
        vc.type = MSInsuranceDetailFromType_policyDetail;
        vc.insuranceId = self.viewModel.policy.insuranceId;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (model.type == MSPolicyDetailModel_electronicPolicy) {
        MSProjectFileController *projectFileController = [[MSProjectFileController alloc] init];
        [projectFileController updateWithFileName:@"电子保单" fileUrl:self.viewModel.policy.electronicPolicyUrl];
        [self.navigationController pushViewController:projectFileController animated:YES];
    } else if (model.type == MSPolicyDetailModel_serviceTel) {
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,2,0}]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.viewModel.policy.serviceTel]]];
        } else {
            [MSAlert showWithTitle:self.viewModel.policy.serviceTel message:nil buttonClickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.viewModel.policy.serviceTel]]];
                }
            } cancelButtonTitle:NSLocalizedString(@"str_cancel", @"") otherButtonTitles:NSLocalizedString(@"str_call", @""), nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - query
- (void)queryPolicyDetail {
    
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryInsurancePolicyInfoWithId:self.orderId] subscribeNext:^(InsurancePolicy *policyInfo) {
        @strongify(self);
        self.viewModel.policy = policyInfo;
        self.headerView.policy = policyInfo;
        self.footerView.policy = policyInfo;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
    } completed:^{
        @strongify(self);
        self.pageStateView.state = MSPageStateMachineType_loaded;
    }];
}

- (void)pay {
    @weakify(self);
    [MSProgressHUD showWithStatus:@"获取订单信息中..."];
    [[[MSAppDelegate getServiceManager] queryFHOnlinePayInfoWithOrderId:self.orderId] subscribeNext:^(FHOlinePayInfo *payInfo) {
        @strongify(self);
        [MSProgressHUD dismiss];
        MSWebViewController *webVC = [MSWebViewController load];
        NSString *payUrl = [NSString stringWithFormat:@"%@?orderInfo=%@&channelCode=%@",[MSUrlManager getFHOLPayUrl],[payInfo.orderInfo URLEncodedString],[payInfo.channelCode URLEncodedString]];
        [webVC payUrl:payUrl payCompletion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        webVC.navigationItem.title = @"在线支付";
        [self.navigationController pushViewController:webVC animated:YES];
    } error:^(NSError *error) {
        [MSProgressHUD dismiss];
        [MSToast show:@"获取订单信息失败"];
    }];
}

- (void)cancel {
    @weakify(self);
    [MSProgressHUD showWithStatus:@"正在取消中..."];
    [[[MSAppDelegate getServiceManager] cancelInsuranceWithOrderId:self.orderId] subscribeError:^(NSError *error) {
        [MSProgressHUD dismiss];
        [MSToast show:@"取消失败"];
    } completed:^{
        [MSProgressHUD dismiss];
        @strongify(self);
        [MSNotificationHelper notify:NOTIFY_POLICY_LIST_RELOAD result:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - private
- (void)addSubviews {
    
    self.viewModel = [[MSPolicyDetailViewModel alloc] init];
    
    self.navigationItem.title = @"保单详情";
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 48;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[MSPolicyHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 112)];
    self.tableView.tableHeaderView = self.headerView;
    
    @weakify(self);
    self.footerView = [[MSPolicyFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.tableView.tableFooterView = self.footerView;
    self.footerView.cancelBlock = ^{
        @strongify(self);
        [self pageEventWithTitle:@"提醒-取消保单" pageId:219 params:nil];
        [MSAlert showWithTitle:@"确认放弃投保?" message:nil buttonClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self cancel];
            }
        } cancelButtonTitle:@"取消订单" otherButtonTitles:@"继续投保", nil];
    };
    self.footerView.payBlock = ^{
        @strongify(self);
        [self pay];
    };
}

- (void)setupRefreshHeader {
    @weakify(self);
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryPolicyDetail];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryPolicyDetail];
    };
    [self.pageStateView showInView:self.view];
}
@end
