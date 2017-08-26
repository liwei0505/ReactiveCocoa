//
//  MSInsuranceDetailController.m
//  Sword
//
//  Created by lee on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceDetailController.h"
#import "MSInsuranceDetailHeader.h"
#import "MSInsuranceDetailTypeCell.h"
#import "MSInsuranceDetailInfoCell.h"
#import "MSInsureObjectCell.h"
#import "MSInsuranceDetailContentCell.h"
#import "MSInsuranceDetailBottomView.h"
#import "MSInsuranceDetailViewModel.h"
#import "MSWebViewController.h"
#import "MSPolicyDetailViewController.h"
#import "MSInsuranceTypeView.h"
#import "MSLoginController.h"
#import "MSStoryboardLoader.h"

@interface MSInsuranceDetailController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSInsuranceDetailHeader *headerView;
@property (strong, nonatomic) MSInsuranceDetailBottomView *bottomView;
@property (strong, nonatomic) MSInsuranceDetailViewModel *viewModel;
@property (strong, nonatomic) MSInsuranceDetailContentCell *contentCell;
@property (assign, nonatomic) InsuranceTypeSelected selectedType;

@end

@implementation MSInsuranceDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    
    @weakify(self);
    [self.viewModel queryDetail:self.insuranceId completion:^(BOOL status) {
        @strongify(self);
        if (status) {
            NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:12]};
            CGSize size = [_viewModel.detail.introduction boundingRectWithSize:CGSizeMake(self.view.bounds.size.width-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
            self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 250+size.height);
            self.headerView.detail = _viewModel.detail;
            self.tableView.tableHeaderView = self.headerView;
    
            
            if (_viewModel.detail.productList.count) {
                double amount = _viewModel.detail.productList[0].premium.doubleValue * self.viewModel.count;
                self.bottomView.lbAmount.text = [NSString stringWithFormat:@"%.2f元",amount];
            }
            self.bottomView.phone = _viewModel.detail.serviceTel;
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.type != MSInsuranceDetailFromType_home) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:@"产品详情" pageId:218 params:nil];
}

#pragma mark - datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        MSInsuranceDetailTypeCell *cell = [MSInsuranceDetailTypeCell cellWithTableView:tableView];
        cell.viewModel = self.viewModel;
        cell.detail = self.viewModel.detail;
        @weakify(self);
        cell.selectBlock = ^(InsuranceTypeSelected type) {
            @strongify(self);
            self.selectedType = type;
            double amount = _viewModel.detail.productList[type].premium.doubleValue*self.viewModel.count;
            self.bottomView.lbAmount.text = [NSString stringWithFormat:@"%.2f元",amount];
        };
        return cell;
    } else if (indexPath.row == 1) {
        MSInsuranceDetailInfoCell *cell = [MSInsuranceDetailInfoCell cellWithTableView:tableView];
        cell.viewModel = self.viewModel;
        cell.detail = self.viewModel.detail;
        @weakify(self);
        cell.updateCountBlock = ^(int count) {
            @strongify(self);
            double amount = _viewModel.detail.productList[self.selectedType].premium.doubleValue*self.viewModel.count;
            self.bottomView.lbAmount.text = [NSString stringWithFormat:@"%.2f元",amount];
        };
        return cell;
    } else if (indexPath.row == 2) {
        MSInsureObjectCell *cell = [MSInsureObjectCell cellWithTableView:tableView];
        cell.viewModel = self.viewModel;
        cell.detail = self.viewModel.detail;
        @weakify(self);
        cell.switchBlock = ^(BOOL on) {
            @strongify(self);
            self.viewModel.switchStatus = on;
            [self.tableView reloadData];
        };
        return cell;
    } else if (indexPath.row == 3) {
        MSInsuranceDetailContentCell *cell = [MSInsuranceDetailContentCell cellWithTableView:tableView];
        cell.viewModel = self.viewModel;
        cell.detail = self.viewModel.detail;
        self.contentCell = cell;
        return cell;
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return 176;
    } else if (indexPath.row == 1) {
        return (self.viewModel.detail && !self.viewModel.detail.needMail) ? 142 : 190;
    } else if (indexPath.row == 2) {
        NSArray *array = self.viewModel.detail.insurantLimit;
        if (array.count == 1 && [array.firstObject integerValue] != 1) {
            return 280;
        } else if (array.count == 1 && [array.firstObject integerValue] == 1) {
            return 48;
        } else {
            return self.viewModel.switchStatus ? 48 : 280;
        }
    } else if (indexPath.row == 3) {
        float height = [UIScreen mainScreen].bounds.size.height-48;
        return  self.viewModel.detail.specialAgreement.length ? (height+48+48) : (height+48);
    }
    return 44;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%@",NSStringFromCGPoint(self.tableView.contentOffset));
    CGFloat y = self.tableView.contentOffset.y;
    CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    if (y == rect.origin.y) {
        NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    }
    float cellY = self.viewModel.detail.specialAgreement.length ? rect.origin.y+48+48 : rect.origin.y+48;
    if (y>=cellY && self.contentCell) {
        self.contentCell.canScroll = YES;
    } else {
        self.contentCell.canScroll = NO;
    }
}

#pragma mark - lazy

- (MSInsuranceDetailViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[MSInsuranceDetailViewModel alloc] init];
    }
    return _viewModel;
}

- (UITableView *)tableView {

    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height-48)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.bounces = NO;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (MSInsuranceDetailHeader *)headerView {

    if (!_headerView) {
        
        _headerView = [[MSInsuranceDetailHeader alloc] init];
        @weakify(self);
        _headerView.backButtonClick = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _headerView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[MSInsuranceDetailBottomView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-48, self.view.bounds.size.width, 48)];
        @weakify(self);
        _bottomView.clickBlock = ^{
            @strongify(self);
            [self commit];
        };
    }
    return _bottomView;
}

- (void)commit {
    
    if (![[MSAppDelegate getServiceManager] isLogin]) {
        MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
        MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        return;
    }
    
    @weakify(self);
    [self.viewModel insuranceCompletion:^(BOOL status, NSString *url) {
        @strongify(self);
        if (status) {
            MSWebViewController *web = [[MSWebViewController alloc] init];
            @weakify(self);
            [web payUrl:url payCompletion:^{
                @strongify(self);
                MSPolicyDetailViewController *vc = [[MSPolicyDetailViewController alloc] init];
                [vc updateWithOrderId:self.viewModel.orderId type:MSPolicyDetailViewFromType_insuranceDetail];
                if (self.type == MSInsuranceDetailFromType_policyDetail) {
                   [self popToPush:vc index:2];
                } else {
                    [self popToPush:vc index:1];
                }
            }];
            [self.navigationController pushViewController:web animated:YES];
        } else {
           
        }
    }];

}

@end
