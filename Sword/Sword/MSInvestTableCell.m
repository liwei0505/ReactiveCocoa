//
//  MSInvestTableCell.m
//  Sword
//
//  Created by haorenjie on 16/6/6.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInvestTableCell.h"
#import "MSProgressBar.h"
#import "MSTextUtils.h"
#import "UIView+FrameUtil.h"
#import "MSCircleProgressView.h"
#import "NSDate+Add.h"
#import "MSConfig.h"

@interface MSInvestTableCell()
@property (strong, nonatomic) UILabel *lbInterest;
@property (strong, nonatomic) UILabel *lbAmountTerm;
@property (strong, nonatomic) UILabel *lbRedBag;
@property (strong, nonatomic) UILabel *lbNovice;
@property (strong, nonatomic) MSCircleProgressView *progressView;
@property (strong, nonatomic) UILabel *lbSubjectAmount;
@property (strong, nonatomic) UILabel *lbStartAmount;
@property (strong, nonatomic) UIView *bottomLine;
// @property (strong, nonatomic) UIImageView *bgImageView;

@property (strong, nonatomic) UILabel *lbBeginDay;
@property (strong, nonatomic) UILabel *lbBeginHour;
@end

@implementation MSInvestTableCell

+ (MSInvestTableCell *)cellWithTableView:(UITableView *)tableView
{
    MSInvestTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSInvestTableCell"];
    if (!cell) {
        cell = [[MSInvestTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSInvestTableCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.lbInterest = [[UILabel alloc] init];
        self.lbInterest.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbInterest];
        
        self.lbAmountTerm = [[UILabel alloc] init];
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
        
        self.lbNovice = [[UILabel alloc] init];
        self.lbNovice.font = [UIFont systemFontOfSize:10];
        self.lbNovice.textColor = [UIColor whiteColor];
        self.lbNovice.backgroundColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        self.lbNovice.textAlignment = NSTextAlignmentCenter;
        self.lbNovice.layer.cornerRadius = 2;
        self.lbNovice.layer.masksToBounds = YES;
        self.lbNovice.text = @"新手专享";
        [self.contentView addSubview:self.lbNovice];
        
        self.lbSubjectAmount = [[UILabel alloc] init];
        self.lbSubjectAmount.font = [UIFont systemFontOfSize:14];
        self.lbSubjectAmount.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbSubjectAmount];
        
        self.lbStartAmount = [[UILabel alloc] init];
        self.lbStartAmount.font = [UIFont systemFontOfSize:14];
        self.lbStartAmount.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbStartAmount];
        
        self.progressView = [[MSCircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.contentView addSubview:self.progressView];
        self.progressView.hidden = YES;
    
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self.contentView addSubview:self.bottomLine];
        
//        self.bgImageView = [[UIImageView alloc] init];
//        self.bgImageView.image = [UIImage imageNamed:@"ms_soldout_image"];
//        [self.contentView addSubview:self.bgImageView];
//        self.bgImageView.hidden = YES;
        
        self.lbBeginDay = [[UILabel alloc] init];
        self.lbBeginDay.font = [UIFont systemFontOfSize:14];
        self.lbBeginDay.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbBeginDay.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.lbBeginDay];
        self.lbBeginDay.hidden = YES;
        
        self.lbBeginHour = [[UILabel alloc] init];
        self.lbBeginHour.font = [UIFont boldSystemFontOfSize:14];
        self.lbBeginHour.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbBeginHour.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.lbBeginHour];
        self.lbBeginHour.hidden = YES;
        
    }
    return self;
}

- (void)updateWithLoanDetail:(LoanDetail *)loanDetail type:(MSSectionListType)type {
    
    if (type == MSSectionListTypeWillStart || type == MSSectionListTypeInvesting) {
        self.lbAmountTerm.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbSubjectAmount.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbStartAmount.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    }else {
        self.lbAmountTerm.textColor = [UIColor ms_colorWithHexString:@"#C8C8C8"];
        self.lbSubjectAmount.textColor = [UIColor ms_colorWithHexString:@"#C8C8C8"];
        self.lbStartAmount.textColor = [UIColor ms_colorWithHexString:@"#C8C8C8"];
    }
    
    if (type == MSSectionListTypeInvesting) {
        self.progressView.hidden = NO;
//        self.bgImageView.hidden = YES;
        self.lbBeginDay.hidden = YES;
        self.lbBeginHour.hidden = YES;
        
    } else if (type == MSSectionListTypeWillStart){
        self.progressView.hidden = YES;
//        self.bgImageView.hidden = YES;
        self.lbBeginDay.hidden = NO;
        self.lbBeginHour.hidden = NO;
    } else {
        self.progressView.hidden = YES;
//        self.bgImageView.hidden = NO;
        self.lbBeginDay.hidden = YES;
        self.lbBeginHour.hidden = YES;
    }
    
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
    if (type == MSSectionListTypeWillStart || type == MSSectionListTypeInvesting) {
        [interestAttributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#F3091C"]} range:NSMakeRange(0, interestAttributedString.length)];
    }else {
        [interestAttributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#C8C8C8"]} range:NSMakeRange(0, interestAttributedString.length)];
    }
    self.lbInterest.attributedText = interestAttributedString;
    
    self.lbAmountTerm.text = [NSString stringWithFormat:@"%d%@",[loanDetail.baseInfo.termInfo getTermCount], loanDetail.baseInfo.termInfo.term];
    
    if (loanDetail.baseInfo.classify == CLASSIFY_FOR_TIRO) {
        self.lbNovice.hidden = NO;
    }else{
        self.lbNovice.hidden = YES;
    }
    
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
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:loanDetail.baseInfo.raiseBeginTime/1000];
    if (date.isToday) {
        self.lbBeginDay.text = @"今天";
    } else {
        self.lbBeginDay.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)date.year,(long)date.month,(long)date.day];
    }
    self.lbBeginHour.text = [NSString stringWithFormat:@"%02ld:%02ld 开抢",(long)date.hour,(long)date.minute];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = (self.contentView.width - 28 - 15) / 2.0;
    
    CGSize interestSize = [self.lbInterest.attributedText boundingRectWithSize:CGSizeMake(width, 24) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.lbInterest.frame = CGRectMake(14, 16, interestSize.width, 24);
    self.lbNovice.frame = CGRectMake(CGRectGetMaxX(self.lbInterest.frame)+8, 0, 48, 16);
    self.lbNovice.bottom = self.lbInterest.bottom;
    
    CGSize amountTermSize = [self.lbAmountTerm.text sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]}];
    self.lbAmountTerm.frame = CGRectMake(144*scaleX, 0, amountTermSize.width, amountTermSize.height);
    self.lbAmountTerm.bottom = self.lbInterest.bottom;
    
    CGSize redEnvelopeSize = [self.lbRedBag.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10]}];
    self.lbRedBag.frame = CGRectMake(CGRectGetMaxX(self.lbAmountTerm.frame)+8, 0, redEnvelopeSize.width + 5, 16);
    self.lbRedBag.bottom = self.lbAmountTerm.bottom;
    
    self.lbSubjectAmount.frame = CGRectMake(14, CGRectGetMaxY(self.lbInterest.frame)+8, width, 20);
    self.lbStartAmount.frame = CGRectMake(144*scaleX, 0, width, 20);
    self.lbStartAmount.centerY = self.lbSubjectAmount.centerY;
    
    self.progressView.centerY = self.contentView.centerY;
    self.progressView.x = self.contentView.width - self.progressView.width - 16;
    
    self.bottomLine.frame = CGRectMake(14, self.contentView.height - 1, self.contentView.width - 16, 1);
//    self.bgImageView.frame = CGRectMake(self.contentView.width - 114, self.contentView.height - 84, 114, 84);
    
    self.lbBeginHour.frame = CGRectMake(self.contentView.width - width - 14, 0, width, 20);
    self.lbBeginHour.bottom = self.lbInterest.bottom;
    self.lbBeginDay.frame = CGRectMake(self.contentView.width - width - 14, 0, width, 20);
    self.lbBeginDay.centerY = self.lbSubjectAmount.centerY;
}
@end
