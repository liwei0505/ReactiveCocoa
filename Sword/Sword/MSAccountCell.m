//
//  MSAccountCell.m
//  Sword
//
//  Created by lee on 2017/6/12.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSAccountCell.h"
#import "PureLayout.h"
#import "UIImage+color.h"

@interface MSAccountCell()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbDetail;
@end

@implementation MSAccountCell

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
    
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [UIImageView newAutoLayoutView];
        [self.contentView addSubview:self.imageView];
        [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.imageView autoAlignAxisToSuperviewMarginAxis:ALAxisHorizontal];
        [self.imageView autoSetDimensionsToSize:CGSizeMake(25, 25)];
        
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        self.lbTitle.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1/1.0];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.imageView withOffset:19];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:29];
        
        self.lbDetail = [UILabel newAutoLayoutView];
        self.lbDetail.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        self.lbDetail.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        [self.contentView addSubview:self.lbDetail];
        [self.lbDetail autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.imageView withOffset:19];
        [self.lbDetail autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:3];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.contentView.backgroundColor = [UIColor ms_colorWithHexString:@"#f0f0f0"];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor ms_colorWithHexString:@"#f0f0f0"];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
}

- (void)setModel:(MSAccountModel *)model {

    _model = model;
    self.imageView.image = [UIImage imageNamed:model.iconStr];
    self.lbTitle.text = model.title;
    self.lbDetail.text = model.detail;
    
}

@end
