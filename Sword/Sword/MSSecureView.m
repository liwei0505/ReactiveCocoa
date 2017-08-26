//
//  MSSecureView.m
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSSecureView.h"
#import "MSInvestSectionHeaderView.h"
#import "MSInsuranceDetailController.h"
#import "MSInsuranceCell.h"
#import "InsuranceSection.h"
#import "UIView+viewController.h"


@interface MSSecureView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSPageStateView *pageStateView;
@property (strong, nonatomic) NSMutableArray *datas;
@end

@implementation MSSecureView

#pragma mark - life
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self setupRefreshHeader];
        [self configPageStateView];
        [self queryInranceList];
        [MSNotificationHelper addObserver:self selector:@selector(onReloadInveranceList) name:NOTIFY_INVERANCE_LIST_RELOAD];
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
    [self queryInranceList];
}

- (void)initDatas {
    
    self.datas = [NSMutableArray array];
    
    {
        InsuranceSection *insuranceSection = [InsuranceSection new];
        insuranceSection.sectionName = @"医疗保险";
        
        InsuranceInfo *model = [InsuranceInfo new];
        model.title = @"恋爱保险";
        model.iconUrl = nil;
        model.tags = @[@"恋爱有保障", @"结婚送大礼", @"低保费", @"高保障", @"涵盖主流", @"低保费", @"高保障", @"涵盖主流"];
        model.startAmount = [NSDecimalNumber decimalNumberWithString:@"66.88"];
        model.soldCount = 1000;
        
        InsuranceInfo *model2 = [InsuranceInfo new];
        model2.title = @"恋爱保险";
        model2.iconUrl = nil;
        model2.tags = @[@"恋爱有保障"];
        model2.startAmount = [NSDecimalNumber decimalNumberWithString:@"66.88"];
        model2.soldCount = 1000;
        
        [insuranceSection.insuranceList addObject:model];
        [insuranceSection.insuranceList addObject:model2];
        
        [self.datas addObject:insuranceSection];
    }
    
    {
        InsuranceSection *insuranceSection = [InsuranceSection new];
        insuranceSection.sectionName = @"恋爱保险";
        
        InsuranceInfo *model = [InsuranceInfo new];
        model.title = @"恋爱保险";
        model.iconUrl = nil;
        model.tags = @[@"恋爱有保障", @"结婚送大礼", @"低保费", @"高保障", @"涵盖主流", @"低保费", @"高保障", @"涵盖主流"];
        model.startAmount = [NSDecimalNumber decimalNumberWithString:@"66.88"];
        model.soldCount = 1000;
        
        [insuranceSection.insuranceList addObject:model];
        
        [self.datas addObject:insuranceSection];
    }
    
    {
        InsuranceSection *insuranceSection = [InsuranceSection new];
        insuranceSection.sectionName = @"汽车保险";
        
        InsuranceInfo *model = [InsuranceInfo new];
        model.title = @"恋爱保险";
        model.iconUrl = nil;
        model.tags = @[@"恋爱有保障", @"最高50万医疗保障", @"综合意外保障"];
        model.startAmount = [NSDecimalNumber decimalNumberWithString:@"66.88"];
        model.soldCount = 1000;
        
        [insuranceSection.insuranceList addObject:model];
        
        [self.datas addObject:insuranceSection];
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    InsuranceSection *sectionList = self.datas[section];
    return sectionList.insuranceList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    InsuranceSection *sectionList = self.datas[section];
    MSInvestSectionHeaderView *header = [[MSInvestSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, 32)];
    [header updateImage:nil title:sectionList.sectionName];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InsuranceSection *sectionList = self.datas[indexPath.section];
    MSInsuranceCell *cell = [MSInsuranceCell cellWithTableView:tableView];
    cell.insuranceInfo = sectionList.insuranceList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InsuranceSection *sectionList = self.datas[indexPath.section];
    InsuranceInfo *insuranceInfo = sectionList.insuranceList[indexPath.row];
    
    MSInsuranceDetailController *vc = [[MSInsuranceDetailController alloc] init];
    vc.type = MSInsuranceDetailFromType_invest;
    vc.insuranceId = insuranceInfo.insuranceId;
    [self.ms_viewController.navigationController pushViewController:vc animated:YES];

}

#pragma mark - Notification
- (void)onReloadInveranceList {
    [self queryInranceList];
}

#pragma mark - query 
- (void)queryInranceList {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryInsuranceSectionList] subscribeNext:^(NSMutableArray *sectionList) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        self.datas = sectionList;
        [self.tableView reloadData];
        if (sectionList.count > 0) {
            self.pageStateView.state = MSPageStateMachineType_loaded;
        } else {
            self.pageStateView.state = MSPageStateMachineType_empty;
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
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
        [self queryInranceList];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryInranceList];
    };
    [self.pageStateView showInView:self];
}
@end
