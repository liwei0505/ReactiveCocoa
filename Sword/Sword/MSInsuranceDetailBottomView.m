//
//  MSInsuranceDetailBottomView.m
//  Sword
//
//  Created by lee on 2017/8/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceDetailBottomView.h"

@implementation MSInsuranceBottomButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((self.bounds.size.width-20)*0.5, 6, 20, 20);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, self.bounds.size.height-20, self.bounds.size.width, 20);
}

@end


@interface MSInsuranceDetailBottomView()
@property (strong, nonatomic) MSInsuranceBottomButton *call;
@end

@implementation MSInsuranceDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {

    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.call];
    [self.call autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.call autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.call autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.call autoSetDimension:ALDimensionWidth toSize:60];
    
    UIView *line = [UIView newAutoLayoutView];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
    [self addSubview:line];
    [line autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [line autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [line autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.call];
    [line autoSetDimension:ALDimensionWidth toSize:1];
    
    UIButton *commit = [UIButton newAutoLayoutView];
    [commit setTitle:@"立即投保" forState:UIControlStateNormal];
    commit.titleLabel.font = [UIFont systemFontOfSize:16];
    [commit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commit setBackgroundImage:[UIImage imageNamed:@"ms_bg_image"] forState:UIControlStateNormal];
    [commit addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commit];
    [commit autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [commit autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [commit autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [commit autoSetDimension:ALDimensionWidth toSize:120];
    
    UILabel *lbAmount = [UILabel newAutoLayoutView];
    lbAmount.backgroundColor = [UIColor whiteColor];
    lbAmount.textColor = [UIColor ms_colorWithHexString:@"F3091C"];
    lbAmount.font = [UIFont systemFontOfSize:24];
    self.lbAmount = lbAmount;
    [self addSubview:self.lbAmount];
    [lbAmount autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [lbAmount autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [lbAmount autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:line withOffset:16];
    
}

- (void)tel {
    if (self.phone) {
        NSString *phone = [NSString stringWithFormat:@"tel:%@", self.phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
    }
}

- (void)commit {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (MSInsuranceBottomButton *)call {

    if (!_call) {
        MSInsuranceBottomButton *call = [MSInsuranceBottomButton newAutoLayoutView];
        call.backgroundColor = [UIColor whiteColor];
        call.titleLabel.font = [UIFont systemFontOfSize:10];
        call.titleLabel.textAlignment = NSTextAlignmentCenter;
        [call setImage:[UIImage imageNamed:@"ms_phone"] forState:UIControlStateNormal];
        [call setTitleColor:[UIColor ms_colorWithHexString:@"666666"] forState:UIControlStateNormal];
        [call setTitle:@"客服电话" forState:UIControlStateNormal];
        [call addTarget:self action:@selector(tel) forControlEvents:UIControlEventTouchUpInside];
        _call = call;
    }
    return _call;
}

@end
