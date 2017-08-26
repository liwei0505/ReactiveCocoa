//
//  MSNoticeView.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNoticeView.h"
#import "UIView+FrameUtil.h"
#import "MSPageStateView.h"
#import "MSRefreshHeader.h"
#import "MSNoticeCell.h"
#import "UIView+viewController.h"
#import "MSWebViewController.h"

@interface MSNoticeView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic)  MSPageStateView *pageStateView;

@end

@implementation MSNoticeView
#pragma mark - Life
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

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[MSAppDelegate getServiceManager] getNoticeList].count;
    self.tableView.mj_footer.hidden = ![[MSAppDelegate getServiceManager] hasMoreNoticeList];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSNoticeCell *cell = [MSNoticeCell cellWithTableView:tableView];
    cell.info = [[MSAppDelegate getServiceManager] getNoticeList][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NoticeInfo *info = [[MSAppDelegate getServiceManager] getNoticeList][indexPath.row];
    MSWebViewController *webController = [MSWebViewController load];
    webController.title = info.title;
    webController.htmlContent = info.content;
    webController.pageId = 159;
    [self.ms_viewController.navigationController pushViewController:webController animated:YES];
}

#pragma mark - Private
- (void)queryNotice:(ListRequestType)requestType{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryNoticeListByType:requestType] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        
        NSInteger count = [[MSAppDelegate getServiceManager] getNoticeList].count;
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
        [self queryNotice:LIST_REQUEST_NEW];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryNotice:LIST_REQUEST_MORE];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self configPageStateView];
    [self queryNotice:LIST_REQUEST_NEW];
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryNotice:LIST_REQUEST_NEW];
    };
    [self.pageStateView showInView:self];
}
@end
