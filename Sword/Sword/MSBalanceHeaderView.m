//
//  MSChargeHeaderView.m
//  Sword
//
//  Created by msj on 2017/6/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBalanceHeaderView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "NSString+Ext.h"

@interface MSBalanceHeaderView()
@property (strong, nonatomic) UILabel *lbMoney;
@property (strong, nonatomic) UIButton *btnCharge;
@property (strong, nonatomic) UIButton *btnCash;
@property (strong, nonatomic) UIView  *line;
@property (assign, nonatomic, readwrite) BALANCE_TYPE balanceType;
@end

@implementation MSBalanceHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        UIImage *oldImage = [UIImage imageNamed:@"ms_bg_image"];
        UIImage *bgImage = [oldImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, oldImage.size.width*0.5 - 1, 0.5, oldImage.size.width*0.5 - 1) resizingMode:UIImageResizingModeStretch];
        bgImageView.image = bgImage;
        [self addSubview:bgImageView];
        
        self.lbMoney = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.width, 45)];
        self.lbMoney.textColor = [UIColor whiteColor];
        self.lbMoney.font = [UIFont systemFontOfSize:32];
        self.lbMoney.textAlignment = NSTextAlignmentCenter;
        self.lbMoney.text = @"--";
        [self addSubview:self.lbMoney];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 77, self.width, 48)];
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
        
        self.btnCharge = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width/2.0, contentView.height)];
        [self.btnCharge setTitle:@"充值" forState:UIControlStateNormal];
        [self.btnCharge setTitleColor:[UIColor ms_colorWithHexString:@"#F3091C"] forState:UIControlStateSelected];
        [self.btnCharge setTitleColor:[UIColor ms_colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        [self.btnCharge addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnCharge.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnCharge.tag = BALANCE_RECHAGE;
        [contentView addSubview:self.btnCharge];
        
        self.btnCash = [[UIButton alloc] initWithFrame:CGRectMake(self.width/2.0, 0, self.width/2.0, contentView.height)];
        [self.btnCash setTitle:@"提现" forState:UIControlStateNormal];
        [self.btnCash setTitleColor:[UIColor ms_colorWithHexString:@"#F3091C"] forState:UIControlStateSelected];
        [self.btnCash setTitleColor:[UIColor ms_colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        [self.btnCash addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnCash.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnCash.tag = BALANCE_CASH;
        [contentView addSubview:self.btnCash];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake((self.width/2.0 - 72)/2.0, contentView.height - 2, 72, 2)];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        [contentView addSubview:self.line];
        
        self.balanceType = BALANCE_RECHAGE;

    }
    return self;
}

- (void)tap:(UIButton *)btn {
    self.balanceType = (BALANCE_TYPE)btn.tag;
    if (self.balanceType == BALANCE_RECHAGE) {
        [self pageEventWithTitle:@"我的余额-充值" pageId:119 params:nil];
    } else {
        [self pageEventWithTitle:@"我的余额-提现" pageId:120 params:nil];
    }
}

- (void)setAssertInfo:(AssetInfo *)assertInfo {
    _assertInfo = assertInfo;
    NSString *money = [NSString stringWithFormat:@"%@元",[NSString convertMoneyFormate:assertInfo.balance.doubleValue]];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:money];
    [attStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:32]} range:NSMakeRange(0, money.length)];
    [attStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} range:NSMakeRange(money.length - 1, 1)];
    self.lbMoney.attributedText = attStr;
}

- (void)setBalanceType:(BALANCE_TYPE)balanceType {
    _balanceType = balanceType;
    
    if (self.block) {
        self.block(balanceType);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (balanceType == BALANCE_RECHAGE) {
            self.btnCharge.selected = YES;
            self.btnCash.selected = NO;
            self.line.x = (self.width/2.0 - 72) / 2.0;
        } else {
            self.btnCharge.selected = NO;
            self.btnCash.selected = YES;
            self.line.x = (self.width/2.0 - 72) / 2.0 + self.width/2.0;
        }
    }];
    
}

- (void)pageEventWithTitle:(NSString *)title pageId:(int)pageId params:(NSDictionary *)dict {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = pageId;
    params.title = title;
    if (dict) {
        params.params = dict;
    }
    [MJSStatistics sendPageParams:params];
    
}

@end
