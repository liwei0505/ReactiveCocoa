//
//  MSRiskCollectionViewCell.m
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRiskCollectionViewCell.h"
#import "UIView+FrameUtil.h"
#import "MSRiskAnswerCell.h"
#import "MSRiskAnswerHeaderView.h"
#import "UIColor+StringColor.h"
#import "UIImage+color.h"

#define screenWidth  [UIScreen mainScreen].bounds.size.width

@interface MSRiskCollectionViewCell ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSRiskAnswerHeaderView *headerView;
@property (strong, nonatomic) UIButton *btnCompeleted;

@property (strong, nonatomic) RiskInfo *riskInfo;
@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) NSMutableArray *riskInfoArr;

@end

@implementation MSRiskCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor ms_colorWithHexString:@"EEEEEE"];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        [self.contentView addSubview:self.tableView];
        
        self.headerView = [[MSRiskAnswerHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        
        self.btnCompeleted = [[UIButton alloc] initWithFrame:CGRectMake(0, self.height - 50, self.width, 50)];
        self.btnCompeleted.hidden = YES;
        [self.btnCompeleted setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
        [self.btnCompeleted setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
        [self.btnCompeleted setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
        self.btnCompeleted.enabled = NO;
        [self.btnCompeleted setTitle:@"完成" forState:UIControlStateNormal];
        [self.btnCompeleted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnCompeleted addTarget:self action:@selector(compeleted:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnCompeleted];
        
    }
    return self;
}

- (void)update:(RiskInfo *)riskInfo index:(NSInteger)index riskInfoArr:(NSMutableArray *)riskInfoArr
{
    self.riskInfo = riskInfo;
    self.index = index;
    self.riskInfoArr = riskInfoArr;
    
    CGFloat headerHeight = [self.headerView updateRiskInfo:riskInfo];
    self.headerView.height = headerHeight;
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView reloadData];
    
    self.btnCompeleted.hidden = (index < riskInfoArr.count-1);
    [self judgeCompeletedButtonCanClick];
}

- (void)judgeCompeletedButtonCanClick
{
    if (!self.btnCompeleted.hidden) {
        self.btnCompeleted.enabled = YES;
        for (RiskInfo *info in self.riskInfoArr) {
            if (!info.isCompeleted) {
                self.btnCompeleted.enabled = NO;
                break;
            }
        }
    }
}

- (void)compeleted:(UIButton *)btn
{
    if (self.compeleted) {
        self.compeleted();
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.riskInfo.riskDetailInfoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSRiskAnswerCell *cell = [MSRiskAnswerCell cellWithTableView:tableView];
    cell.riskDetailInfo = self.riskInfo.riskDetailInfoArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RiskDetailInfo *info = self.riskInfo.riskDetailInfoArr[indexPath.item];
    CGSize size = [info.answer boundingRectWithSize:CGSizeMake(self.width - 97, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
    
    return size.height + 42 + 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.riskInfo.isCompeleted = YES;
    for(int i = 0; i < self.riskInfo.riskDetailInfoArr.count; i++){
        RiskDetailInfo *info = self.riskInfo.riskDetailInfoArr[i];
        if (i == indexPath.row) {
            info.isSelected = YES;
            self.riskInfo.answerId = info.answerId;
        }else{
            info.isSelected = NO;
        }
    }
    [self.tableView reloadData];
    
    [self judgeCompeletedButtonCanClick];
    
    if (self.selectedCallBlcok) {
        self.selectedCallBlcok(self.index);
    }
}

@end
