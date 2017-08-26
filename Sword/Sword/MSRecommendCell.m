//
//  MSRecommendCell.m
//  Sword
//
//  Created by haorenjie on 16/6/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRecommendCell.h"
#import "MSProgressBar.h"
#import "UIView+FrameUtil.h"
#import "MSCircleProgressView.h"

@interface MSRecommendCell()
@property (strong, nonatomic) UILabel *lbInterest;
@property (strong, nonatomic) UILabel *lbAmountTerm;
@property (strong, nonatomic) UILabel *lbRedBag;
@property (strong, nonatomic) MSCircleProgressView *progressView;
@property (strong, nonatomic) UILabel *lbSubjectAmount;
@property (strong, nonatomic) UILabel *lbStartAmount;
@property (strong, nonatomic) UIView *bottomLine;
@end

@implementation MSRecommendCell
+ (MSRecommendCell *)cellWithTableView:(UITableView *)tableView
{
    MSRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSRecommendCell"];
    if (!cell) {
        cell = [[MSRecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSRecommendCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.lbInterest = [[UILabel alloc] init];
        self.lbInterest.textColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        self.lbInterest.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbInterest];
        
        self.lbAmountTerm = [[UILabel alloc] init];
        self.lbAmountTerm.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbAmountTerm.font = [UIFont boldSystemFontOfSize:14];
        self.lbAmountTerm.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbAmountTerm];
        
        self.lbRedBag = [[UILabel alloc] init];
        self.lbRedBag.textColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        self.lbRedBag.font = [UIFont systemFontOfSize:10];
        self.lbRedBag.textAlignment = NSTextAlignmentCenter;
        self.lbRedBag.layer.cornerRadius = 2;
        self.lbRedBag.layer.borderWidth = 0.5;
        self.lbRedBag.layer.masksToBounds = YES;
        self.lbRedBag.layer.borderColor = [UIColor ms_colorWithHexString:@"#F3091C"].CGColor;
        [self.contentView addSubview:self.lbRedBag];
        
        self.lbSubjectAmount = [[UILabel alloc] init];
        self.lbSubjectAmount.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbSubjectAmount.font = [UIFont systemFontOfSize:14];
        self.lbSubjectAmount.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbSubjectAmount];
        
        self.lbStartAmount = [[UILabel alloc] init];
        self.lbStartAmount.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbStartAmount.font = [UIFont systemFontOfSize:14];
        self.lbStartAmount.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbStartAmount];
        
        self.progressView = [[MSCircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.contentView addSubview:self.progressView];
        
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self.contentView addSubview:self.bottomLine];
    }
    return self;
}

- (void)setLoanDetail:(LoanDetail *)loanDetail {
    NSString *ratioStr = nil;
    NSString *interestStr = nil;
    CGFloat ratio = loanDetail.baseInfo.salesRate;
    if (ratio) {
        ratioStr = [NSString stringWithFormat:@"+%.1f%%",ratio];
    } else {
        ratioStr = @"%";
    }
    interestStr = [NSString stringWithFormat:@"%.1f", loanDetail.baseInfo.interest-ratio];
    
    NSMutableAttributedString *interestAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",interestStr,ratioStr]];
    [interestAttributedString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:24]} range:NSMakeRange(0, interestStr.length)];
    [interestAttributedString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} range:NSMakeRange(interestStr.length, ratioStr.length)];
    self.lbInterest.attributedText = interestAttributedString;
    
    self.lbAmountTerm.text = [NSString stringWithFormat:@"%d%@",[loanDetail.baseInfo.termInfo getTermCount], loanDetail.baseInfo.termInfo.term];

    if (loanDetail.baseInfo.redEnvelopeTypes == TYPE_NONE) {
        self.lbRedBag.hidden = YES;
    }else{
        self.lbRedBag.hidden = NO;
        if (loanDetail.baseInfo.redEnvelopeTypes == TYPE_VOUCHERS) {
            self.lbRedBag.text = @"代金劵";
        }else if (loanDetail.baseInfo.redEnvelopeTypes == TYPE_PLUS_COUPONS){
            self.lbRedBag.text = @"加息劵";
        }else if (loanDetail.baseInfo.redEnvelopeTypes == TYPE_EXPERIENS_GOLD){
            self.lbRedBag.text = @"体验金";
        }else{
            self.lbRedBag.text = @"红包";
        }
    }
    
    double subjectAmount = loanDetail.baseInfo.subjectAmount;
    if (subjectAmount >= 10000) {
        subjectAmount /= 10000.00;
        self.lbSubjectAmount.text = [NSString stringWithFormat:@"剩余%.2f万元",subjectAmount];
    } else {
        self.lbSubjectAmount.text = [NSString stringWithFormat:@"剩余%.2f元",subjectAmount];
    }
    
    int startAmount = loanDetail.baseInfo.startAmount;
    if (startAmount >= 10000) {
        float start = startAmount * 1.00 / 10000.00;
        self.lbStartAmount.text = [NSString stringWithFormat:@"%.1f万元起投",start];
    } else {
        self.lbStartAmount.text = [NSString stringWithFormat:@"%d元起投",startAmount];
    }
    
    [self.progressView updateCircleStrokeEnd:loanDetail.baseInfo.progress animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = (self.contentView.width - 32 - self.progressView.width) / 2.0;
    self.lbInterest.frame = CGRectMake(16, 16, width, 24);
    
    CGSize amountTermSize = [self.lbAmountTerm.text sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]}];
    self.lbAmountTerm.frame = CGRectMake(CGRectGetMaxX(self.lbInterest.frame), 0, amountTermSize.width, amountTermSize.height);
    self.lbAmountTerm.bottom = self.lbInterest.bottom;
    
    CGSize redEnvelopeSize = [self.lbRedBag.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]}];
    self.lbRedBag.frame = CGRectMake(CGRectGetMaxX(self.lbAmountTerm.frame)+15, 0, redEnvelopeSize.width + 5, 16);
    self.lbRedBag.centerY = self.lbAmountTerm.centerY;
    
    self.lbSubjectAmount.frame = CGRectMake(16, CGRectGetMaxY(self.lbInterest.frame)+8, width, 20);
    self.lbStartAmount.frame = CGRectMake(CGRectGetMaxX(self.lbSubjectAmount.frame), 0, width, 20);
    self.lbStartAmount.centerY = self.lbSubjectAmount.centerY;
    
    self.progressView.centerY = self.contentView.centerY;
    self.progressView.x = self.contentView.width - self.progressView.width - 16;
    
    self.bottomLine.frame = CGRectMake(16, self.contentView.height - 1, self.contentView.width - 16, 1);
}

@end
