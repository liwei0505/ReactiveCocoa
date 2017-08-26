//
//  MSInvestDetailHeaderView.m
//  Sword
//
//  Created by msj on 2017/6/12.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestDetailHeaderView.h"
#import "MSLoanProgress.h"
#import "MSLoanTimeLine.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"

@interface MSInvestDetailHeaderView ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbInterest;
@property (strong, nonatomic) UILabel *lbRate;

@property (strong, nonatomic) UILabel *lbRedEnvelope;
@property (strong, nonatomic) UILabel *lbNewNovice;

@property (strong, nonatomic) MSLoanProgress *progress;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *lbProject;
@property (strong, nonatomic) UILabel *lbProjectTerm;
@property (strong, nonatomic) UILabel *lbRepayment;
@property (strong, nonatomic) UILabel *lbRepaymentTerm;
@property (strong, nonatomic) UILabel *lbTotalMoney;
@property (strong, nonatomic) UILabel *lbTotalMoneyTerm;

@property (strong, nonatomic) MSLoanTimeLine *timeline;
@end

@implementation MSInvestDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        UIImage *oldImage = [UIImage imageNamed:@"ms_bg_image"];
        UIImage *bgImage = [oldImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, oldImage.size.width*0.5 - 1, 0.5, oldImage.size.width*0.5 - 1) resizingMode:UIImageResizingModeStretch];
        bgImageView.image = bgImage;
        [self addSubview:bgImageView];
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.width, 17)];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        self.lbTitle.font = [UIFont systemFontOfSize:12];
        self.lbTitle.text = @"--";
        [self addSubview:self.lbTitle];
        
        self.lbInterest = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbTitle.frame)+4, self.width, 67)];
        self.lbInterest.textColor = [UIColor whiteColor];
        self.lbInterest.textAlignment = NSTextAlignmentCenter;
        self.lbInterest.font = [UIFont systemFontOfSize:48];
        self.lbInterest.text = @"--";
        [self addSubview:self.lbInterest];
        
        self.lbRate = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, self.width, 17)];
        self.lbRate.textColor = [UIColor whiteColor];
        self.lbRate.textAlignment = NSTextAlignmentCenter;
        self.lbRate.font = [UIFont systemFontOfSize:12];
        self.lbRate.text = @"预期年化收益率";
        [self addSubview:self.lbRate];
        
        self.lbNewNovice = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbRate.frame)+4, 0, 16)];
        self.lbNewNovice.font = [UIFont systemFontOfSize:10];
        self.lbNewNovice.textAlignment = NSTextAlignmentCenter;
        self.lbNewNovice.textColor = [UIColor whiteColor];
        self.lbNewNovice.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        self.lbNewNovice.layer.cornerRadius = 2;
        self.lbNewNovice.layer.masksToBounds = YES;
        [self addSubview:self.lbNewNovice];
        self.lbNewNovice.hidden = YES;
        
        self.lbRedEnvelope = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbRate.frame)+4, 0, 16)];
        self.lbRedEnvelope.font = [UIFont systemFontOfSize:10];
        self.lbRedEnvelope.textAlignment = NSTextAlignmentCenter;
        self.lbRedEnvelope.textColor = [UIColor whiteColor];
        self.lbRedEnvelope.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        self.lbRedEnvelope.layer.cornerRadius = 2;
        self.lbRedEnvelope.layer.masksToBounds = YES;
        [self addSubview:self.lbRedEnvelope];
        self.lbRedEnvelope.hidden = YES;
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 164, self.width, 70)];
        self.contentView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4/1.0];
        [self addSubview:self.contentView];
        
        CGFloat width = self.width / 3.0;
        self.lbProject = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, width, 17)];
        self.lbProject.font = [UIFont systemFontOfSize:12];
        self.lbProject.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
        self.lbProject.text = @"项目期限";
        self.lbProject.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbProject];
        
        self.lbProjectTerm = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbProject.frame)+4, width, 17)];
        self.lbProjectTerm.font = [UIFont systemFontOfSize:12];
        self.lbProjectTerm.textColor = [UIColor whiteColor];
        self.lbProjectTerm.text = @"--";
        self.lbProjectTerm.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbProjectTerm];
        
        self.lbRepayment = [[UILabel alloc] initWithFrame:CGRectMake(width, 16, width, 17)];
        self.lbRepayment.font = [UIFont systemFontOfSize:12];
        self.lbRepayment.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
        self.lbRepayment.text = @"还款方式";
        self.lbRepayment.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbRepayment];
        
        self.lbRepaymentTerm = [[UILabel alloc] initWithFrame:CGRectMake(width, CGRectGetMaxY(self.lbRepayment.frame)+4, width, 17)];
        self.lbRepaymentTerm.font = [UIFont systemFontOfSize:12];
        self.lbRepaymentTerm.textColor = [UIColor whiteColor];
        self.lbRepaymentTerm.text = @"--";
        self.lbRepaymentTerm.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbRepaymentTerm];
        
        self.lbTotalMoney = [[UILabel alloc] initWithFrame:CGRectMake(width*2, 16, width, 17)];
        self.lbTotalMoney.font = [UIFont systemFontOfSize:12];
        self.lbTotalMoney.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
        self.lbTotalMoney.text = @"融资总额";
        self.lbTotalMoney.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbTotalMoney];
        
        self.lbTotalMoneyTerm = [[UILabel alloc] initWithFrame:CGRectMake(width*2, CGRectGetMaxY(self.lbRepayment.frame)+4, width, 17)];
        self.lbTotalMoneyTerm.font = [UIFont systemFontOfSize:12];
        self.lbTotalMoneyTerm.textColor = [UIColor whiteColor];
        self.lbTotalMoneyTerm.text = @"--";
        self.lbTotalMoneyTerm.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbTotalMoneyTerm];
        
        self.progress = [[MSLoanProgress alloc] initWithFrame:CGRectMake(0, self.contentView.y - 28, self.width, 28)];
        [self addSubview:self.progress];
        
        self.timeline = [[MSLoanTimeLine alloc] initWithFrame:CGRectMake(0, 234, self.width, 110)];
        @weakify(self);
        self.timeline.countdownTimeoutBlock = ^{
            @strongify(self);
            if (self.countdownTimeoutBlock) {
                self.countdownTimeoutBlock();
            }
        };
        [self addSubview:self.timeline];
    }
    return self;
}

- (void)setLoanDetail:(LoanDetail *)loanDetail {
    _loanDetail = loanDetail;
    self.lbTitle.text = loanDetail.baseInfo.title;
    
    NSString *ratioStr = nil;
    NSString *interestStr = nil;
    CGFloat ratio = loanDetail.baseInfo.salesRate;
    if (ratio > 0) {
        ratioStr = [NSString stringWithFormat:@"+%.1f%%",ratio];
    } else {
        ratioStr = @"%";
    }
    interestStr = [NSString stringWithFormat:@"%.1f", loanDetail.baseInfo.interest-ratio];
    
    NSMutableAttributedString *interestAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",interestStr,ratioStr]];
    [interestAttributedString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:48]} range:NSMakeRange(0, interestStr.length)];
    [interestAttributedString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:24]} range:NSMakeRange(interestStr.length, ratioStr.length)];
    self.lbInterest.attributedText = interestAttributedString;
    
    
    self.lbNewNovice.hidden = (loanDetail.baseInfo.classify != CLASSIFY_FOR_TIRO);
    self.lbRedEnvelope.hidden = !loanDetail.baseInfo.redEnvelopeTypes;
    
    CGSize noviceSize = [@"新手专享" sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]}];
    CGSize redEnvelopeSize = [[self getRedEnvelopeName] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]}];
    CGFloat x = 0;
    CGFloat distance = 8;
    if (self.lbNewNovice.hidden && self.lbRedEnvelope.hidden) {
        x = 0;
    }else if (!self.lbNewNovice.hidden && self.lbRedEnvelope.hidden) {
        x = (self.width - (noviceSize.width + 5)) / 2.0;
    }else if (self.lbNewNovice.hidden && !self.lbRedEnvelope.hidden) {
        x = (self.width - (redEnvelopeSize.width + 5)) / 2.0;
    }else {
        x = (self.width - (redEnvelopeSize.width + 5) - (noviceSize.width + 5) - distance) / 2.0;
    }
    self.lbNewNovice.frame = CGRectMake(x, CGRectGetMaxY(self.lbRate.frame)+4, noviceSize.width+5, 16);
    CGFloat redEnvelopeX = (self.lbNewNovice.hidden ? x : CGRectGetMaxX(self.lbNewNovice.frame) + distance);
    self.lbRedEnvelope.frame = CGRectMake(redEnvelopeX, CGRectGetMaxY(self.lbRate.frame)+4, redEnvelopeSize.width+5, 16);

    self.lbNewNovice.text = @"新手专享";
    self.lbRedEnvelope.text = [self getRedEnvelopeName];

    [self.progress updateWithLoanDetail:loanDetail];
    
    self.lbProjectTerm.text = [NSString stringWithFormat:@"%d%@", [loanDetail.baseInfo.termInfo getTermCount], loanDetail.baseInfo.termInfo.term];
    self.lbRepaymentTerm.text = loanDetail.repayType;
    NSString *format = NSLocalizedString(@"fmt_reward_amount", nil);
    double amount = loanDetail.totalAmount;
    if (amount >= 10000) {
        amount /= 10000.00;
        self.lbTotalMoneyTerm.text = [NSString stringWithFormat:NSLocalizedString(@"fmt_reward_amount2", @""),amount];
    } else {
        
        self.lbTotalMoneyTerm.text = [NSString stringWithFormat:format,amount];
    }
    
    self.timeline.loanDetail = loanDetail;
    
}

- (NSString *)getRedEnvelopeName {
    if (self.loanDetail.baseInfo.redEnvelopeTypes == TYPE_VOUCHERS) {
        return @"代金劵";
    } else if (self.loanDetail.baseInfo.redEnvelopeTypes == TYPE_PLUS_COUPONS) {
        return @"加息劵";
    } else if (self.loanDetail.baseInfo.redEnvelopeTypes == TYPE_EXPERIENS_GOLD) {
        return @"体验金";
    } else {
        return @"红包";
    }
    return @"";
}

@end
