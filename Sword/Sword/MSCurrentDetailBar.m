//
//  MSCurrentDetailBar.m
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentDetailBar.h"
#import "UIView+FrameUtil.h"
#import "UIImage+color.h"

@interface MSCurrentDetailBar ()
@property (strong, nonatomic) UIButton *btnInvestment;
@property (strong, nonatomic) UIButton *btnRedeem;
@end

@implementation MSCurrentDetailBar
- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        self.btnRedeem = [[UIButton alloc] init];
        [self.btnRedeem setTitle:@"赎回" forState:UIControlStateNormal];
        [self.btnRedeem setTitleColor:[UIColor ms_colorWithHexString:@"#FC646A"] forState:UIControlStateNormal];
        [self.btnRedeem setTitleColor:[UIColor ms_colorWithHexString:@"#ADADAD"] forState:UIControlStateDisabled];
        
        [self.btnRedeem setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor whiteColor] withSize:CGSizeMake(self.width / 2.0, self.height)] forState:UIControlStateNormal];
        [self.btnRedeem setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#F0F0F0"] withSize:CGSizeMake(self.width / 2.0, self.height)] forState:UIControlStateDisabled];
        [self.btnRedeem setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#FFCACC"] withSize:CGSizeMake(self.width / 2.0, self.height)] forState:UIControlStateHighlighted];
        self.btnRedeem.tag = MSCurrentDetailBarTypeRedeem;
        [self addSubview:self.btnRedeem];
        self.btnRedeem.hidden = YES;
        [self.btnRedeem addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];

        
        self.btnInvestment = [[UIButton alloc] init];
        [self.btnInvestment setTitle:@"立即买入" forState:UIControlStateNormal];
        [self.btnInvestment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnInvestment setTitleColor:[UIColor ms_colorWithHexString:@"#ADADAD"] forState:UIControlStateDisabled];
        
        [self.btnInvestment setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#FC646A"] withSize:CGSizeMake(self.width / 2.0, self.height)] forState:UIControlStateNormal];
        [self.btnInvestment setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#F0F0F0"] withSize:CGSizeMake(self.width / 2.0, self.height)] forState:UIControlStateDisabled];
        [self.btnInvestment setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#E5494F"] withSize:CGSizeMake(self.width / 2.0, self.height)] forState:UIControlStateHighlighted];
        self.btnInvestment.tag = MSCurrentDetailBarTypeInvest;
        [self addSubview:self.btnInvestment];
        self.btnInvestment.frame = self.bounds;
        [self.btnInvestment addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        line.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        [self addSubview:line];
        
        self.btnRedeem.enabled = NO;
        self.btnInvestment.enabled = NO;
    }
    return self;
}

- (void)updateWithAssetInfo:(AssetInfo *)assetInfo currentDetail:(CurrentDetail *)currentDetail {
    
    if (currentDetail.baseInfo.status == STATUS_SALE_OUT) {
        self.btnRedeem.enabled = NO;
        self.btnInvestment.enabled = NO;
        self.btnRedeem.hidden = YES;
        self.btnInvestment.frame = self.bounds;
        [self.btnInvestment setTitle:NSLocalizedString(@"str_invest_done", @"已结束") forState:UIControlStateNormal];
        return;
    }
    
    [self.btnInvestment setTitle:@"立即买入" forState:UIControlStateNormal];
    
    if (currentDetail.investRulesURL && currentDetail.investRulesURL.length > 0) {
        self.btnRedeem.enabled = YES;
        self.btnInvestment.enabled = YES;
    } else {
        self.btnRedeem.enabled = NO;
        self.btnInvestment.enabled = NO;
    }
    
    if (assetInfo.currentAsset.canRedeemAmount.doubleValue > 0) {
        self.btnRedeem.hidden = NO;
        self.btnRedeem.frame = CGRectMake(0, 0, self.width / 2.0, self.height);
        self.btnInvestment.frame = CGRectMake(CGRectGetMaxX(self.btnRedeem.frame), 0, self.width / 2.0, self.height);
    } else {
        self.btnRedeem.hidden = YES;
        self.btnInvestment.frame = self.bounds;
    }
}

- (void)action:(UIButton *)btn {
    MSCurrentDetailBarType type = (MSCurrentDetailBarType)btn.tag;
    if (self.actionBlock) {
        self.actionBlock(type);
    }
}

@end
