//
//  MSNewPointHeaderView.m
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNewPointHeaderView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "PureLayout.h"
#import "UserPoint.h"

@interface MSNewPointHeaderView ()
@property (strong, nonatomic) UILabel *lbScore;
@property (strong, nonatomic) UILabel *lbFrozenScore;

@property (strong, nonatomic) UIView *contentView;
@end

@implementation MSNewPointHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame: frame]) {
        
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
        
        UIButton *btnRules = [UIButton newAutoLayoutView];
        [btnRules setImage:[UIImage imageNamed:@"mypoint"] forState:UIControlStateNormal];
        [btnRules setTitle:@"积分规则" forState:UIControlStateNormal];
        [btnRules setTitleColor:[UIColor ms_colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        btnRules.titleLabel.font = [UIFont systemFontOfSize:12];
        btnRules.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [self.contentView addSubview:btnRules];
        [btnRules autoSetDimensionsToSize:CGSizeMake(76, 22)];
        [btnRules autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:4];
        [btnRules autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:9];
        @weakify(self);
        [[btnRules rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.showRules) {
                self.showRules();
            }
        }];
        
        CGFloat width = self.bounds.size.width / 2.0;
        
        self.lbScore = [UILabel newAutoLayoutView];
        self.lbScore.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
        self.lbScore.font = [UIFont systemFontOfSize:36];
        self.lbScore.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbScore];
        [self.lbScore autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:50];
        [self.lbScore autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbScore autoSetDimensionsToSize:CGSizeMake(width, 37)];
        
        self.lbFrozenScore = [UILabel newAutoLayoutView];
        self.lbFrozenScore.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbFrozenScore.font = [UIFont systemFontOfSize:36];
        self.lbFrozenScore.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbFrozenScore];
        [self.lbFrozenScore autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:50];
        [self.lbFrozenScore autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbFrozenScore autoSetDimensionsToSize:CGSizeMake(width, 37)];
        
        UIImageView *lineImageView = [UIImageView newAutoLayoutView];
        lineImageView.image = [UIImage imageNamed:@"linewhite"];
        [self.contentView addSubview:lineImageView];
        [lineImageView autoSetDimensionsToSize:CGSizeMake(0.5, 60)];
        [lineImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.lbScore];
        [lineImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        UILabel *lbScoreTips = [UILabel newAutoLayoutView];
        lbScoreTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        lbScoreTips.font = [UIFont systemFontOfSize:14];
        lbScoreTips.text = @"可用积分";
        lbScoreTips.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lbScoreTips];
        [lbScoreTips autoSetDimensionsToSize:CGSizeMake(width, 15)];
        [lbScoreTips autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [lbScoreTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbScore withOffset:10];
        
        UILabel *lbFrozenScoreTips = [UILabel newAutoLayoutView];
        lbFrozenScoreTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        lbFrozenScoreTips.font = [UIFont systemFontOfSize:14];
        lbFrozenScoreTips.text = @"冻结积分";
        lbFrozenScoreTips.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lbFrozenScoreTips];
        [lbFrozenScoreTips autoSetDimensionsToSize:CGSizeMake(width, 15)];
        [lbFrozenScoreTips autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [lbFrozenScoreTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbFrozenScore withOffset:10];
        
        UIView *bgView = [UIView newAutoLayoutView];
        bgView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
        [self.contentView addSubview:bgView];
        [bgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbScoreTips withOffset:26];
        [bgView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [bgView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [bgView autoSetDimension:ALDimensionHeight toSize:10];
        
        UIButton *btnPointshop = [UIButton newAutoLayoutView];
        [btnPointshop setBackgroundImage:[UIImage imageNamed:@"pointshop"] forState:UIControlStateNormal];
        [self.contentView addSubview:btnPointshop];
        [btnPointshop autoSetDimensionsToSize:CGSizeMake(130, 32)];
        [btnPointshop autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:bgView withOffset:20];
        [btnPointshop autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [[btnPointshop rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.enterPointShop) {
                self.enterPointShop();
            }
        }];
        
        UILabel *lbTips = [UILabel newAutoLayoutView];
        lbTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        lbTips.font = [UIFont systemFontOfSize:12];
        lbTips.text = @"积分明细";
        lbTips.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lbTips];
        [lbTips autoSetDimensionsToSize:CGSizeMake(50, 14)];
        [lbTips autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [lbTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:btnPointshop withOffset:20];
        
        CGFloat lineWidth = (self.width - 60)/2.0;
        
        UIView *leftLine = [UIView newAutoLayoutView];
        leftLine.backgroundColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:leftLine];
        [leftLine autoSetDimensionsToSize:CGSizeMake(lineWidth, 0.5)];
        [leftLine autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbTips];
        [leftLine autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        
        UIView *rightLine = [UIView newAutoLayoutView];
        rightLine.backgroundColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:rightLine];
        [rightLine autoSetDimensionsToSize:CGSizeMake(lineWidth, 0.5)];
        [rightLine autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbTips];
        [rightLine autoPinEdgeToSuperviewEdge:ALEdgeRight];
        
    }
    return self;
}

- (void)setUserPoint:(UserPoint *)userPoint {
    
    _userPoint = userPoint;
    [self.lbScore setText:[NSString stringWithFormat:@"%d",userPoint.usedPoints]];
    [self.lbFrozenScore setText:[NSString stringWithFormat:@"%d",userPoint.freezePoints]];

}
@end
