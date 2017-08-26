//
//  MSInvestSectionHeaderView.m
//  Sword
//
//  Created by msj on 2017/4/1.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestSectionHeaderView.h"

@interface MSInvestSectionHeaderView ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTitle;
@end

@implementation MSInvestSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont boldSystemFontOfSize:12];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:14];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        self.imageView = [UIImageView newAutoLayoutView];
        [self addSubview:self.imageView];
        [self.imageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.lbTitle withOffset:8];
        [self.imageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.imageView autoSetDimensionsToSize:CGSizeMake(16, 16)];
    }
    return self;
}

- (void)updateImage:(NSString *)image title:(NSString *)title {
    
    if (!image) {
        self.imageView.hidden = YES;
    }else {
        self.imageView.hidden = NO;
        self.imageView.image = [UIImage imageNamed:image];
    }
    self.lbTitle.text = title;
}
@end
