//
//  MSMyInviteController.m
//  Sword
//
//  Created by lee on 16/7/11.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyInviteController.h"
#import "MSAppDelegate.h"
#import "MSShareManager.h"
#import "InviteCode.h"
#import "MSInviteDetailView.h"
#import "MSInviteHeader.h"
#import "UIView+FrameUtil.h"
#import "MSRefreshHeader.h"
#import "MSInviteFriendCell.h"
#import "MSWebViewController.h"

@interface MSMyInviteController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSInviteHeader *tableHeaderView;
@property (strong, nonatomic) UIButton *btnShare;
@property (strong, nonatomic) InviteCode *inviteCode;
@property (strong, nonatomic) RACDisposable *shareDisposable;
@end

@implementation MSMyInviteController

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configueElement];
    [self addSubViews];
    [self setupRefreshHeader];
    [self setupRefreshFooter];
    [self setupHeaderView];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    if (self.shareDisposable) {
        [self.shareDisposable dispose];
        self.shareDisposable = nil;
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MSListWrapper *list = [[MSAppDelegate getServiceManager] getInvitedFriendList];
    self.tableView.mj_footer.hidden = !list.hasMore;
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *friendList = [[[MSAppDelegate getServiceManager] getInvitedFriendList] getList];
    MSInviteFriendCell *cell = [MSInviteFriendCell cellWithTableView:tableView];
    [cell updateWithFriendInfo:friendList[indexPath.row] index:indexPath.row];
    return cell;
}

#pragma mark - private
- (void)configueElement {
    self.navigationItem.title = @"邀请有礼";
}

- (void)addSubViews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 52, 0);
    self.tableView.rowHeight = 68;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self.view addSubview:self.tableView];
    
    self.btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight - 64 - 44, self.view.width, 44)];
    [self.btnShare setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.btnShare setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.btnShare setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    self.btnShare.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.btnShare setTitle:@"立即邀请" forState:UIControlStateNormal];
    [self.view addSubview:self.btnShare];
    
    @weakify(self);
    [[self.btnShare rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self showQRCode];
        [self eventWithName:@"立即邀请" elementId:21];
    }];
}

- (void)showQRCode {
    self.btnShare.userInteractionEnabled = NO;
    if (self.inviteCode) {
        [self shareWithInviteCode:self.inviteCode];
        self.btnShare.userInteractionEnabled = YES;
    }else {
        [self queryShareInviteCode];
    }
}

- (void)shareWithInviteCode:(InviteCode *)inviteCode {
    NSString *title = inviteCode.title;
    NSString *urlStr = inviteCode.codeLink;
    NSString *content = inviteCode.desc;
    NSString *iconUrl = inviteCode.shareUrl;
    NSString *shareId = @"invite";
    
    [MSShareManager sharedManager].selectedShareType = ^(NSString *title) {
        [self eventWithName:title elementId:103];
    };
    [[MSShareManager sharedManager] ms_setShareUrl:urlStr shareTitle:title shareContent:content shareIcon:iconUrl shareId:shareId shareType:MSShareManager_invite];
}

- (void)setupRefreshHeader{
    @weakify(self);
    MSRefreshHeader *header =[MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryInviteInfo];
        [self queryInvitedFriendListType:LIST_REQUEST_NEW];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryInvitedFriendListType:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)setupHeaderView {
    @weakify(self);
    self.tableHeaderView = [[MSInviteHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 106)];
    self.tableHeaderView.block = ^(NSString *bannerLink) {
        @strongify(self);
        MSWebViewController *webController = [MSWebViewController load];
        webController.title = @"活动详情";
        webController.url = bannerLink;
        [self.navigationController pushViewController:webController animated:YES];
    };
    self.tableView.tableHeaderView = self.tableHeaderView;
}

#pragma mark - query
- (void)queryInviteInfo{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyInviteInfo] subscribeNext:^(InviteInfo *inviteInfo) {
        @strongify(self);
        self.tableHeaderView.inviteInfo = inviteInfo;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } error:^(NSError *error) {
        @strongify(self); 
        [MSToast show:NSLocalizedString(@"hint_alert_invitefriends_error", @"")];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
    
}

- (void)queryInvitedFriendListType:(ListRequestType)type {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyInvitedFriendListByType:type] subscribeError:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [MSToast show:NSLocalizedString(@"hint_alert_invitefriends_error", @"")];
    } completed:^{
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)queryShareInviteCode {
    @weakify(self);
    self.shareDisposable = [[[MSAppDelegate getServiceManager] queryInviteCode:SHARE_INVITE] subscribeNext:^(InviteCode *inviteCode) {
        @strongify(self);
        self.btnShare.userInteractionEnabled = YES;
        [self shareWithInviteCode:inviteCode];
        self.inviteCode = inviteCode;
    } error:^(NSError *error) {
        self.btnShare.userInteractionEnabled = YES;
        RACError *result = (RACError *)error;
        [MSLog error:@"Query share invite code failed, result: %d", result.result];
        [MSToast show:NSLocalizedString(@"hint_share_error", @"")];
    }];
}

#pragma mark - 统计
- (void)eventWithName:(NSString *)name elementId:(int)eId {
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 118;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

- (void)pageEvent {
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 118;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
    
}

@end
