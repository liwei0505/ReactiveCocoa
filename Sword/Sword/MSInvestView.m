//
//  MSInvestView.m
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestView.h"
#import "MSInvestTableCell.h"
#import "MSInvestDetailController.h"
#import "MSStoryboardLoader.h"
#import "MSInvestSectionHeaderView.h"
#import "MSInvestCurrentCell.h"
#import "MSCurrentDetailController.h"
#import "UIView+viewController.h"

@interface MSInvestView()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) LoanList *investList;
@property (strong, nonatomic) MSPageStateView *pageStateView;
@end

@implementation MSInvestView

#pragma mark - life
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self setupRefreshHeader];
        [self setupRefreshFooter];
        [MSNotificationHelper addObserver:self selector:@selector(onReloadInvestList:) name:NOTIFY_INVEST_LIST_RELOAD];
    }
    return self;
}

- (void)dealloc {
    [MSNotificationHelper removeObserver:self];
    NSLog(@"%s",__func__);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self configPageStateView];
    [self queryInvestList:LIST_REQUEST_NEW];
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = self.investList.sections.count;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSNumber *sectionType = self.investList.sections[section];
    MSSectionList *list = [self.investList getSection:sectionType];
    NSInteger count = list.listWrapper.count;
    self.tableView.mj_footer.hidden = !self.investList.hasMore;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 87;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MSInvestSectionHeaderView *header = [[MSInvestSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, 32)];
    NSNumber *sectionType = self.investList.sections[section];
    MSSectionList *list = [self.investList getSection:sectionType];
    if (list.type == MSSectionListTypeWillStart) {
        [header updateImage:@"ms_will_start" title:@"马上推出"];
    } else if (list.type == MSSectionListTypeInvesting){
        [header updateImage:@"ms_investing" title:@"大家都在投"];
    }else if (list.type == MSSectionListTypeCompleted){
        [header updateImage:nil title:@"已售罄"];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *sectionType = self.investList.sections[indexPath.section];
    MSSectionList *list = [self.investList getSection:sectionType];
    MSInvestTableCell *cell = [MSInvestTableCell cellWithTableView:tableView];
    NSNumber *loanId = [list.listWrapper getItemWithIndex:indexPath.row];
    [cell updateWithLoanDetail:[[MSAppDelegate getServiceManager] getLoanInfo:loanId] type:list.type];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSNumber *sectionType = self.investList.sections[indexPath.section];
    MSSectionList *list = [self.investList getSection:sectionType];
    MSInvestDetailController *investDetailController = [MSStoryboardLoader loadViewController:@"invest" withIdentifier:@"invest_detail"];
    NSNumber *loanId = [list.listWrapper getItemWithIndex:indexPath.row];
    investDetailController.loanId = loanId;
    [self.ms_viewController.navigationController pushViewController:investDetailController animated:YES];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:loanId forKey:@"loanId"];
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:105 control:6 params:params];
}

#pragma mark - query
- (void)queryInvestList:(ListRequestType)requestType {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryLoanListByType:requestType] subscribeNext:^(LoanList *investList) {
        @strongify(self);
        self.investList = investList;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        NSInteger count = self.investList.sections.count;
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
    }];
}

#pragma mark - Notifications
- (void)onReloadInvestList:(NSNotification *)notification{
    [self queryInvestList:LIST_REQUEST_NEW];
}

#pragma mark - private
- (void)addSubviews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    [self addSubview:self.tableView];
    
    self.pageStateView = [[MSPageStateView alloc] init];
    self.pageStateView.state = MSPageStateMachineType_idle;
}

- (void)setupRefreshHeader {
    
    @weakify(self);
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryInvestList:LIST_REQUEST_NEW];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryInvestList:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryInvestList:LIST_REQUEST_NEW];
    };
    [self.pageStateView showInView:self];
}
@end
