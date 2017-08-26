//
//  MSMessageView.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSMessageView.h"
#import "UIView+FrameUtil.h"
#import "MSPageStateView.h"
#import "MSRefreshHeader.h"
#import "MSMessageCell.h"
#import "MSPageStateView.h"
#import "UIView+viewController.h"
#import "MSWebViewController.h"

@interface MSMessageView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSPageStateView *pageStateView;
@end

@implementation MSMessageView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
        [self setupRefreshHeader];
        [self setupRefreshFooter];
    }
    return self;
}

#pragma mark - tableview datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[MSAppDelegate getServiceManager] getMessageList].count;
    self.tableView.mj_footer.hidden = ![[MSAppDelegate getServiceManager] hasMoreMessageList];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MSMessageCell *messageCell = [MSMessageCell cellWithTableView:tableView];
    NSArray *list = [[MSAppDelegate getServiceManager] getMessageList];
    messageCell.message = list[indexPath.row];
    return messageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageInfo *info = [[MSAppDelegate getServiceManager] getMessageList][indexPath.row];
    MSWebViewController *webController = [MSWebViewController load];
    webController.title = info.type;
    webController.htmlContent = info.content;
    webController.pageId = 158;
    [self.ms_viewController.navigationController pushViewController:webController animated:YES];
    if (0 == info.status) {
        [self sendReadMessageId:info.messageId];
    }
    [self eventWithName:@"消息列表" elementId:105 msgId:[NSNumber numberWithInt:info.messageId]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self messageDelete:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"str_delete", @"");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - query
- (void)queryMessageList:(ListRequestType)requestType{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMessageListByType:requestType] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        NSInteger count = [[MSAppDelegate getServiceManager] getMessageList].count;
        if (count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        }else {
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
}

- (void)sendReadMessageId:(int)messageId{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] readMessageWithId:@(messageId)] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)messageDelete:(NSInteger)index {
    @weakify(self);
    MessageInfo *info = [[MSAppDelegate getServiceManager] getMessageList][index];
    [[[MSAppDelegate getServiceManager] deleteMessageWithId:@(info.messageId)] subscribeNext:^(id x) {
        @strongify(self);
        
        NSInteger count = [[MSAppDelegate getServiceManager] getMessageList].count;
        if (count == 0) {
            [self configPageStateView];
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
    } completed:^{
        
    }];
}

#pragma mark - Private
- (void)addSubViews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self addSubview:self.tableView];
    
    self.pageStateView = [[MSPageStateView alloc] init];
    self.pageStateView.state = MSPageStateMachineType_idle;
}

- (void)setupRefreshHeader {
    
    @weakify(self);
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryMessageList:LIST_REQUEST_NEW];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryMessageList:LIST_REQUEST_MORE];

    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self configPageStateView];
    [self queryMessageList:LIST_REQUEST_NEW];
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryMessageList:LIST_REQUEST_NEW];
    };
    [self.pageStateView showInView:self];
}

#pragma mark - 统计
- (void)eventWithName:(NSString *)name elementId:(int)eId msgId:(NSNumber *)msgId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 128;
    params.title = self.ms_viewController.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    if (msgId) {
        NSDictionary *dic = @{@"msg_id":msgId};
        params.params = dic;
    }
    [MJSStatistics sendEventParams:params];
}
@end
