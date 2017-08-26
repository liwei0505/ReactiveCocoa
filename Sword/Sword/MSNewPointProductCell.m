//
//  MSNewPointProductCell.m
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNewPointProductCell.h"
#import "GoodsInfo.h"
#import "UIImageView+WebCache.h"
#import "UIColor+StringColor.h"
#import "PureLayout.h"

@interface MSNewPointProductCell ()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbPoint;
@property (strong, nonatomic) UIButton *btnExchange;
@end

@implementation MSNewPointProductCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [UIColor ms_colorWithHexString:@"#F6F6F6"];
        
        self.icon = [UIImageView newAutoLayoutView];
        [self.contentView addSubview:self.icon];
        [self.icon autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [self.icon autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.icon];
        
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#323232"];
        self.lbTitle.font = [UIFont boldSystemFontOfSize:16];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.icon withOffset:10];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbTitle autoSetDimension:ALDimensionHeight toSize:20];
        
        self.lbPoint = [UILabel newAutoLayoutView];
        self.lbPoint.font = [UIFont systemFontOfSize:15];
        self.lbPoint.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbPoint];
        [self.lbPoint autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:10];
        [self.lbPoint autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbPoint autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbPoint autoSetDimension:ALDimensionHeight toSize:18];
        
        self.btnExchange = [UIButton newAutoLayoutView];
        [self.btnExchange setBackgroundImage:[UIImage imageNamed:@"button_all"] forState:UIControlStateNormal];
        [self.btnExchange setTitle:@"兑换" forState:UIControlStateNormal];
        self.btnExchange.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.btnExchange setTitleColor:[UIColor ms_colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.btnExchange];
        [self.btnExchange autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.btnExchange autoSetDimension:ALDimensionHeight toSize:32];
        @weakify(self);
        [[self.btnExchange rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.exchange) {
                self.exchange(self.goodInfo);
            }
        }];
        
    }
    return self;
}

- (void)setGoodInfo:(GoodsInfo *)goodInfo{
    _goodInfo = goodInfo;
    
    [self.icon sd_setImageWithURL:[NSURL URLWithString:goodInfo.pictureUrl] placeholderImage:[UIImage imageNamed:@"upload_placeholder"]];
    self.lbTitle.text = goodInfo.name;

    NSString *points  = [NSString stringWithFormat:@"积分 %d",goodInfo.points];
    NSMutableAttributedString * attrPoints = [[NSMutableAttributedString alloc] initWithString:points];
    [attrPoints addAttribute:NSForegroundColorAttributeName value: [UIColor ms_colorWithHexString:@"#FC646A"] range:NSMakeRange(3, points.length-3)];
    self.lbPoint.attributedText = attrPoints;
}
@end
