//
//  MSRedEnvelopeRuleView.m
//  Sword
//
//  Created by msj on 2017/6/20.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSRedEnvelopeRuleView.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"

@interface MSRedEnvelopeRuleView ()
@property (strong, nonatomic) UIView *contentView;
@end

@implementation MSRedEnvelopeRuleView

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
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(30, 0, self.width - 60, 0)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 6;
    [self addSubview:self.contentView];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 35)];
    lbTitle.text = @"红包说明";
    lbTitle.textColor = [UIColor ms_colorWithHexString:@"#454A5C"];
    lbTitle.textAlignment = NSTextAlignmentCenter;
    lbTitle.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:lbTitle];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbTitle.frame), self.contentView.width, 1)];
    topLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self.contentView addSubview:topLine];
    
    NSString *one = @"1.红包仅限于投资民金所平台所指定产品使用。";
    CGSize oneSize = [self getSize:one];
    UILabel *lbOne = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(topLine.frame)+10, self.contentView.width-32, oneSize.height)];
    lbOne.numberOfLines = 0;
    lbOne.text = one;
    lbOne.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbOne.textAlignment = NSTextAlignmentLeft;
    lbOne.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:lbOne];
    
    NSString *two = @"2.根据单笔投资金额,可选用符合条件的红包。";
    CGSize twoSize = [self getSize:two];
    UILabel *lbTwo = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lbOne.frame)+8, self.contentView.width-32, twoSize.height)];
    lbTwo.numberOfLines = 0;
    lbTwo.text = two;
    lbTwo.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbTwo.textAlignment = NSTextAlignmentLeft;
    lbTwo.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:lbTwo];
    
    NSString *three = @"3.单笔投资仅限使用一个红包。";
    CGSize threeSize = [self getSize:three];
    UILabel *lbThree = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lbTwo.frame)+8, self.contentView.width-32, threeSize.height)];
    lbThree.numberOfLines = 0;
    lbThree.text = three;
    lbThree.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbThree.textAlignment = NSTextAlignmentLeft;
    lbThree.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:lbThree];
    
    NSString *four = @"4.红包仅限有效期内使用,过期作废。";
    CGSize fourSize = [self getSize:four];
    UILabel *lbFour = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lbThree.frame)+8, self.contentView.width-32, fourSize.height)];
    lbFour.numberOfLines = 0;
    lbFour.text = four;
    lbFour.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbFour.textAlignment = NSTextAlignmentLeft;
    lbFour.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:lbFour];
    
    NSString *five = @"5.红包使用的最终解释权归民金所所有。";
    CGSize fiveSize = [self getSize:five];
    UILabel *lbFive = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lbFour.frame)+8, self.contentView.width-32, fiveSize.height)];
    lbFive.numberOfLines = 0;
    lbFive.text = five;
    lbFive.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbFive.textAlignment = NSTextAlignmentLeft;
    lbFive.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:lbFive];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbFive.frame)+8, self.contentView.width, 1)];
    bottomLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self.contentView addSubview:bottomLine];
    
    UIButton *btnSure = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bottomLine.frame), self.contentView.width, 45)];
    [btnSure setTitle:@"确定" forState:UIControlStateNormal];
    [btnSure setTitleColor:[UIColor ms_colorWithHexString:@"#343490"] forState:UIControlStateNormal];
    [self.contentView addSubview:btnSure];
    @weakify(self);
    [[btnSure rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self removeFromSuperview];
    }];
    
    self.contentView.height = CGRectGetMaxY(btnSure.frame);
    self.contentView.y = (self.height - self.contentView.height)/2.0 - 25;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        return;
    }
    
    self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
}

- (void)removeFromSuperview {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (CGSize)getSize:(NSString *)str {
    return [str boundingRectWithSize:CGSizeMake(self.contentView.width-32, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size;
}

@end
