//
//  MSAttornTableCell.m
//  Sword
//
//  Created by haorenjie on 16/6/6.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSAttornTableCell.h"
#import "MSTextUtils.h"

@interface MSAttornTableCell()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ivNoviceExclusive;
@property (weak, nonatomic) IBOutlet UILabel *lbEarnings;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbTerm;

@end

@implementation MSAttornTableCell

- (void)setDebtInfo:(DebtDetail *)debtInfo
{
    _debtInfo = debtInfo;
    
    self.lbTitle.text = _debtInfo.baseInfo.loanInfo.baseInfo.title;
    self.ivNoviceExclusive.hidden = (_debtInfo.baseInfo.loanInfo.baseInfo.classify != CLASSIFY_FOR_TIRO);
    
    
    double earnings = _debtInfo.baseInfo.earnings;
    if (earnings >= 10000) {
        earnings /=10000.00;
        self.lbEarnings.text = [NSString stringWithFormat:@"%.2f万",earnings];
    } else {
        
        self.lbEarnings.text = [NSString stringWithFormat:@"%.2f",earnings];
    }
    
    
    float amount = [_debtInfo.baseInfo.soldPrice floatValue];
    if (amount >= 10000) {
        amount /=10000.00;
        NSString *amountStr = [NSString stringWithFormat:@"%.2f万",amount];
        self.lbAmount.attributedText = [MSTextUtils attributedString:amountStr unitLength:1];
    } else {
        
        self.lbAmount.text = [NSString stringWithFormat:@"%.2f",amount];
    }
    
    NSString *format = NSLocalizedString(@"fmt_term_day", nil);
    NSString *term = [NSString stringWithFormat:format, _debtInfo.baseInfo.leftTermCount];
    self.lbTerm.attributedText = [MSTextUtils attributedString:term unitLength:1];
}

@end
