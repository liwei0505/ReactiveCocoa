//
//  MSRiskAnswerCell.m
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRiskAnswerCell.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"

@interface MSRiskAnswerCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UIImageView *iconImageView;

@property (strong, nonatomic) UIView *containView;
@end


@implementation MSRiskAnswerCell

+ (MSRiskAnswerCell *)cellWithTableView:(UITableView *)tableView
{
    MSRiskAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSRiskAnswerCell"];
    if (!cell) {
        cell = [[MSRiskAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSRiskAnswerCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.containView = [[UIView alloc] init];
        self.containView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.containView];
        self.containView.layer.borderWidth = 0.5;
        self.containView.layer.borderColor = [UIColor ms_colorWithHexString:@"#D0D0D0"].CGColor;
        self.containView.layer.cornerRadius = 6;
        self.containView.layer.masksToBounds = YES;
        
        self.iconImageView = [[UIImageView alloc] init];
        self.iconImageView.image = [UIImage imageNamed:@"risk_unchoose_icon"];
        [self.containView addSubview:self.iconImageView];
        
        self.lbTitle = [[UILabel alloc] init];
        self.lbTitle.numberOfLines = 0;
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        self.lbTitle.font = [UIFont systemFontOfSize:15];
        [self.containView addSubview:self.lbTitle];
        
    }
    return self;
}

- (void)setRiskDetailInfo:(RiskDetailInfo *)riskDetailInfo
{
    _riskDetailInfo = riskDetailInfo;
    
    if (riskDetailInfo.isSelected) {
        self.containView.layer.borderColor = [UIColor ms_colorWithHexString:@"#FC646A"].CGColor;
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#2E2E2E"];
        self.iconImageView.image = [UIImage imageNamed:@"risk_choose_icon"];
    }else{
        self.containView.layer.borderColor = [UIColor ms_colorWithHexString:@"#D0D0D0"].CGColor;
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.iconImageView.image = [UIImage imageNamed:@"risk_unchoose_icon"];
    }
    self.lbTitle.text = riskDetailInfo.answer;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = [self.riskDetailInfo.answer boundingRectWithSize:CGSizeMake(self.width - 97, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
    
    self.containView.frame = CGRectMake(16, 0, self.width - 32, size.height + 42);
    self.iconImageView.frame = CGRectMake(15, 20, 20, 20);
    self.lbTitle.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+15, 21, self.width - 97, size.height);
    
}
@end
