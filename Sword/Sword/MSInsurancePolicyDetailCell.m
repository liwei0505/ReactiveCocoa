//
//  MSInsurancePolicyDetailCell.m
//  Sword
//
//  Created by lee on 2017/8/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsurancePolicyDetailCell.h"

@interface MSInsurancePolicyDetailCell()

@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbDetail;
@property (strong, nonatomic) UILabel *lbContent;

@end

@implementation MSInsurancePolicyDetailCell

+ (MSInsurancePolicyDetailCell *)cellWithTableView:(UITableView *)tableView {

    NSString *reuseId = @"PolicyDetail";
    MSInsurancePolicyDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSInsurancePolicyDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        [self.contentView addSubview:view];
        [view autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [view autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [view autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [view autoSetDimension:ALDimensionHeight toSize:8];
        
        self.lbTitle = [self getLabel];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbTitle autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:view withOffset:12];
        
        self.lbDetail = [self getLabel];
        [self.contentView addSubview:self.lbDetail];
        [self.lbDetail autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbDetail autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:view withOffset:12];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        [self.contentView addSubview:line];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [line autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:55];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        
        self.lbContent = [UILabel newAutoLayoutView];
        self.lbContent.font = [UIFont systemFontOfSize:12];
        self.lbContent.numberOfLines = 0;
        self.lbContent.textColor = [UIColor ms_colorWithHexString:@"999999"];
        [self.contentView addSubview:self.lbContent];
        [self.lbContent autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbContent autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbContent autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line withOffset:14];

    }
    return self;
}

- (void)setDuty:(InsuranceDuty *)duty {
    _duty = duty;
    self.lbTitle.text = duty.dutyTitle;
    self.lbDetail.text = [duty getGuaranteeDesc];
    self.lbContent.text = duty.introduction;
}

- (UILabel *)getLabel {
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor ms_colorWithHexString:@"333333"];
    return label;
}

@end
