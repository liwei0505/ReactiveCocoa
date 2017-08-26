//
//  MSInsuranceDetailTypeCell.m
//  Sword
//
//  Created by lee on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceDetailTypeCell.h"
#import "MSInsurancePolicyDetailController.h"

@interface MSInsuranceDetailTypeCell()

@property (strong, nonatomic) MSInsuranceTypeView *typeView;
@property (strong, nonatomic) UILabel *lbTop;
@property (strong, nonatomic) UILabel *lbBottom;
@property (strong, nonatomic) UILabel *lbTopAmount;
@property (strong, nonatomic) UILabel *lbBottomAmount;
@property (assign, nonatomic) InsuranceTypeSelected type;
@property (strong, nonatomic) InsuranceProduct *pro;

@end

@implementation MSInsuranceDetailTypeCell

+ (MSInsuranceDetailTypeCell *)cellWithTableView:(UITableView *)tableView {

    NSString *reuseId = @"detailType";
    MSInsuranceDetailTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSInsuranceDetailTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.typeView = [[MSInsuranceTypeView alloc] init];
        [self.contentView addSubview:self.typeView];
        [self.typeView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.typeView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.typeView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.typeView autoSetDimension:ALDimensionHeight toSize:64];
        @weakify(self);
        self.typeView.selectBlock = ^(InsuranceTypeSelected type) {
            @strongify(self);
            self.type = type;
            InsuranceProduct *product = self.viewModel.detail.productList[type];
            [self dutyInfo:product.duties];
            self.viewModel.productId = product.productId;
            if (self.selectBlock) {
                self.selectBlock(type);
            }
        };
        
        self.lbTop = [self getDetailLabel];
        [self.contentView addSubview:self.lbTop];
        [self.lbTop autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbTop autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.typeView withOffset:9];
        
        self.lbBottom = [self getDetailLabel];
        [self.contentView addSubview:self.lbBottom];
        [self.lbBottom autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbBottom autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.typeView withOffset:32];
        
        self.lbTopAmount = [self getDetailLabel];
        [self.contentView addSubview:self.lbTopAmount];
        [self.lbTopAmount autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbTopAmount autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbTop];
        
        self.lbBottomAmount = [self getDetailLabel];
        [self.contentView addSubview:self.lbBottomAmount];
        [self.lbBottomAmount autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbBottomAmount autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbBottom];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
        [self.contentView addSubview:line];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.typeView withOffset:63];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        
        UIButton *btnDetail = [UIButton newAutoLayoutView];
        [btnDetail setTitle:@"查看担保详情" forState:UIControlStateNormal];
        btnDetail.titleLabel.font = [UIFont systemFontOfSize:12];
        [btnDetail setTitleColor:[UIColor ms_colorWithHexString:@"4229B3"] forState:UIControlStateNormal];
        [btnDetail addTarget:self action:@selector(btnDetailClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnDetail];
        [btnDetail autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line withOffset:0];
        [btnDetail autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [btnDetail autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [btnDetail autoSetDimension:ALDimensionHeight toSize:32];
        
        UIView *bottomLine = [UIView newAutoLayoutView];
        bottomLine.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
        [self.contentView addSubview:bottomLine];
        [bottomLine autoSetDimension:ALDimensionHeight toSize:8];
        [bottomLine autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [bottomLine autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [bottomLine autoPinEdgeToSuperviewEdge:ALEdgeBottom];

    }
    return self;
}

- (void)dutyInfo:(NSArray<InsuranceDuty *> *)duties {
    
    [self clear];
    
    if (!duties || duties.count == 0) {
        return;
    }
    
    InsuranceDuty *duty1 = duties[0];
    self.lbTop.text = duty1.dutyTitle;
    self.lbTopAmount.text = [duty1 getGuaranteeDesc];
    if (duties.count > 1) {
        InsuranceDuty *duty2 = duties[1];
        self.lbBottom.text = duty2.dutyTitle;
        self.lbBottomAmount.text = [duty2 getGuaranteeDesc];
    }
}

- (void)btnDetailClick {

    MSInsurancePolicyDetailController *vc = [[MSInsurancePolicyDetailController alloc] init];
    vc.dataArray = self.viewModel.detail.productList;
    vc.type = self.type;
    
    [[[MSAppDelegate getInstance] getNavigationController] pushViewController:vc animated:YES];
    
}

- (void)setDetail:(InsuranceDetail *)detail {
    _detail = detail;
    self.typeView.dataArray = _detail.productList;
    if (self.viewModel.detail.productList.count) {
        InsuranceProduct *product = self.viewModel.detail.productList[SelectedLeft];
        [self dutyInfo:product.duties];
    }
    
}

- (void)clear {
    self.lbTop.text = nil;
    self.lbTopAmount.text = nil;
    self.lbBottom.text = nil;
    self.lbBottomAmount.text = nil;
}

- (UILabel *)getDetailLabel {
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor ms_colorWithHexString:@"333333"];
    return label;
}

@end
