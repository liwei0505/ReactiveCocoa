//
//  MSNewPointRulesView.m
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNewPointRulesView.h"
#import "PureLayout.h"
#import "UIColor+StringColor.h"

@implementation MSNewPointRulesView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        UILabel *lbTitle = [UILabel newAutoLayoutView];
        lbTitle.textColor = [UIColor ms_colorWithHexString:@"#000000"];
        lbTitle.font = [UIFont systemFontOfSize:16];
        lbTitle.text = @"积分兑换规则";
        lbTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lbTitle];
        [lbTitle autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
        [lbTitle autoSetDimension:ALDimensionHeight toSize:50];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#C6C6C6"];
        [self addSubview:line];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbTitle];
        
        UILabel *lbOne = [UILabel newAutoLayoutView];
        lbOne.textColor = [UIColor ms_colorWithHexString:@"#000000"];
        lbOne.numberOfLines = 0;
        lbOne.font = [UIFont systemFontOfSize:14];
        lbOne.text = @"1.用户当前可用积分大于或等于兑换商品所需积分时，可申请积分兑换。";
        [self addSubview:lbOne];
        [lbOne autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [lbOne autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [lbOne autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line withOffset:20];
        
        UILabel *lbTwo = [UILabel newAutoLayoutView];
        lbTwo.textColor = [UIColor ms_colorWithHexString:@"#000000"];
        lbTwo.numberOfLines = 0;
        lbTwo.font = [UIFont systemFontOfSize:14];
        lbTwo.text = @"2.积分兑换申请后，等值的积分会被暂时冻结，兑换成功后积分会被扣除，并在兑换记录中显示；若兑换失败，积分将被退回。";
        [self addSubview:lbTwo];
        [lbTwo autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [lbTwo autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [lbTwo autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbOne withOffset:5];
        
        UILabel *lbThree = [UILabel newAutoLayoutView];
        lbThree.textColor = [UIColor ms_colorWithHexString:@"#000000"];
        lbThree.numberOfLines = 0;
        lbThree.font = [UIFont systemFontOfSize:14];
        lbThree.text = @"3.若您兑换的是实物商品，客服人员会在1-3个工作日与您在民金所绑定的手机进行联系，核对兑换商品及收件地址等信息。";
        [self addSubview:lbThree];
        [lbThree autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [lbThree autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [lbThree autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbTwo withOffset:5];
        
    }
    return self;
}

@end
