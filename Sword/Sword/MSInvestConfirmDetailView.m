//
//  MSInvestConfirmDetailView.m
//  Sword
//
//  Created by msj on 2017/6/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInvestConfirmDetailView.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "NSString+Ext.h"

@interface MSInvestConfirmDetailView ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbNovice;
@property (strong, nonatomic) UILabel *lbInterest;
@property (strong, nonatomic) UILabel *lbTerm;
@property (strong, nonatomic) UILabel *lbBackWay;
@property (strong, nonatomic) UILabel *lbBalance;
@property (strong, nonatomic) UILabel *lbMaxInvestLimit;
@end

@implementation MSInvestConfirmDetailView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.width - 32, 45)];
    self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbTitle.font = [UIFont systemFontOfSize:12];
    self.lbTitle.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.lbTitle];
    
    self.lbNovice = [[UILabel alloc] initWithFrame:CGRectMake(0, (45 - 16)/2.0, 48, 16)];
    self.lbNovice.font = [UIFont systemFontOfSize:10];
    self.lbNovice.textColor = [UIColor whiteColor];
    self.lbNovice.backgroundColor = [UIColor ms_colorWithHexString:@"#F3091C"];
    self.lbNovice.textAlignment = NSTextAlignmentCenter;
    self.lbNovice.layer.cornerRadius = 2;
    self.lbNovice.layer.masksToBounds = YES;
    self.lbNovice.text = @"新手专享";
    [self addSubview:self.lbNovice];
    self.lbNovice.hidden = YES;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, self.width, 113)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    
    CGFloat width = (self.width - 32) / 2.0;
    UILabel *lbInterestTips = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, width, 12)];
    lbInterestTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbInterestTips.font = [UIFont systemFontOfSize:12];
    lbInterestTips.textAlignment = NSTextAlignmentLeft;
    lbInterestTips.text = @"预期年化收益率";
    [contentView addSubview:lbInterestTips];
    
    UILabel *lbTermTips = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lbInterestTips.frame)+8, width, 12)];
    lbTermTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbTermTips.font = [UIFont systemFontOfSize:12];
    lbTermTips.textAlignment = NSTextAlignmentLeft;
    lbTermTips.text = @"投资期限";
    [contentView addSubview:lbTermTips];
    
    UILabel *lbBackWayTips = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lbTermTips.frame)+8, width, 12)];
    lbBackWayTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbBackWayTips.font = [UIFont systemFontOfSize:12];
    lbBackWayTips.textAlignment = NSTextAlignmentLeft;
    lbBackWayTips.text = @"还款方式";
    [contentView addSubview:lbBackWayTips];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(lbBackWayTips.frame)+8, self.width - 16, 1)];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [contentView addSubview:line];
    
    UILabel *lbBalanceTips = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(line.frame)+8, width, 12)];
    lbBalanceTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbBalanceTips.font = [UIFont systemFontOfSize:12];
    lbBalanceTips.textAlignment = NSTextAlignmentLeft;
    lbBalanceTips.text = @"项目剩余可投";
    [contentView addSubview:lbBalanceTips];
    
    
    self.lbInterest = [[UILabel alloc] initWithFrame:CGRectMake(width + 16, 16, width, 12)];
    self.lbInterest.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbInterest.font = [UIFont systemFontOfSize:12];
    self.lbInterest.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:self.lbInterest];
    
    self.lbTerm = [[UILabel alloc] initWithFrame:CGRectMake(width + 16, CGRectGetMaxY(self.lbInterest.frame)+8, width, 12)];
    self.lbTerm.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbTerm.font = [UIFont systemFontOfSize:12];
    self.lbTerm.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:self.lbTerm];
    
    self.lbBackWay = [[UILabel alloc] initWithFrame:CGRectMake(width + 16, CGRectGetMaxY(self.lbTerm.frame)+8, width, 12)];
    self.lbBackWay.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbBackWay.font = [UIFont systemFontOfSize:12];
    self.lbBackWay.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:self.lbBackWay];
    
    self.lbBalance = [[UILabel alloc] initWithFrame:CGRectMake(width + 16, CGRectGetMaxY(line.frame)+8, width, 12)];
    self.lbBalance.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbBalance.font = [UIFont systemFontOfSize:12];
    self.lbBalance.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:self.lbBalance];
    
    self.lbMaxInvestLimit = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(contentView.frame)+16, self.width - 32, 12)];
    self.lbMaxInvestLimit.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbMaxInvestLimit.font = [UIFont boldSystemFontOfSize:12];
    self.lbMaxInvestLimit.textAlignment = NSTextAlignmentLeft;
    self.lbMaxInvestLimit.backgroundColor = [UIColor clearColor];
    self.lbMaxInvestLimit.hidden = YES;
    [self addSubview:self.lbMaxInvestLimit];
}

- (void)setLoanDetail:(LoanDetail *)loanDetail {
    _loanDetail = loanDetail;
    if (loanDetail.baseInfo.maxInvestLimit > 0) {
        self.height = 200;
        self.lbMaxInvestLimit.hidden = NO;
    }else {
        self.height = 168;
        self.lbMaxInvestLimit.hidden = YES;
    }
    
    CGSize size = [loanDetail.baseInfo.title sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}];
    if (loanDetail.baseInfo.classify == CLASSIFY_FOR_TIRO) {
        self.lbNovice.hidden = NO;
        if (size.width + 16 + self.lbNovice.width > self.width - 32) {
            self.lbNovice.x = self.width - self.lbNovice.width - 16;
            self.lbTitle.frame = CGRectMake(16, 0, self.lbNovice.x - 32, 45);
        } else {
            self.lbTitle.frame = CGRectMake(16, 0, size.width, 45);
            self.lbNovice.x = CGRectGetMaxX(self.lbTitle.frame) + 16;
        }
    }else{
        self.lbNovice.hidden = YES;
    }
    
    self.lbTitle.text = loanDetail.baseInfo.title;
    NSString *interestStr = [NSString stringWithFormat:@"%.1f%%", loanDetail.baseInfo.interest];
    self.lbInterest.text = [NSString stringWithFormat:@"%@",interestStr];
    self.lbTerm.text = [NSString stringWithFormat:@"%d%@", [loanDetail.baseInfo.termInfo getTermCount], loanDetail.baseInfo.termInfo.term];
    self.lbBackWay.text = loanDetail.repayType;
    
    NSString *amountStr = [NSString convertMoneyFormate:loanDetail.baseInfo.subjectAmount];
    NSString *amountTips = [NSString stringWithFormat:@"%@ 元",amountStr];
    self.lbBalance.text = amountTips;
    
    NSString *maxInvestLimitStr = [NSString convertMoneyFormate:loanDetail.baseInfo.maxInvestLimit];
    NSString *maxInvestLimitTips = [NSString stringWithFormat:@"个人投资限额 %@ 元",maxInvestLimitStr];
    self.lbMaxInvestLimit.text = maxInvestLimitTips;
}
@end
