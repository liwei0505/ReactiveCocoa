//
//  MSCurrentDetailController.m
//  Sword
//
//  Created by msj on 2017/4/1.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentDetailController.h"
#import "UIView+FrameUtil.h"
#import "MSCurrentDetailBar.h"
#import "MSCurrentDetailHeaderView.h"
#import "MSCurrentDetailCell.h"
#import "MSRefreshHeader.h"
#import "MSLoginController.h"
#import "MSStoryboardLoader.h"
#import "MSBindCardController.h"
#import "MSWebViewController.h"
#import "MSCurrentRedeemController.h"
#import "MSCurrentInvestController.h"
#import "MSSetTradePassword.h"

@interface MSCurrentDetailController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) MSCurrentDetailHeaderView *currentDetailHeaderView;
@property (strong, nonatomic) UILabel *currentDetailFooterView;
@property (strong, nonatomic) MSCurrentDetailBar *currentDetailBar;
@property (strong, nonatomic) UIButton *btnRule;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) AssetInfo *assetInfo;
@property (strong, nonatomic) CurrentDetail *currentDetail;
@property (strong, nonatomic) AccountInfo *accountInfo;

@property (strong, nonatomic) RACDisposable *assetInfoSubscription;
@property (strong, nonatomic) RACDisposable *accountInfoSubscription;
@end

@implementation MSCurrentDetailController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configueElement];
    [self addSubViews];
    [self setupRefreshHeader];
    [self subscribe];
    [self queryCurrentDetail];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    if (self.assetInfoSubscription) {
        [self.assetInfoSubscription dispose];
        self.assetInfoSubscription = nil;
    }
    
    if (self.accountInfoSubscription) {
        [self.accountInfoSubscription dispose];
        self.accountInfoSubscription = nil;
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentDetail.productInfo.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSCurrentDetailCell *cell = [MSCurrentDetailCell cellWithTableView:tableView];
    cell.productItem = self.currentDetail.productInfo.items[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbTips = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 35)];
    lbTips.backgroundColor = [UIColor whiteColor];
    lbTips.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    lbTips.font = [UIFont systemFontOfSize:16];
    lbTips.text = @"      相关协议";
    return lbTips;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[MSAppDelegate getServiceManager] isLogin]) {
        [self login];
        return;
    }
    if (self.accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
        [self bindCard];
        return;
    }
    
    CurrentProductItem *productItem = self.currentDetail.productInfo.items[indexPath.row];
    if (![[MSAppDelegate getServiceManager] setSessionForURL:productItem.url]) {
        [MSToast show:@"网络繁忙，请稍后再试!"];
    }else {
        MSWebViewController *webVC = [MSWebViewController load];
        webVC.url = [[MSAppDelegate getServiceManager] setSessionForURL:productItem.url];
        webVC.navigationItem.title = productItem.name;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

#pragma mark - Private
- (void)configueElement {
    self.currentDetail = [[MSAppDelegate getServiceManager] getCurrent:self.currentID];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.currentDetail.baseInfo.title;
    self.btnRule = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 14)];
    self.btnRule.showsTouchWhenHighlighted = YES;
    [self.btnRule setTitle:@"规则说明" forState:UIControlStateNormal];
    self.btnRule.titleLabel.font = [UIFont systemFontOfSize:13];
    self.btnRule.hidden = YES;
    @weakify(self);
    [[self.btnRule rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        MSWebViewController *webVC = [MSWebViewController load];
        webVC.url = self.currentDetail.investRulesURL;
        webVC.navigationItem.title = @"规则说明";
        [self.navigationController pushViewController:webVC animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnRule];
}

- (void)setupRefreshHeader{
    @weakify(self);
    MSRefreshHeader *header =[MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryCurrentDetail];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)subscribe {
    @weakify(self);
    self.assetInfoSubscription = [[RACEventHandler subscribe:[AssetInfo class]] subscribeNext:^(AssetInfo *assetInfo) {
        @strongify(self);
        self.assetInfo = assetInfo;
        [self refreshHeaderViewAndBar];
    }];
    
    self.accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
    }];
}

- (void)refreshHeaderViewAndBar {
    [self.currentDetailBar updateWithAssetInfo:self.assetInfo currentDetail:self.currentDetail];
    [self.currentDetailHeaderView updateWithAssetInfo:self.assetInfo currentInfo:self.currentDetail.baseInfo currentDetail:nil];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)addSubViews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 28;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    [self.view addSubview:self.tableView];
    
    self.currentDetailHeaderView = [[MSCurrentDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 0)];
    self.tableView.tableHeaderView = self.currentDetailHeaderView ;
    
    self.currentDetailFooterView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 50)];
    self.currentDetailFooterView.font = [UIFont systemFontOfSize:12];
    self.currentDetailFooterView.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.currentDetailFooterView.textAlignment = NSTextAlignmentCenter;
    self.currentDetailFooterView.text = @"产品管理人：---";
    self.tableView.tableFooterView = self.currentDetailFooterView;
    
    [self addCurrentDetailBar];
}

- (void)addCurrentDetailBar {
    @weakify(self);
    self.currentDetailBar = [[MSCurrentDetailBar alloc] initWithFrame:CGRectMake(0, self.tableView.height - 45, self.view.width, 45)];
    self.currentDetailBar.actionBlock = ^(MSCurrentDetailBarType type){
        @strongify(self);
        if (![[MSAppDelegate getServiceManager] isLogin]) {
            [self login];
            return;
        }
        if (self.accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
            [self bindCard];
            return;
        }
        if (self.accountInfo.payStatus == STATUS_PAY_NO_PASSWORD){
            [self setTradePassword];
            return;
        }
        if (type == MSCurrentDetailBarTypeInvest) {
            
            MSCurrentInvestController *investVC = [[MSCurrentInvestController alloc] init];
            investVC.currentDetail = self.currentDetail;
            [self.navigationController pushViewController:investVC animated:YES];
            
        } else if (type == MSCurrentDetailBarTypeRedeem){
            
            MSCurrentRedeemController *redeemVC = [[MSCurrentRedeemController alloc] init];
            redeemVC.currentDetail = self.currentDetail;
            [self.navigationController pushViewController:redeemVC animated:YES];
        }
        NSLog(@"%ld",(long)type);
    };
    [self.view addSubview:self.currentDetailBar];
}

- (void)queryCurrentDetail {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryCurrentDetail:self.currentID] subscribeNext:^(CurrentDetail *currentDetail) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        self.currentDetail = currentDetail;
        [self.currentDetailBar updateWithAssetInfo:self.assetInfo currentDetail:currentDetail];
        [self.currentDetailHeaderView updateWithAssetInfo:self.assetInfo currentInfo:self.currentDetail.baseInfo currentDetail:currentDetail];
        self.currentDetailFooterView.text = [NSString stringWithFormat:@"产品管理人：%@",currentDetail.productInfo.productManager];
        self.btnRule.hidden = NO;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
        [self.tableView.mj_header endRefreshing];
        self.btnRule.hidden = YES;
    } completed:^{
        
    }];
}

- (void)login {
    MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
    MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)bindCard {
    MSBindCardController *vc = [[MSBindCardController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setTradePassword {
    MSSetTradePassword *vc = [[MSSetTradePassword alloc] init];
    vc.type = TRADE_PASSWORD_SET;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
