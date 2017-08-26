//
//  MSSupportBankCell.m
//  Sword
//
//  Created by lee on 16/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSSupportBankCell.h"
#import "UIColor+StringColor.h"
#import "UIImageView+WebCache.h"

@interface MSSupportBankCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *line;

@end

@implementation MSSupportBankCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (MSSupportBankCell *)cellWithTableView:(UITableView *)tableView {
    NSString *cellId = @"bank_cell";
    MSSupportBankCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MSSupportBankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        float margin = 16;
        self.iconView = [UIImageView newAutoLayoutView];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.iconView];
        [_iconView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:margin];
        [_iconView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_iconView autoSetDimensionsToSize:CGSizeMake(32, 32)];
        
        self.titleLabel = [UILabel newAutoLayoutView];
        self.titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
        self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.contentView addSubview:self.titleLabel];
        [_titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_iconView withOffset:margin];
        [_titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView withOffset:-10];
        
        self.detailLabel = [UILabel newAutoLayoutView];
        self.detailLabel.textColor =[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        self.detailLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:self.detailLabel];
        [_detailLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_iconView withOffset:margin];
        [_detailLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView withOffset:10];
        
        self.line = [UIView newAutoLayoutView];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
        [self.contentView addSubview:self.line];
        [_line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:margin];
        [_line autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [_line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [_line autoSetDimension:ALDimensionHeight toSize:1];
    }
    return self;
}

- (void)setBankInfo:(BankInfo *)bankInfo {

    _bankInfo = bankInfo;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:_bankInfo.bankUrl] placeholderImage:[UIImage imageNamed:@"bank_icon_placeholder"] options:SDWebImageAllowInvalidSSLCertificates];//SDWebImageAllowInvalidSSLCertificates
    [self.titleLabel setText:_bankInfo.bankName];
    NSString *detail = nil;
    if (_bankInfo.singleLimit > 0) {
        if (_bankInfo.singleLimit >= 10000) {
            int value = (int)(_bankInfo.singleLimit/1000) % 10;
            if (value) {
                detail = [NSString stringWithFormat:@"单笔限额%.1f万",_bankInfo.singleLimit/10000];
            } else {
                detail = [NSString stringWithFormat:@"单笔限额%.0f万",_bankInfo.singleLimit/10000];
            }
        } else {
            detail = [NSString stringWithFormat:@"单笔限额%.0f",_bankInfo.singleLimit];
        }
    }
    if (_bankInfo.dayLimit > 0) {
        if (detail) {
            if (_bankInfo.dayLimit >= 10000) {
                int value = (int)(_bankInfo.dayLimit/1000) % 10;
                if (value) {
                    detail = [detail stringByAppendingString:[NSString stringWithFormat:@",日限额%.1f万",_bankInfo.dayLimit/10000]];
                } else {
                    detail = [detail stringByAppendingString:[NSString stringWithFormat:@",日限额%.0f万",_bankInfo.dayLimit/10000]];
                }
            } else {
                detail = [detail stringByAppendingString:[NSString stringWithFormat:@",日限额%.0f",_bankInfo.dayLimit]];
            }
        } else {
            if (_bankInfo.dayLimit >= 10000) {
                int value = (int)(_bankInfo.dayLimit/1000) % 10;
                if (value) {
                    detail = [NSString stringWithFormat:@"日限额%.1f万",_bankInfo.dayLimit/10000];
                } else {
                    detail = [NSString stringWithFormat:@"日限额%.0f万",_bankInfo.dayLimit/10000];
                }
            } else {
                detail = [NSString stringWithFormat:@"日限额%.0f",_bankInfo.dayLimit];
            }
        }
    }
    if (_bankInfo.monthLimit > 0) {
        if (detail) {
            if (_bankInfo.monthLimit >= 10000) {
                int value = (int)(_bankInfo.monthLimit/1000) % 10;
                if (value) {
                    detail = [detail stringByAppendingString:[NSString stringWithFormat:@",月限额%.1f万",_bankInfo.monthLimit/10000]];
                } else {
                    detail = [detail stringByAppendingString:[NSString stringWithFormat:@",月限额%.0f万",_bankInfo.monthLimit/10000]];
                }
            } else {
                detail = [detail stringByAppendingString:[NSString stringWithFormat:@",月限额%.0f",_bankInfo.monthLimit]];
            }
        } else {
            if (_bankInfo.monthLimit >= 10000) {
                int value = (int)(_bankInfo.monthLimit/1000) % 10;
                if (value) {
                    detail = [NSString stringWithFormat:@"月限额%.1f万",_bankInfo.monthLimit/10000];
                } else {
                    detail = [NSString stringWithFormat:@"月限额%.0f万",_bankInfo.monthLimit/10000];
                }
            } else {
                detail = [NSString stringWithFormat:@"月限额%.0f",_bankInfo.monthLimit];
            }
        }
    }
    [self.detailLabel setText:detail];
}

@end
