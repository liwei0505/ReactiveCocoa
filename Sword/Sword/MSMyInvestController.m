//
//  MSMyInvestController.m
//  Sword
//
//  Created by haorenjie on 16/6/24.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyInvestController.h"
#import "MSLog.h"
#import "MSAppDelegate.h"
#import "MSNotificationHelper.h"
#import "MJRefresh.h"
#import "MSStoryboardLoader.h"
#import "MSInvestDetailController.h"
#import "MSMyInvestCustomCell.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "MSRefreshHeader.h"
#import "NSString+Ext.h"
#import "MSRegularEmptyView.h"
#import "MSCurrentDetailController.h"
#import "MSMainController.h"

typedef NS_ENUM(NSInteger, InvestRecordType) {
    RECORD_TYPE_RECEIVING = 10,
    RECORD_TYPE_INVESTING = 20,
    RECORD_TYPE_COMPLETED = 30,
};

@interface MSMyInvestController () <UITableViewDelegate, UITableViewDataSource>
{
    InvestRecordType _recordType;
    RACDisposable *_assetInfoSubscription;
}

@property (weak, nonatomic) IBOutlet UILabel *lbPrincipal;
@property (weak, nonatomic) IBOutlet UILabel *lbIncome;
@property (weak, nonatomic) IBOutlet UILabel *lbFroze;
@property (weak, nonatomic) IBOutlet UIButton *btnReceiving;
@property (weak, nonatomic) IBOutlet UIButton *btnInvesting;
@property (weak, nonatomic) IBOutlet UIButton *btnCompleted;
@property (weak, nonatomic) IBOutlet UIView *vSelected;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MSRegularEmptyView *empty;

@property (strong, nonatomic) AssetInfo *assetInfo;

@end

@implementation MSMyInvestController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    
    @weakify(self);
    _assetInfoSubscription = [[RACEventHandler subscribe:[AssetInfo class]] subscribeNext:^(AssetInfo *assetInfo) {
        @strongify(self);
        self.assetInfo = assetInfo;
        [self refreshAmount];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self queryMyInvestList:[self getCurrentStatus] requestType:LIST_REQUEST_NEW];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

#pragma mark - UI
- (void)prepareUI {

    self.title = NSLocalizedString(@"str_account_my_regular", nil);
    _recordType = RECORD_TYPE_INVESTING;
    
    [self.btnReceiving addTarget:self action:@selector(setButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnInvesting addTarget:self action:@selector(setButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCompleted addTarget:self action:@selector(setButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    headerView.backgroundColor = [UIColor ms_colorWithHexString:@"#F7F7F7"];
    self.tableView.tableHeaderView = headerView;
    
    __weak typeof(self)weakSelf = self;
    MSRefreshHeader *mj_header = [MSRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf queryMyInvestList:[self getCurrentStatus] requestType:LIST_REQUEST_NEW];
    }];
    self.tableView.mj_header = mj_header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf queryMyInvestList:[self getCurrentStatus] requestType:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
}

#pragma mark - table view delegate and date source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MSListWrapper *investList = [[MSAppDelegate getServiceManager] getMyInvestList:[self getCurrentStatus]];
    self.tableView.mj_footer.hidden = !investList.hasMore;
    NSUInteger itemCount = investList.count;
    if (itemCount > 0) {
        [self hideEmptyView];
    } else {
        [self showEmptyView];
    }
    return itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InvestStatus status = [self getCurrentStatus];
    NSString *reuseId = @"cell_invest";
    MSListWrapper *investList = [[MSAppDelegate getServiceManager] getMyInvestList:status];
    InvestInfo *investInfo = [investList getItemWithIndex:indexPath.row];
    MSMyInvestCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSMyInvestCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.investStatus = status;
    cell.investInfo = investInfo;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSInvestDetailController *detail = [MSStoryboardLoader loadViewController:@"invest" withIdentifier:@"invest_detail"];
    MSListWrapper *investList = [[MSAppDelegate getServiceManager] getMyInvestList:[self getCurrentStatus]];
    InvestInfo *investInfo = [investList getList][indexPath.row];
    detail.loanId = @(investInfo.loanInfo.loanId);
    [self.navigationController pushViewController:detail animated:YES];
    switch (_recordType) {
        case RECORD_TYPE_RECEIVING: {
            [self eventWithName:@"回款中记录列表" elementId:98];
            break;
        }
        case RECORD_TYPE_INVESTING: {
            [self eventWithName:@"投资中记录列表" elementId:99];
            break;
        }
        case RECORD_TYPE_COMPLETED: {
            [self eventWithName:@"已完成记录列表" elementId:100];
            break;
        }
    }

}

#pragma mark - Private

- (void)refreshAmount {

    self.lbPrincipal.text = [NSString convertMoneyFormate:self.assetInfo.regularAsset.tobeReceivedPrincipal.doubleValue+self.assetInfo.regularAsset.investFrozenAmount.doubleValue];
    self.lbIncome.text = [NSString convertMoneyFormate:self.assetInfo.regularAsset.tobeReceivedInterest.doubleValue];
    self.lbFroze.text = [NSString convertMoneyFormate:self.assetInfo.regularAsset.totalEarnings.doubleValue];
    
}

- (void)queryMyInvestList:(InvestStatus)status requestType:(ListRequestType)type {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyInvestListByType:type status:status] subscribeError:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        RACError *result = (RACError *)error;
        [MSLog error:@"Query my invest list failed: %d", result.result];
    } completed:^{
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];

        [self.tableView reloadData];
    }];
}

- (void)setButtonSelected:(UIButton *)button {
    
    if (_recordType == button.tag) {
        return;
    }
    
    _recordType = button.tag;
    
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.btnReceiving.selected = (self.btnReceiving == button);
    self.btnInvesting.selected = (self.btnInvesting == button);
    self.btnCompleted.selected = (self.btnCompleted == button);

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.vSelected.centerX = button.centerX;
    }];
    
    [self.tableView reloadData];
    
    InvestStatus status = [self getCurrentStatus];
    MSListWrapper *investList = [[MSAppDelegate getServiceManager] getMyInvestList:status];
    if (!investList) {
        [self queryMyInvestList:status requestType:LIST_REQUEST_NEW];
    }
    
    switch (_recordType) {
        case RECORD_TYPE_RECEIVING: {
            [self eventWithName:@"回款中" elementId:66];
            break;
        }
        case RECORD_TYPE_INVESTING: {
            [self eventWithName:@"投资中" elementId:67];
            break;
        }
        case RECORD_TYPE_COMPLETED: {
            [self eventWithName:@"已完成" elementId:68];
            break;
        }
    }

}

- (InvestStatus)getCurrentStatus
{
    if (_recordType == RECORD_TYPE_RECEIVING) {
        return STATUS_BACKING;
    } else if (_recordType == RECORD_TYPE_INVESTING) {
        return STATUS_FUNDRAISING;
    } else {
        return STATUS_FINISHED;
    }
}

- (void)showEmptyView {
    
    if (!self.empty) {
        self.empty = [[MSRegularEmptyView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-74-48)];
        __weak typeof(self)weakSelf = self;
        self.empty.investButtonBlock = ^{
            [weakSelf setTabbarControllerIndex:1];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        };
    }
    [self.tableView addSubview:self.empty];

}

- (void)hideEmptyView {
    if (self.empty) {
        [self.empty removeFromSuperview];
    }
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 111;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
    
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 111;
    params.title = self.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
