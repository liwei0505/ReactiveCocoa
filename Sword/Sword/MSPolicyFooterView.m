//
//  MSPolicyFooterView.m
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPolicyFooterView.h"

@interface MSPolicyFooterView ()
@property (strong, nonatomic) UILabel *lbTips;
@property (strong, nonatomic) UIButton *btnPay;
@property (strong, nonatomic) UIButton *btnCancel;
@end

@implementation MSPolicyFooterView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    
    self.backgroundColor = [UIColor clearColor];
    CGFloat font = 10;
    if ([UIScreen mainScreen].bounds.size.width <= 320) {
        font = 9;
    }
    self.lbTips = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.width, 14)];
    self.lbTips.text = @"本页面保单信息仅供参考，实际保单状态请以保险公司核心业务系统为准";
    self.lbTips.font = [UIFont systemFontOfSize:font];
    self.lbTips.textAlignment = NSTextAlignmentCenter;
    self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    [self addSubview:self.lbTips];
    
    self.btnPay = [[UIButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.lbTips.frame)+24, self.width - 32, 40)];
    [self.btnPay setTitle:@"立即支付" forState:UIControlStateNormal];
    [self.btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnPay.layer.cornerRadius = self.btnPay.height / 2.0;
    self.btnPay.layer.masksToBounds = YES;
    [self.btnPay setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.btnPay setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.btnPay setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    [self addSubview:self.btnPay];
    
    @weakify(self);
    [[self.btnPay rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.payBlock) {
            self.payBlock();
        }
    }];
    
    self.btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(self.btnPay.frame)+16, 50, 18)];
    self.btnCancel.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.btnCancel setTitle:@"取消订单" forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:[UIColor ms_colorWithHexString:@"#7564C4"] forState:UIControlStateNormal];
    [self addSubview:self.btnCancel];
    
    [[self.btnCancel rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }];
}

- (void)setPolicy:(InsurancePolicy *)policy {
    _policy = policy;
   
    if (policy.status == POLICY_STATUS_TOBE_PAID) {
        self.btnPay.hidden = NO;
        self.btnCancel.hidden = NO;
        self.height = CGRectGetMaxY(self.btnCancel.frame)+8;
    } else {
        self.btnPay.hidden = YES;
        self.btnCancel.hidden = YES;
        self.height = CGRectGetMaxY(self.lbTips.frame)+8;
    }
}
@end
