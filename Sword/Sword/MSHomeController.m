//
//  MSHomeController.m
//  Sword
//
//  Created by lee on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSHomeController.h"
#import "MSNetworkMonitor.h"
#import "MSNetworkStatus.h"
#import "MSRecommendCell.h"
#import "MSInvestDetailController.h"
#import "MSStoryboardLoader.h"
#import "MSConfig.h"
#import "MSRefreshHeader.h"
#import "MSHomeHeaderView.h"
#import "UIView+FrameUtil.h"
#import "MSVersionUtils.h"
#import "MSWebViewController.h"
#import "MSHomeFooterView.h"
#import "MSLoginController.h"
#import "MSRiskHomeViewController.h"
#import "MSRiskResultViewController.h"
#import "MSInsuranceDetailController.h"
#import "BannerInfo.h"
#import "MSNewNoviceCell.h"
#import "MSInsuranceCell.h"
#import "MSHomeSectionView.h"
#import "MSCurrentDetailController.h"
#import "MSNavigationView.h"
#import "MSUserInfoController.h"
#import "MSMessageController.h"

@interface MSHomeController () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSHomeHeaderView *tableHeaderView;
@property (strong, nonatomic) MSHomeFooterView *tableFooterView;
@property (strong, nonatomic) MSNavigationView *navView;

//保险list
@property (strong, nonatomic) MSSectionList *insuranceList;
//定期list
@property (strong, nonatomic) LoanList *recommendedList;

@property (strong, nonatomic) NSArray *datas;
@end

@implementation MSHomeController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configElement];
    [self addSubViews];
    [self setupHeaderView];
    [self setupFooterView];
    [self setupRefreshHeader];
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.tabBarController.selectedIndex == 0) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }

    if ([[MSNetworkMonitor sharedInstance] isNetworkAvailable]) {
        if ([[MSAppDelegate getServiceManager] isShouldQueryBannerList]) {
            [self queryBannerList];
        }
        
        if (!self.recommendedList || [self.recommendedList shouldRefresh]) {
            [self queryRecommendedList];
        }
        
        if (self.insuranceList.listWrapper.count == 0) {
            [self queryInsuranceList];
        }
        
        if ([[MSAppDelegate getServiceManager] isLogin]) {
            [self queryUnreadMessageCount];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.tabBarController.selectedIndex == 0) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    [MSNotificationHelper removeObserver:self];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MSSectionList *list = self.datas[section];
    if (list.type == MSSectionListTypeNewer) {
        return 1;
    }
    return list.listWrapper.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSSectionList *list = self.datas[indexPath.section];
    if (list.type == MSSectionListTypeNewer){
        return 226.0;
    } else if (list.type == MSSectionListTypeInsurance) {
        return 98.0;
    }
    return 87.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSSectionList *list = self.datas[indexPath.section];
    if (list.type == MSSectionListTypeNewer) {
        MSNewNoviceCell *cell = [MSNewNoviceCell cellWithTableView:tableView];
        @weakify(self);
        cell.block = ^(NSNumber *loanId) {
            @strongify(self);
            MSInvestDetailController *viewController = [MSStoryboardLoader loadViewController:@"invest" withIdentifier:@"invest_detail"];
            viewController.loanId = loanId;
            [self.navigationController pushViewController:viewController animated:YES];
        };
        cell.list = list;
        return cell;
    } else if (list.type == MSSectionListTypeInsurance) {
        MSInsuranceCell *cell = [MSInsuranceCell cellWithTableView:tableView];
        InsuranceInfo *insuranceInfo = [list.listWrapper getItemWithIndex:indexPath.row];
        cell.insuranceInfo = insuranceInfo;
        return cell;
    } else if (list.type == MSSectionListTypeWillStart ||
              list.type == MSSectionListTypeInvesting ||
              list.type == MSSectionListTypeCompleted) {
        MSRecommendCell *cell = [MSRecommendCell cellWithTableView:tableView];
        NSNumber *loanId = [list.listWrapper getItemWithIndex:indexPath.row];
        cell.loanDetail = [[MSAppDelegate getServiceManager] getLoanInfo:loanId];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MSSectionList *list = self.datas[indexPath.section];
    if (list.type == MSSectionListTypeInvesting
        || list.type == MSSectionListTypeWillStart
        || list.type == MSSectionListTypeCompleted){
        
        MSInvestDetailController *viewController = [MSStoryboardLoader loadViewController:@"invest" withIdentifier:@"invest_detail"];
        NSNumber *loanId = [list.listWrapper getItemWithIndex:indexPath.row];
        viewController.loanId = loanId;
        [self.navigationController pushViewController:viewController animated:YES];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:loanId forKey:@"loanId"];
        [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:104 control:1 params:params];
        [self eventWithName:@"推荐列表" elementId:1 LoanId:loanId];
        
    } else if (list.type == MSSectionListTypeInsurance) {
        InsuranceInfo *insuranceInfo = [list.listWrapper getItemWithIndex:indexPath.row];
        MSInsuranceDetailController *vc = [[MSInsuranceDetailController alloc] init];
        vc.type = MSInsuranceDetailFromType_home;
        vc.insuranceId = insuranceInfo.insuranceId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MSSectionList *list = self.datas[section];
    if (list.type == MSSectionListTypeNewer) {
        return nil;
    }
    MSHomeSectionView *sectionView = [[MSHomeSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
    sectionView.type = list.type;
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    MSSectionList *list = self.datas[section];
    if (list.type == MSSectionListTypeNewer) {
        return 0;
    }
    return 60;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y <= 0) {
        self.navView.backgroundColorAlpha = 0;
        [self.tableHeaderView addSubview:self.navView];
    } else {
        self.navView.backgroundColorAlpha = scrollView.contentOffset.y / 150;
        [self.view addSubview:self.navView];
    }
}

#pragma mark - Notifications
- (void)onNetworkStatusChanged:(NSNotification *)notification {
    
    NSNumber *value = notification.object;
    if (!value) {
        return;
    }
    
    NSInteger status = value.integerValue;
    if (status == MSNetworkNotReachable || status == MSNetworkUnknown) {
        return;
    }
    
    if ([[MSAppDelegate getServiceManager] isShouldQueryBannerList]) {
        [self queryBannerList];
    }
    
    if (!self.recommendedList || [self.recommendedList shouldRefresh]) {
        [self queryRecommendedList];
    }
    
    if (self.insuranceList.listWrapper.count == 0) {
        [self queryInsuranceList];
    }
    
    if ([[MSAppDelegate getServiceManager] isLogin]) {
        [self queryUnreadMessageCount];
    }

    UpdateInfo *info = [[MSAppDelegate getServiceManager] getUpdateInfo];
    if (!info) {
        [self checkVersion];
    }
}

- (void)onInvestListReload {
    [self queryRecommendedList];
}

- (void)onReloadInveranceList {
    [self queryInsuranceList];
}

#pragma mark - query
- (void)checkVersion {
    
    [[[MSAppDelegate getServiceManager] checkUpdate] subscribeNext:^(UpdateInfo *versionUpdate) {
        [MSVersionUtils updateVersion:versionUpdate];
    } error:^(NSError *error) {
        NSLog(@"获取更新信息失败");
    }];
}

- (void)queryBannerList {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryBannerList] subscribeNext:^(NSArray *bannerList) {
        @strongify(self);
        self.tableHeaderView.bannerList = bannerList;
    } error:^(NSError *error) {
    }];
}

- (void)queryInsuranceList {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryInsuranceRecommendedList] subscribeNext:^(MSSectionList *insuranceList) {
        @strongify(self);
        self.insuranceList = insuranceList;
        [self.tableView.mj_header endRefreshing];
        [self initData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)queryRecommendedList {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryRecommendedList] subscribeNext:^(LoanList *loanList) {
        @strongify(self);
        self.recommendedList = loanList;
        [self.tableView.mj_header endRefreshing];
        [self initData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
    }];
    
}

- (void)queryUnreadMessageCount {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryUnreadMessageCount] subscribeNext:^(NSNumber *unreadMessageCount) {
        @strongify(self);
        self.navView.unReadCount = unreadMessageCount.integerValue;
    } error:^(NSError *error) {
    }];
}

#pragma mark - private
- (void)configElement {
    self.view.backgroundColor = [UIColor colorWithRed:248.0/256.0 green:248.0/256.0 blue:248.0/256.0 alpha:1];
    [MSNotificationHelper addObserver:self selector:@selector(onNetworkStatusChanged:) name:NOTIFY_NETWORK_STATUS_CHANGED];
    [MSNotificationHelper addObserver:self selector:@selector(onInvestListReload) name:NOTIFY_INVEST_LIST_RELOAD];
    [MSNotificationHelper addObserver:self selector:@selector(onReloadInveranceList) name:NOTIFY_INVERANCE_LIST_RELOAD];
}

- (void)addSubViews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 49) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self.view addSubview:self.tableView];
    
    @weakify(self);
    self.navView = [[MSNavigationView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    self.navView.actionBlock = ^(NavigationType type) {
        @strongify(self);
        
        if (![[MSAppDelegate getServiceManager] isLogin]) {
            MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
            MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            return ;
        }
        
        if (type == NavigationType_Mine) {
            MSUserInfoController *info = [[MSUserInfoController alloc] init];
            [self.navigationController pushViewController:info animated:YES];
        } else {
            MSMessageController *message = [[MSMessageController alloc] init];
            [self.navigationController pushViewController:message animated:YES];
        }
    };
    [self.view addSubview:self.navView];
}

- (void)setupHeaderView {
    @weakify(self);
    self.tableHeaderView = [[MSHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,self.view.width * 140.0 / 375.0)];
    self.tableHeaderView.block = ^(NSInteger index, BannerInfo *banner){
        @strongify(self);
        NSLog(@"%ld, %@, %@",(long)index,banner.bannerUrl, banner.link);
        if (banner.link) {
            [self eventWithName:banner.bannerUrl elementId:47 LoanId:nil];
            MSWebViewController *webViewController = [MSWebViewController load];
            webViewController.url = banner.link;
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    };
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)setupFooterView {
    self.tableFooterView = [[MSHomeFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
    self.tableView.tableFooterView = self.tableFooterView;
}

- (void)setupRefreshHeader {
    @weakify(self);
    MSRefreshHeader *header =[MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self updateList];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)updateList {
    [self queryBannerList];
    [self queryRecommendedList];
    [self queryInsuranceList];
    if ([[MSAppDelegate getServiceManager] isLogin]) {
        [self queryUnreadMessageCount];
    }
}

- (void)initData {
    
    BOOL hasInsuranceList = self.insuranceList && self.insuranceList.listWrapper && self.insuranceList.listWrapper.count > 0;
    BOOL hasRecommendedList = self.recommendedList.sections && self.recommendedList.sections.count > 0;
    
    NSMutableArray *array = [NSMutableArray array];
    if (hasInsuranceList && hasRecommendedList) {
        [array addObjectsFromArray:[self.recommendedList getAllSectionLists]];
        MSSectionList *list = array.firstObject;
        if (list.type == MSSectionListTypeNewer) {
            [array insertObject:self.insuranceList atIndex:1];
        } else {
            [array insertObject:self.insuranceList atIndex:0];
        }
    } else if (hasRecommendedList && !hasInsuranceList) {
        [array addObjectsFromArray:[self.recommendedList getAllSectionLists]];
    } else if (!hasRecommendedList && hasInsuranceList) {
        [array addObject:self.insuranceList];
    }
    self.datas = array;
    [self.tableView reloadData];
}

#pragma mark - 统计
- (void)pageEvent {
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 104;
    params.title = @"首页";
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId LoanId:(NSNumber *)loanId {
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 104;
    params.title = @"首页";
    params.elementId = eId;
    params.elementText = name;
    if (loanId) {
        NSDictionary *dic = @{@"loan_id":loanId};
        params.params = dic;
    }
    [MJSStatistics sendEventParams:params];
}

@end
