//
//  MSPolicyDetailCell.m
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPolicyDetailCell.h"

@interface MSPolicyDetailCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbSubTitle;
@property (strong, nonatomic) UIView *line;
@property (strong, nonatomic) UIImageView *arrow;
@end

@implementation MSPolicyDetailCell
+ (MSPolicyDetailCell *)cellWithTableView:(UITableView *)tableView {
    MSPolicyDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSPolicyDetailCell"];
    if (!cell) {
        cell = [[MSPolicyDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSPolicyDetailCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.lbTitle = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbTitle];
    [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    self.lbTitle.font = [UIFont systemFontOfSize:14];
    self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    self.lbTitle.textAlignment = NSTextAlignmentLeft;
    
    self.lbSubTitle = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbSubTitle];
    [self.lbSubTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbSubTitle autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.lbSubTitle autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    self.lbSubTitle.font = [UIFont systemFontOfSize:14];
    self.lbSubTitle.textAlignment = NSTextAlignmentRight;
    
    self.line = [UIView newAutoLayoutView];
    self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [self.contentView addSubview:self.line];
    [self.line autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 16, 0, 0) excludingEdge:ALEdgeTop];
    [self.line autoSetDimension:ALDimensionHeight toSize:1];
    
    self.arrow = [UIImageView newAutoLayoutView];
    self.arrow.image = [UIImage imageNamed:@"right_arrow"];
    [self.contentView addSubview:self.arrow];
    [self.arrow autoSetDimensionsToSize:CGSizeMake(12, 12)];
    [self.arrow autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.arrow autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
}

- (void)setModel:(MSPolicyDetailModel *)model {
    
    self.lbTitle.text = model.title;
    self.line.hidden = model.isHideLine;
    
    NSMutableAttributedString *attributedText;
    if (model.subTitle && model.subTitle.length > 0) {
        attributedText = [[NSMutableAttributedString alloc] initWithString:model.subTitle];
        [attributedText addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#333333"]} range:NSMakeRange(0, model.subTitle.length)];
    }
    
    switch (model.type) {
        case MSPolicyDetailModel_insurer:
        {
            self.arrow.hidden = YES;
            self.lbSubTitle.hidden = NO;
            self.lbSubTitle.attributedText = attributedText;
            break;
        }
        case MSPolicyDetailModel_insurant:
        {
            self.arrow.hidden = YES;
            self.lbSubTitle.hidden = NO;
            self.lbSubTitle.attributedText = attributedText;
            break;
        }
        case MSPolicyDetailModel_startDate:
        {
            self.arrow.hidden = YES;
            self.lbSubTitle.hidden = NO;
            self.lbSubTitle.attributedText = attributedText;
            break;
        }
        case MSPolicyDetailModel_endDate:
        {
            self.arrow.hidden = YES;
            self.lbSubTitle.hidden = NO;
            self.lbSubTitle.attributedText = attributedText;
            break;
        }
        case MSPolicyDetailModel_productDetail:
        {
            self.arrow.hidden = NO;
            self.lbSubTitle.hidden = YES;
            break;
        }
        case MSPolicyDetailModel_electronicPolicy:
        {
            self.arrow.hidden = NO;
            self.lbSubTitle.hidden = YES;
            break;
        }
        case MSPolicyDetailModel_serviceTel:
        {
            self.arrow.hidden = YES;
            self.lbSubTitle.hidden = NO;
            [attributedText addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#4229B3"]} range:NSMakeRange(0, model.subTitle.length)];
            self.lbSubTitle.attributedText = attributedText;
            break;
        }
        case MSPolicyDetailModel_premium:
        {
            self.arrow.hidden = YES;
            self.lbSubTitle.hidden = NO;
            [attributedText addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#F3091C"]} range:NSMakeRange(0, model.subTitle.length - 1)];
            self.lbSubTitle.attributedText = attributedText;
            break;
        }
        default:
            break;
    }
}
@end
