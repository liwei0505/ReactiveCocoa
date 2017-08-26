//
//  MSHomeSectionView.m
//  Sword
//
//  Created by msj on 2017/6/13.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSHomeSectionView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"

@interface MSHomeSectionView ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbSubTitle;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation MSHomeSectionView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIView *topLine = [UIView newAutoLayoutView];
        topLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self addSubview:topLine];
        [topLine autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [topLine autoSetDimension:ALDimensionHeight toSize:10];
        
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont boldSystemFontOfSize:16];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbTitle autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topLine];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        self.imageView = [UIImageView newAutoLayoutView];
        [self addSubview:self.imageView];
        [self.imageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbTitle];
        [self.imageView autoSetDimensionsToSize:CGSizeMake(16, 16)];
        [self.imageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.lbTitle withOffset:8];
        
        self.lbSubTitle = [UILabel newAutoLayoutView];
        self.lbSubTitle.font = [UIFont boldSystemFontOfSize:12];
        self.lbSubTitle.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbSubTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lbSubTitle];
        [self.lbSubTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbSubTitle autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topLine];
        [self.lbSubTitle autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        UIView *bottomLine = [UIView newAutoLayoutView];
        bottomLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self addSubview:bottomLine];
        [bottomLine autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [bottomLine autoSetDimension:ALDimensionHeight toSize:1];
    }
    return self;
}

- (void)setType:(MSSectionListType)type {
    _type = type;
    switch (type) {
        case MSSectionListTypeWillStart:
        {
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:@"ms_will_start"];
            self.lbTitle.text = @"即将开始";
            self.lbSubTitle.text = @"优质资产";
            break;
        }
        case MSSectionListTypeInvesting:
        {
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:@"ms_investing"];
            self.lbTitle.text = @"大家都在投";
            self.lbSubTitle.text = @"优质资产";
            break;
        }
        case MSSectionListTypeCompleted:
        {
            self.imageView.hidden = YES;
            self.lbTitle.text = @"已售罄";
            self.lbSubTitle.text = @"优质资产";
            break;
        }
        case MSSectionListTypeInsurance:
        {
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:@"ms_zan"];
            self.lbTitle.text = @"保险推荐";
            self.lbSubTitle.text = @"安心保障";
            break;
        }
        default:
            break;
    }
}
@end
