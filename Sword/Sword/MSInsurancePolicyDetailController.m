//
//  MSInsurancePolicyDetailController.m
//  Sword
//
//  Created by lee on 2017/8/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsurancePolicyDetailController.h"
#import "MSInsurancePolicyDetailCell.h"

@interface MSInsurancePolicyDetailController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) MSInsuranceTypeView *typeView;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation MSInsurancePolicyDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepare];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.title pageId:212 params:nil];
}

- (void)prepare {
    
    self.title = @"项目保障详情";
    [self.view addSubview:self.tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    InsuranceProduct *product = self.dataArray[self.type];
    return product.duties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSInsurancePolicyDetailCell *cell = [MSInsurancePolicyDetailCell cellWithTableView:tableView];
    InsuranceProduct *product = self.dataArray[self.type];
    cell.duty = product.duties[indexPath.row];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InsuranceProduct *product = self.dataArray[self.type];
    InsuranceDuty *duty = product.duties[indexPath.row];
    CGRect rect = [duty.introduction boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
    return 88+rect.size.height;
}

- (UITableView *)tableView {

    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-73) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        MSInsuranceTypeView *typeView = [[MSInsuranceTypeView alloc] init];
        typeView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
        @weakify(self);
        typeView.selectBlock = ^(InsuranceTypeSelected type) {
            @strongify(self);
            self.type = type;
            [self.tableView reloadData];
        };
        _tableView.tableHeaderView = typeView;
        typeView.dataArray = self.dataArray;
    }
    return _tableView;
}

- (void)setDataArray:(NSArray<InsuranceProduct *> *)dataArray {
    _dataArray = dataArray;
    self.typeView.dataArray = dataArray;
}

@end
