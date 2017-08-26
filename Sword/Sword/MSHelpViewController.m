//
//  MSHelpViewController.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSHelpViewController.h"
#import "MSAppDelegate.h"
#import "MJSNotifications.h"
#import "MSEmptyView.h"
#import "MSWebViewController.h"
#import "MSLog.h"
#import "MSRefreshHeader.h"
#import "UIView+FrameUtil.h"
#import "MSHelpFooterView.h"
#import "MSHelpCell.h"
#import "MSFeedbackController.h"

@interface MSHelpViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSHelpFooterView *footerView;

@end

@implementation MSHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configElement];
    [self addSubViews];
    [self setupRefreshHeader];
    [self setupRefreshFooter];
    [self configPageStateView];
    [self onPullToUpdateList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - tableview datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = [[MSAppDelegate getServiceManager] getHelpList].count;
    self.tableView.mj_footer.hidden = ![[MSAppDelegate getServiceManager] hasMoreHelpList];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *dataList = [[MSAppDelegate getServiceManager] getHelpList];
    MSHelpCell *cell = [MSHelpCell cellWithTableView:tableView];
    cell.info = dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NoticeInfo *info = [[MSAppDelegate getServiceManager] getHelpList][indexPath.row];
    MSWebViewController *webController = [MSWebViewController load];
    webController.title = info.title;
    webController.htmlContent = info.content;
    webController.pageId = 157;
    [self.navigationController pushViewController:webController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61.0f;
}

#pragma mark - Private
- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryHelpCenter:LIST_REQUEST_NEW];
    };
    [self.pageStateView showInView:self.tableView];
}

- (void)configElement {
    self.navigationItem.title = @"帮助反馈";
}

- (void)addSubViews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64 - 49) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    @weakify(self);
    self.footerView = [[MSHelpFooterView alloc] initWithFrame:CGRectMake(0, screenHeight - 64 - 49, self.view.width, 49)];
    self.footerView.block = ^(HELP_TYPE type) {
        @strongify(self);
        if (type == HELP_CALL) {
            [self call];
        }else {
            MSFeedbackController *feedback = [[MSFeedbackController alloc] init];
            [self.navigationController pushViewController:feedback animated:YES];
        }
    };
    [self.view addSubview:self.footerView];
}

- (void)call {
    
    NSString *telNumber = @"400-001-1111";
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,2,0}]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",telNumber]]];
    } else {
        [MSAlert showWithTitle:telNumber message:nil buttonClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self eventWithName:@"确定" elementId:90];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",telNumber]]];
            } else {
                [self eventWithName:@"取消" elementId:90];
            }
        } cancelButtonTitle:NSLocalizedString(@"str_cancel", @"") otherButtonTitles:NSLocalizedString(@"str_call", @""), nil];
    }
    
}

- (void)setupRefreshHeader {
    
    __weak typeof(self)weakSelf = self;
    MSRefreshHeader *mj_header = [MSRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf onPullToUpdateList];
    }];
    self.tableView.mj_header = mj_header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryHelpCenter:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)onPullToUpdateList {
    [self queryHelpCenter:LIST_REQUEST_NEW];
}

#pragma mark - query
- (void)queryHelpCenter:(ListRequestType)requestType{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryHelpListByType:requestType] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        
        NSInteger count = [[MSAppDelegate getServiceManager] getHelpList].count;
        if (count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        }else {
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 126;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 126;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
