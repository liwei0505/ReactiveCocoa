//
//  MSChargeStatusView.m
//  Sword
//
//  Created by msj on 2017/7/3.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSChargeStatusView.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "MSConfig.h"

@interface MSChargeStatusView ()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *imageIcon;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbSubTitle;

@property (assign, nonatomic) MSChargeStatusType style;

@end

@implementation MSChargeStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self addSubviews];
        self.contentView.alpha = 0;
    }
    return self;
}

- (void)addSubviews {
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(27*scaleX, 97*scaleY, self.width - 27*scaleX*2, 303*scaleY)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 4;
    [self addSubview:self.contentView];
    
    self.imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.contentView.width - 109*scaleX)/2.0, 49*scaleY, 109*scaleX, 109*scaleX)];
    [self.contentView addSubview:self.imageIcon];
    
    self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageIcon.frame)+27*scaleY, self.contentView.width, 25)];
    self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    self.lbTitle.textAlignment = NSTextAlignmentCenter;
    self.lbTitle.font = [UIFont systemFontOfSize:18];
    [self.contentView addSubview:self.lbTitle];
    
    self.lbSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbTitle.frame)+8, self.contentView.width, 17)];
    self.lbSubTitle.textColor = [UIColor ms_colorWithHexString:@"666666"];
    self.lbSubTitle.textAlignment = NSTextAlignmentCenter;
    self.lbSubTitle.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.lbSubTitle];
    
    @weakify(self);
    UIButton *btnSure = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.height - 49*scaleY, self.contentView.width, 49*scaleY)];
    [btnSure setTitle:@"知道了" forState:UIControlStateNormal];
    [btnSure setTitleColor:[UIColor ms_colorWithHexString:@"#4229B3"] forState:UIControlStateNormal];
    btnSure.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:btnSure];
    [[btnSure rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        [self removeFromSuperview];
        
        if (self.style == MSChargeStatusType_success) {
            if (self.block) {
                self.block();
            }
        }
    }];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbSubTitle.frame)+21*scaleY, self.contentView.width, 1)];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"#D8D8D8"];
    [self.contentView addSubview:line];
}

- (void)showWithStyle:(MSChargeStatusType)style message:(NSString *)message {
    _style = style;
    if (style == MSChargeStatusType_success) {
        self.imageIcon.image = [UIImage imageNamed:@"pay_success"];
        self.lbTitle.text = @"充值成功";
        self.lbSubTitle.text = message;
    } else {
        self.imageIcon.image = [UIImage imageNamed:@"pay_failure"];
        self.lbTitle.text = @"充值失败";
        self.lbSubTitle.text = message.length > 0 ? message : @"";
    }
    [[MSAppDelegate getInstance].window addSubview:self];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    CGFloat duration = 0;
    if (self.style == MSChargeStatusType_error) {
        duration = 0.25;
    }
    [UIView animateWithDuration:duration animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.contentView.alpha = 1;
        self.imageIcon.alpha = 1;
    } completion:^(BOOL finished) {
        [super willMoveToSuperview:newSuperview];
    }];
}

- (void)removeFromSuperview {
    
    CGFloat duration = 0;
    if (self.style == MSChargeStatusType_error) {
        duration = 0.25;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.contentView.alpha = 0;
        self.imageIcon.alpha = 0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

@end
