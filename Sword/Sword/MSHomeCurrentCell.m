//
//  MSHomeCurrentCell.m
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSHomeCurrentCell.h"
#import "UIImage+color.h"

@interface MSHomeCurrentCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbInterestRate;
@property (strong, nonatomic) UILabel *lbInterestRateDescription;
@property (strong, nonatomic) UILabel *lbTermUnit;
@property (strong, nonatomic) UILabel *lbTermUnitTips;
@property (strong, nonatomic) UIButton *btnInvest;
@end

@implementation MSHomeCurrentCell
+ (MSHomeCurrentCell *)cellWithTableView:(UITableView *)tableView
{
    MSHomeCurrentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSHomeCurrentCell"];
    if (!cell) {
        cell = [[MSHomeCurrentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSHomeCurrentCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 80) / 2.0;
        
        UIView *bgView = [UIView newAutoLayoutView];
        bgView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
        [self.contentView addSubview:bgView];
        [bgView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [bgView autoSetDimension:ALDimensionHeight toSize:10];
        
        UIImageView *imageViewTips = [UIImageView newAutoLayoutView];
        imageViewTips.image = [UIImage imageNamed:@"home_current_tip"];
        [self.contentView addSubview:imageViewTips];
        [imageViewTips autoSetDimensionsToSize:CGSizeMake(66, 24)];
        [imageViewTips autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [imageViewTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:bgView withOffset:10];
        
        UILabel *lbTips = [UILabel newAutoLayoutView];
        lbTips.font = [UIFont systemFontOfSize:12];
        lbTips.backgroundColor = [UIColor clearColor];
        lbTips.textAlignment = NSTextAlignmentCenter;
        lbTips.textColor = [UIColor whiteColor];
        lbTips.text = @"活期";
        [self.contentView addSubview:lbTips];
        [lbTips autoSetDimensionsToSize:CGSizeMake(66, 24)];
        [lbTips autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [lbTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:bgView withOffset:10];
        
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont systemFontOfSize:15];
        self.lbTitle.textColor = [UIColor blackColor];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:66];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:66];
        [self.lbTitle autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:bgView withOffset:20];
        [self.lbTitle autoSetDimension:ALDimensionHeight toSize:15];
        
        self.lbInterestRate = [UILabel newAutoLayoutView];
        self.lbInterestRate.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
        [self.contentView addSubview:self.lbInterestRate];
        self.lbInterestRate.textAlignment = NSTextAlignmentCenter;
        [self.lbInterestRate autoSetDimensionsToSize:CGSizeMake(width, 43)];
        [self.lbInterestRate autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:40];
        [self.lbInterestRate autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:14];
        
        self.lbTermUnit = [UILabel newAutoLayoutView];
        self.lbTermUnit.textColor = [UIColor ms_colorWithHexString:@"#191919"];
        self.lbTermUnit.textAlignment = NSTextAlignmentCenter;
        self.lbTermUnit.font = [UIFont systemFontOfSize:21];
        [self.contentView addSubview:self.lbTermUnit];
        [self.lbTermUnit autoSetDimensionsToSize:CGSizeMake(width, 43)];
        [self.lbTermUnit autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:40];
        [self.lbTermUnit autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbInterestRate];
        
        self.lbInterestRateDescription = [UILabel newAutoLayoutView];
        self.lbInterestRateDescription.textColor = [UIColor ms_colorWithHexString:@"#A8A8A8"];
        self.lbInterestRateDescription.textAlignment = NSTextAlignmentCenter;
        self.lbInterestRateDescription.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.lbInterestRateDescription];
        [self.lbInterestRateDescription autoSetDimensionsToSize:CGSizeMake(width, 12)];
        [self.lbInterestRateDescription autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbInterestRate];
        [self.lbInterestRateDescription autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbInterestRate withOffset:8];
        
        self.lbTermUnitTips = [UILabel newAutoLayoutView];
        self.lbTermUnitTips.textColor = [UIColor ms_colorWithHexString:@"#A8A8A8"];
        self.lbTermUnitTips.textAlignment = NSTextAlignmentCenter;
        self.lbTermUnitTips.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.lbTermUnitTips];
        self.lbTermUnitTips.text = @"投资期限";
        [self.lbTermUnitTips autoSetDimensionsToSize:CGSizeMake(width, 12)];
        [self.lbTermUnitTips autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbTermUnit];
        [self.lbTermUnitTips autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbInterestRateDescription];
        
        UIImageView *line = [UIImageView newAutoLayoutView];
        line.image = [UIImage imageNamed:@"line_vertical"];
        [self.contentView addSubview:line];
        [line autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [line autoSetDimension:ALDimensionWidth toSize:0.5];
        [line autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.lbInterestRate withOffset:20];
        [line autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.lbInterestRateDescription withOffset:-4];
        
        self.btnInvest = [UIButton newAutoLayoutView];
        [self.btnInvest setTitle:@"立即买入" forState:UIControlStateNormal];
        [self.btnInvest setTitle:NSLocalizedString(@"str_invest_done", @"已结束") forState:UIControlStateDisabled];
        [self.btnInvest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnInvest setTitleColor:[UIColor ms_colorWithHexString:@"#ADADAD"] forState:UIControlStateDisabled];
        [self.btnInvest setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#FB2F36"] withSize:CGSizeMake(143, 39)] forState:UIControlStateNormal];
        [self.btnInvest setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#F0F0F0"] withSize:CGSizeMake(143, 39)] forState:UIControlStateDisabled];
        self.btnInvest.titleLabel.font = [UIFont systemFontOfSize:14];
        self.btnInvest.layer.cornerRadius = 21;
        self.btnInvest.layer.masksToBounds = YES;
        self.btnInvest.userInteractionEnabled = NO;
        [self.contentView addSubview:self.btnInvest];
        [self.btnInvest autoSetDimensionsToSize:CGSizeMake(143, 42)];
        [self.btnInvest autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.btnInvest autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbInterestRateDescription withOffset:16];
        
    }
    return self;
}

- (void)setCurrentInfo:(CurrentInfo *)currentInfo {
    _currentInfo = currentInfo;
    self.lbTitle.text = currentInfo.title;
    
    NSString *interestRate = [NSString stringWithFormat:@"%.2f%%",currentInfo.interestRate.floatValue * 100];
    NSMutableAttributedString *interestRateAtt = [[NSMutableAttributedString alloc] initWithString:interestRate];
    [interestRateAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:43]} range:NSMakeRange(0, interestRate.length - 1)];
    [interestRateAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} range:NSMakeRange(interestRate.length - 1, 1)];
    self.lbInterestRate.attributedText = interestRateAtt;
    
    self.lbInterestRateDescription.text = currentInfo.interestRateDescription;
    self.lbTermUnit.text = currentInfo.termUnit;
    switch (currentInfo.status) {
        case STATUS_SALING:
        {
            self.btnInvest.enabled = YES;
            break;
        }
        case STATUS_SALE_OUT:
        {
            self.btnInvest.enabled = NO;
            break;
        }
        default:
            break;
    }
}
@end
