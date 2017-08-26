//
//  MSRedEnvelopeView.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSRedEnvelopeView.h"
#import "MSRedEnvelopeCell.h"
#import "UIView+FrameUtil.h"
#import "MSPageStateView.h"
#import "MSRefreshHeader.h"

@interface MSRedEnvelopeView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic)  MSPageStateView *pageStateView;
@property (strong, nonatomic) MSListWrapper *redEnvelopeList;
@end

@implementation MSRedEnvelopeView

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
    self.tableView.mj_footer.hidden = !self.redEnvelopeList.hasMore;
    return self.redEnvelopeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSRedEnvelopeCell *cell = [MSRedEnvelopeCell cellWithTableView:tableView];
    [cell updateWithRedEnvelope:[self.redEnvelopeList getList][indexPath.row] status:self.status];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

#pragma mark - Private
- (void)queryMyRedEnvelopeList:(ListRequestType)requestType status:(RedEnvelopeStatus)status{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyRedEnvelopeListByType:requestType status:status] subscribeNext:^(NSDictionary *dic) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.redEnvelopeList = [[MSAppDelegate getServiceManager] getRedEnvelopeList:status];
        if (self.redEnvelopeList.count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        }else {
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        self.pageStateView.state = MSPageStateMachineType_error;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - Private
- (void)addSubViews {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self addSubview:self.tableView];
    
    self.pageStateView = [[MSPageStateView alloc] init];
    self.pageStateView.state = MSPageStateMachineType_idle;
}

- (void)setupRefreshHeader {
    
    @weakify(self);
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryMyRedEnvelopeList:LIST_REQUEST_NEW status:self.status];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter {
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self queryMyRedEnvelopeList:LIST_REQUEST_MORE status:self.status];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self configPageStateView];
    [self queryMyRedEnvelopeList:LIST_REQUEST_NEW status:self.status];
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryMyRedEnvelopeList:LIST_REQUEST_NEW status:self.status];
    };
    [self.pageStateView showInView:self];
}
@end
