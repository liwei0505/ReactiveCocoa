//
//  MSRegularEmptyView.m
//  Sword
//
//  Created by lee on 17/4/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSRegularEmptyView.h"

@interface MSRegularEmptyView()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnHint;

@end

@implementation MSRegularEmptyView

- (instancetype)init {

    if (self = [super init]) {
        [self addSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {

    self.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_record"]];
    [imageView configureForAutoLayout];
    self.imageView = imageView;
    [self addSubview:imageView];
    
    UIButton *btnHint = [UIButton newAutoLayoutView];
    btnHint.titleLabel.font = [UIFont systemFontOfSize:14];
    NSString *text = @"暂无记录，立即理财";
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor ms_colorWithHexString:@"#AAAAAA"] range:NSMakeRange(0, text.length-4)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor ms_colorWithHexString:@"#FC646A"] range:NSMakeRange(text.length-4, 4)];
    [btnHint setAttributedTitle:attributeString forState:UIControlStateNormal];
    [btnHint addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    self.btnHint = btnHint;
    [self addSubview:btnHint];
    
}

- (void)layoutSubviews {

    [super layoutSubviews];
    [self.imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.imageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-30];
    
    [self.btnHint autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.btnHint autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:22];
    
}

- (void)buttonClick {
    if (self.investButtonBlock) {
        self.investButtonBlock();
    }
}

@end
