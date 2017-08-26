//
//  MSInvestDetailRedEnvelopeController.m
//  Sword
//
//  Created by msj on 2017/6/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestDetailRedEnvelopeController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "MSRefreshHeader.h"
#import "MSInvestDetailRedEnvelopeCell.h"

@interface MSInvestDetailRedEnvelopeController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datas;
@end

@implementation MSInvestDetailRedEnvelopeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configElement];
    [self addSubViews];
    [self setupRefreshHeader];
    [self configPageStateView];
    [self.tableView.mj_header beginRefreshing];
}

- (void)dealloc {
    self.tableView.delegate = nil;
    NSLog(@"%s",__func__);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSInvestDetailRedEnvelopeCell *cell = [MSInvestDetailRedEnvelopeCell cellWithTableView:tableView];
    cell.redEnvelope = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    if (self.blcok) {
        @strongify(self);
        RedEnvelope *envelope = self.datas[indexPath.row];
        if (!envelope.redId) {
            self.blcok(nil);
        }else {
            self.blcok(envelope);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - query
- (void)queryAvailableRedEnvelopeList:(NSNumber *)loanId amount:(double)amount{
    LoanDetail *loanInfo = [[MSAppDelegate getServiceManager] getLoanInfo:loanId];
    NSUInteger flag = loanInfo.baseInfo.redEnvelopeTypes;
    NSDecimalNumber *investAmount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", amount]];
    
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryRedEnvelopeListForLoanId:loanId investAmount:investAmount flag:flag] subscribeNext:^(NSDictionary *dic) {
        @strongify(self);
        
        self.datas = [dic objectForKey:KEY_RED_ENVELOPE_LIST];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];

        if (self.datas.count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        } else {
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
        
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        if (result.result == ERR_LOGIN_KICK) {
            [MSToast show:result.message];
        }
        [self.tableView.mj_header endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
}

#pragma mark - Private
- (void)configElement {
    self.navigationItem.title = @"可用卡券";
}

- (void)addSubViews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)setupRefreshHeader {
    @weakify(self);
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryAvailableRedEnvelopeList:self.loanId amount:self.investAmount];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryAvailableRedEnvelopeList:self.loanId amount:self.investAmount];
    };
    [self.pageStateView showInView:self.view];
}
@end
