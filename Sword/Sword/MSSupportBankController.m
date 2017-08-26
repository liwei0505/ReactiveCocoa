//
//  MSSurpportBankController.m
//  Sword
//
//  Created by lee on 16/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSSupportBankController.h"
#import "UIColor+StringColor.h"
#import "MSSupportBankCell.h"
#import "BankInfo.h"

@interface MSSupportBankController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy)selectedBank block;
@property (strong, nonatomic) NSArray *supportBanksList;
@end

@implementation MSSupportBankController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self querySupportBankList:@[]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)prepareUI {
    
    self.title = NSLocalizedString(@"str_title_support_bank", @"");
    CGRect tableFrame = self.view.bounds;
    tableFrame.size.height = tableFrame.size.height - 64;
    self.tableView = [[UITableView alloc] initWithFrame: tableFrame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 64;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
}

#pragma mark - tableview datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.supportBanksList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSSupportBankCell *cell = [MSSupportBankCell cellWithTableView:tableView];
    cell.bankInfo = self.supportBanksList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BankInfo *bank = self.supportBanksList[indexPath.row];
    
    if (self.block) {
        self.block(bank.bankName,bank.bankId);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - private
- (void)querySupportBankList:(NSArray *)list{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] querySupportBankListByIds:list] subscribeNext:^(NSArray *supportBanksList) {
        @strongify(self);
        self.supportBanksList = supportBanksList;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [MSToast show:@"获取银行列表失败"];
    }];
}

- (void)seletedBankComplete:(selectedBank)block {
    self.block = block;
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 148;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
    
}

@end
