//
//  MSInsuranceDetailHeader.m
//  Sword
//
//  Created by lee on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceDetailHeader.h"

@interface MSInsuranceDetailHeader()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbDescribe;
@property (strong, nonatomic) UILabel *lbName;
@property (strong, nonatomic) UILabel *lbDetail;
@property (strong, nonatomic) UIButton *backButton;

@end

@implementation MSInsuranceDetailHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.imageView];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.imageView autoSetDimension:ALDimensionHeight toSize:192];
        
        [self addSubview:self.lbName];
        [self.lbName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:10];
        
        [self addSubview:self.lbDetail];
        [self.lbDetail autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.lbDetail autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbName withOffset:6];
        [self.lbDetail autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        [self addSubview:line];
        [line autoSetDimension:ALDimensionHeight toSize:8];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        self.backButton = [UIButton newAutoLayoutView];
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        [self.backButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:25];
        [self.backButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.backButton autoSetDimensionsToSize:CGSizeMake(24, 24)];
    }
    return self;
}

- (void)popSelf {
    
    if (self.backButtonClick) {
        self.backButtonClick();
    }
}

- (void)setDetail:(InsuranceDetail *)detail {
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:detail.bannerUrl] placeholderImage:[UIImage imageNamed:@"product_img_banner"]];
    self.lbDescribe.text = [NSString stringWithFormat:@"本产品由泛海在线代销丨安心保险承保丨已售%lu份", (unsigned long)detail.baseInfo.soldCount];
    self.lbName.text = detail.baseInfo.title;
    self.lbDetail.text = detail.introduction;
}

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [UIImageView newAutoLayoutView];
        [_imageView addSubview:self.lbDescribe];
        [self.lbDescribe autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbDescribe autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.lbDescribe autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbDescribe autoSetDimension:ALDimensionHeight toSize:24];
    }
    return _imageView;
}

- (UILabel *)lbDescribe {
    
    if (!_lbDescribe) {
        UILabel *lbDescribe = [UILabel newAutoLayoutView];
        lbDescribe.font = [UIFont systemFontOfSize:10];
        lbDescribe.textColor = [UIColor whiteColor];
        lbDescribe.backgroundColor = [UIColor blackColor];
        lbDescribe.alpha = 0.2;
        lbDescribe.textAlignment = NSTextAlignmentRight;
        _lbDescribe = lbDescribe;
    }
    return _lbDescribe;
}

- (UILabel *)lbName {
    if (!_lbName) {
        _lbName = [UILabel newAutoLayoutView];
        _lbName.font = [UIFont systemFontOfSize:16];
        _lbName.textColor = [UIColor ms_colorWithHexString:@"333333"];
    }
    return _lbName;
}

- (UILabel *)lbDetail {
    if (!_lbDetail) {
        _lbDetail = [UILabel newAutoLayoutView];
        _lbDetail.font = [UIFont systemFontOfSize:12];
        _lbDetail.numberOfLines = 0;
        _lbDetail.textColor = [UIColor ms_colorWithHexString:@"999999"];
    }
    return _lbDetail;
}

@end
