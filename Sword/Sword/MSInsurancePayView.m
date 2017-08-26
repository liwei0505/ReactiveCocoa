//
//  MSInsurancePayView.m
//  Sword
//
//  Created by msj on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsurancePayView.h"
#import "MSInsuranceButton.h"
#import "WXApi.h"

@interface MSInsurancePayView ()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (strong, nonatomic) NSMutableArray *btnDatas;

@property (assign, nonatomic) CGFloat y;

@end

@implementation MSInsurancePayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}

- (void)addSubviews {
    self.datas = [NSMutableArray array];
    self.btnDatas = [NSMutableArray array];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 224)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    
    MSInsuranceModel *ali = [[MSInsuranceModel alloc] initWithTitle:@"支付宝支付" withIcon:@"ms_alipay" withShareType:Pay_Ali];
    MSInsuranceModel *wx = [[MSInsuranceModel alloc] initWithTitle:@"微信支付" withIcon:@"ms_weixinPay" withShareType:Pay_Wx];
    [self.datas addObject:ali];
    
    if ([WXApi isWXAppInstalled]) {
        [self.datas addObject:wx];
    }
    
    UILabel *lbTips = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 46)];
    lbTips.text = @"选择支付方式";
    lbTips.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    lbTips.textAlignment = NSTextAlignmentCenter;
    lbTips.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:lbTips];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 32, 0, 15, 15)];
    imageView.centerY = lbTips.centerY;
    imageView.image = [UIImage imageNamed:@"pay_cancel"];
    [self.contentView addSubview:imageView];
    
    @weakify(self);
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 46, 0, 46, 46)];
    btnCancel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:btnCancel];
    [[btnCancel rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self dismiss];
        [MSToast show:@"订单支付取消"];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbTips.frame), self.width, 1)];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [self.contentView addSubview:line];
    
    CGFloat distance = 55;
    CGFloat height = 76;
    CGFloat width = 75;
    CGFloat distanceX = (self.width - self.datas.count * width - (self.datas.count - 1) * distance) / 2.0;
    CGFloat y = self.contentView.height;
    
    self.y = (self.contentView.height - lbTips.height - height) / 2.0 + lbTips.height;
    
    for (int i = 0; i < self.datas.count; i++) {
        
        CGFloat x = distanceX + i * (width + distance);
        MSInsuranceButton *btn = [[MSInsuranceButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        btn.model = self.datas[i];
        [self.contentView addSubview:btn];
        [self.btnDatas addObject:btn];
        
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss];
            if (self.payBlock) {
                self.payBlock(btn.model.payType);
                [self pageEventTitle:@"确认付款" pageId:214];
            }
        }];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.contentView.y = self.height - self.contentView.height;
    } completion:^(BOOL finished) {
        for (int i = 0; i < self.btnDatas.count; i++) {
            MSInsuranceButton *btn = self.btnDatas[i];
            [UIView animateWithDuration:0.7 delay:0.08*i usingSpringWithDamping:0.5 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                btn.y = self.y;
            } completion:^(BOOL finished) {
            }];
        }
    }];
}

- (void)removeFromSuperview {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.contentView.y = self.height;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (void)show {
    if (!self.superview) {
        [[MSAppDelegate getInstance].window addSubview:self];
        [self pageEventTitle:@"选择支付方式" pageId:213];
    }
}

- (void)dismiss {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)pageEventTitle:(NSString *)title pageId:(int)pageId {

    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = pageId;
    params.title = title;
    [MJSStatistics sendPageParams:params];
 
}

@end
