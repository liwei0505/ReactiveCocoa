//
//  MSLoanBar.m
//  Sword
//
//  Created by msj on 2017/6/12.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSLoanBar.h"
#import "UIView+FrameUtil.h"
#import "UIImage+color.h"

@interface MSLoanBar ()

@property(nonatomic, strong)UILabel *lbTitle;
@property(nonatomic, strong)UILabel *lbSubTitle;

@end

@implementation MSLoanBar
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
        [self setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.width, 20)];
        self.lbTitle.textColor = [UIColor whiteColor];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        self.lbTitle.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:self.lbTitle];
        
        self.lbSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbTitle.frame) + 2, self.width, 14)];
        self.lbSubTitle.textColor = [UIColor whiteColor];
        self.lbSubTitle.textAlignment = NSTextAlignmentCenter;
        self.lbSubTitle.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.lbSubTitle];
        
        self.lbTitle.text = @"立即投资";
        self.lbSubTitle.text = @"--元起投 --元递增,单笔上限--元";
        
        self.enabled = NO;
        
    }
    return self;
}

- (void)setLoanDetail:(LoanDetail *)loanDetail {
    _loanDetail = loanDetail;
    
    self.enabled = (loanDetail.baseInfo.status == LOAN_STATUS_INVEST_NOW);
    switch (loanDetail.baseInfo.status) {
        case LOAN_STATUS_WILL_START: {
            self.lbTitle.text = @"立即投资";
        } break;
        case LOAN_STATUS_INVEST_NOW: {
            self.lbTitle.text = @"立即投资";
        } break;
        case LOAN_STATUS_COMPLETED: {
            self.lbTitle.text = NSLocalizedString(@"str_invest_done", @"已售罄");
        } break;
        default: {
            self.lbTitle.text = NSLocalizedString(@"str_invest_end", @"已结束");
        } break;
    }
    
    if (loanDetail.baseInfo.maxInvestLimit > 0) {
        self.lbSubTitle.text = [NSString stringWithFormat:@"%d元起投 %ld元递增 单笔上限%.f元", loanDetail.baseInfo.startAmount, loanDetail.increaseAmount,loanDetail.baseInfo.maxInvestLimit];
    } else {
        self.lbSubTitle.text = [NSString stringWithFormat:@"%d元起投 %ld元递增", loanDetail.baseInfo.startAmount, loanDetail.increaseAmount];
    }
    
    switch (loanDetail.baseInfo.status) {
        case LOAN_STATUS_WILL_START:
        case LOAN_STATUS_INVEST_NOW:
        {
            self.lbTitle.font = [UIFont boldSystemFontOfSize:14];
            self.lbTitle.frame = CGRectMake(0, 10, self.width, 20);
            self.lbSubTitle.hidden = NO;
            break;
        }
        default:
        {
            self.lbTitle.font = [UIFont boldSystemFontOfSize:17];
            self.lbTitle.frame = self.bounds;
            self.lbSubTitle.hidden = YES;
            break;
        }
    }
}

- (void)setMyInvestedAmount:(NSDecimalNumber *)myInvestedAmount {
    _myInvestedAmount = myInvestedAmount;
    if (myInvestedAmount.doubleValue > 0) {
        double leftCanInvestAmount = self.loanDetail.baseInfo.maxInvestLimit - myInvestedAmount.doubleValue;
        if (leftCanInvestAmount > 0) {
            self.lbSubTitle.text = [NSString stringWithFormat:@"%ld元递增 剩余可投%.f元", self.loanDetail.increaseAmount, leftCanInvestAmount];
        } else {
            self.enabled = NO;
            self.lbTitle.text = @"已达上限";
            self.lbSubTitle.text = [NSString stringWithFormat:@"%d元起投 %ld元递增 累计上限%.f元", self.loanDetail.baseInfo.startAmount, self.loanDetail.increaseAmount, self.loanDetail.baseInfo.maxInvestLimit];
        }
    } else {
        self.lbSubTitle.text = [NSString stringWithFormat:@"%d元起投 %ld元递增 累计上限%.f元", self.loanDetail.baseInfo.startAmount, self.loanDetail.increaseAmount, self.loanDetail.baseInfo.maxInvestLimit];
    }
}

@end
