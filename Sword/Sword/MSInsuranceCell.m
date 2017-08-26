//
//  MSInsuranceCell.m
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceCell.h"
#import "NSString+Ext.h"

@interface MSInsuranceCell ()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbContent;
@property (strong, nonatomic) UILabel *lbStart;
@property (strong, nonatomic) UILabel *lbSoldCount;
@end

@implementation MSInsuranceCell
+ (MSInsuranceCell *)cellWithTableView:(UITableView *)tableView {
    MSInsuranceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSInsuranceCell"];
    if (!cell) {
        cell = [[MSInsuranceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSInsuranceCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    
    self.icon = [UIImageView newAutoLayoutView];
    [self.contentView addSubview:self.icon];
    [self.icon autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.icon autoSetDimensionsToSize:CGSizeMake(104, 70)];
    [self.icon autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    self.icon.image = [UIImage imageNamed:@"list_insurance_place"];
    
    self.lbTitle = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbTitle];
    [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:13];
    [self.lbTitle autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.icon withOffset:16];
    [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbTitle autoSetDimension:ALDimensionHeight toSize:20];
    self.lbTitle.font = [UIFont systemFontOfSize:14];
    self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    self.lbTitle.textAlignment = NSTextAlignmentLeft;
    
    self.lbContent = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbContent];
    [self.lbContent autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:2];
    [self.lbContent autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.icon withOffset:16];
    [self.lbContent autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbContent autoSetDimension:ALDimensionHeight toSize:34 relation:NSLayoutRelationLessThanOrEqual];
    self.lbContent.numberOfLines = 0;
    self.lbContent.font = [UIFont systemFontOfSize:12];
    self.lbContent.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbContent.textAlignment = NSTextAlignmentLeft;
    
    self.lbStart = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbStart];
    [self.lbStart autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:7];
    [self.lbStart autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.icon withOffset:16];
    [self.lbStart autoSetDimension:ALDimensionHeight toSize:24];
    self.lbStart.font = [UIFont systemFontOfSize:14];
    self.lbStart.textAlignment = NSTextAlignmentLeft;
    
    self.lbSoldCount = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbSoldCount];
    [self.lbSoldCount autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
    [self.lbSoldCount autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbSoldCount autoSetDimension:ALDimensionHeight toSize:17];
    self.lbSoldCount.font = [UIFont systemFontOfSize:12];
    self.lbSoldCount.textAlignment = NSTextAlignmentRight;
}

- (void)setInsuranceInfo:(InsuranceInfo *)insuranceInfo {
    _insuranceInfo = insuranceInfo;
    
    [self.icon sd_setImageWithURL:[NSURL URLWithString:insuranceInfo.iconUrl] placeholderImage:[UIImage imageNamed:@"list_insurance_place"] options:SDWebImageRetryFailed];
    self.lbTitle.text = insuranceInfo.title;
    self.lbContent.text = [insuranceInfo.tags componentsJoinedByString:@" | "];
    
    NSMutableAttributedString *startAmountStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@元起",insuranceInfo.startAmount.stringValue]];
    [startAmountStr addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#3F3F3F"]} range:NSMakeRange(0, startAmountStr.length)];
    [startAmountStr addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#F3091C"]} range:NSMakeRange(0, startAmountStr.length - 2)];
    self.lbStart.attributedText = startAmountStr;
    
    NSString *soldCountStr = [NSString stringWithFormat:@"%ld",(unsigned long)insuranceInfo.soldCount];
    NSString *countStr = [NSString stringWithFormat:@"已售 %@ 份",soldCountStr];
    NSMutableAttributedString *soldCountAtt = [[NSMutableAttributedString alloc] initWithString:countStr];
    [soldCountAtt addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]} range:NSMakeRange(0, countStr.length)];
    [soldCountAtt addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#4229B3"]} range:NSMakeRange(3, soldCountStr.length)];
    self.lbSoldCount.attributedText = soldCountAtt;
}

@end
