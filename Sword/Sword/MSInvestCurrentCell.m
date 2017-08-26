//
//  MSInvestCurrentCell.m
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestCurrentCell.h"
#import "MSTextUtils.h"

#define RGB(r,g,b)  [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/258.0 alpha:1];

@interface MSInvestCurrentCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbInterest;
@property (strong, nonatomic) UILabel *lbInterestTips;
@property (strong, nonatomic) UILabel *lbAmount;
@property (strong, nonatomic) UILabel *lbTerm;

@property (strong, nonatomic) UIView *lineView;
@end

@implementation MSInvestCurrentCell

+ (MSInvestCurrentCell *)cellWithTableView:(UITableView *)tableView
{
    MSInvestCurrentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSInvestCurrentCell"];
    if (!cell) {
        cell = [[MSInvestCurrentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSInvestCurrentCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont systemFontOfSize:15];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#3D3B69"];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [self.lbTitle autoSetDimension:ALDimensionHeight toSize:15];
        
        CGFloat width = (screenWidth - 40) / 3.0;
        
        self.lbInterest = [UILabel newAutoLayoutView];
        self.lbInterest.textColor = [UIColor redColor];
        self.lbInterest.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbInterest];
        [self.lbInterest autoSetDimensionsToSize:CGSizeMake(width, 24)];
        [self.lbInterest autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.lbInterest autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:10];
        
        self.lbAmount = [UILabel newAutoLayoutView];
        self.lbAmount.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbAmount];
        [self.lbAmount autoSetDimensionsToSize:CGSizeMake(width, 24)];
        [self.lbAmount autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbInterest];
        [self.lbAmount autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.lbInterest];
        
        self.lbTerm = [UILabel newAutoLayoutView];
        self.lbTerm.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.lbTerm];
        [self.lbTerm autoSetDimensionsToSize:CGSizeMake(width, 24)];
        [self.lbTerm autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbAmount];
        [self.lbTerm autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.lbAmount];
        
        self.lbInterestTips = [UILabel newAutoLayoutView];
        self.lbInterestTips.textAlignment = NSTextAlignmentLeft;
        self.lbInterestTips.font = [UIFont systemFontOfSize:10];
        self.lbInterestTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:self.lbInterestTips];
        [self.lbInterestTips autoSetDimensionsToSize:CGSizeMake(width, 10)];
        [self.lbInterestTips autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.lbInterestTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbInterest withOffset:6];
        
        UILabel *lbAmountTips = [UILabel newAutoLayoutView];
        lbAmountTips.text = @"起投金额(元)";
        lbAmountTips.textAlignment = NSTextAlignmentCenter;
        lbAmountTips.font = [UIFont systemFontOfSize:10];
        lbAmountTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:lbAmountTips];
        [lbAmountTips autoSetDimensionsToSize:CGSizeMake(width, 10)];
        [lbAmountTips autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbInterestTips];
        [lbAmountTips autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.lbInterestTips];
        
        UILabel *lbTermTips = [UILabel newAutoLayoutView];
        lbTermTips.text = @"投资期限";
        lbTermTips.textAlignment = NSTextAlignmentRight;
        lbTermTips.font = [UIFont systemFontOfSize:10];
        lbTermTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:lbTermTips];
        [lbTermTips autoSetDimensionsToSize:CGSizeMake(width, 10)];
        [lbTermTips autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbAmountTips];
        [lbTermTips autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lbAmountTips];
        
        CGFloat distance = (screenWidth - 1) / 3.0;
        UIImageView *leftLine = [UIImageView newAutoLayoutView];
        leftLine.image = [UIImage imageNamed:@"line_vertical"];
        [self.contentView addSubview:leftLine];
        [leftLine autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.lbInterest];
        [leftLine autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.lbInterestTips];
        [leftLine autoSetDimension:ALDimensionWidth toSize:0.5];
        [leftLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:distance];
        
        UIImageView *rightLine = [UIImageView newAutoLayoutView];
        rightLine.image = [UIImage imageNamed:@"line_vertical"];
        [self.contentView addSubview:rightLine];
        [rightLine autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.lbInterest];
        [rightLine autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.lbInterestTips];
        [rightLine autoSetDimension:ALDimensionWidth toSize:0.5];
        [rightLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:distance * 2];
        
        self.lineView = [UIView newAutoLayoutView];
        self.lineView.backgroundColor = RGB(248, 248, 248);
        [self.contentView addSubview:self.lineView];
        [self.lineView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lineView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.lineView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
        [self.lineView autoSetDimension:ALDimensionHeight toSize:1];
    }
    return self;
}

- (void)updateWithCurrentInfo:(CurrentInfo *)currentInfo index:(NSInteger)index {
    
    self.lineView.hidden = (index == 0);
    
    self.lbTitle.text = currentInfo.title;
    
    NSString *interestRate = [NSString stringWithFormat:@"%.2f%%",currentInfo.interestRate.floatValue * 100];
    NSMutableAttributedString *interestRateAtt = [[NSMutableAttributedString alloc] initWithString:interestRate];
    [interestRateAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:24]} range:NSMakeRange(0, interestRate.length - 1)];
    [interestRateAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]} range:NSMakeRange(interestRate.length - 1, 1)];
    self.lbInterest.attributedText = interestRateAtt;
    
    float amount = currentInfo.startAmount.floatValue;
    if (amount >= 10000) {
        amount /=10000.00;
        NSString *amountStr = [NSString stringWithFormat:@"%.2f万",amount];
        self.lbAmount.attributedText = [MSTextUtils attributedString:amountStr unitLength:1];
    } else {
        self.lbAmount.text = [NSString stringWithFormat:@"%.2f",amount];
    }
    
    self.lbInterestTips.text = currentInfo.interestRateDescription;
    self.lbTerm.text = currentInfo.termUnit;
    
}
@end
