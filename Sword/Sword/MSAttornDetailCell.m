//
//  MSAttronDetailCell.m
//  Sword
//
//  Created by haorenjie on 16/6/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSAttornDetailCell.h"
#import "MSLog.h"
#import "UIColor+StringColor.h"

@interface MSAttornDetailCell()

@property (weak, nonatomic) IBOutlet UILabel *lbKey;

@end

@implementation MSAttornDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setType:(NSInteger)type
{
    _type = type;

    NSString *keyName = @"";
    switch (type) {
        case ATTORN_FIELD_EXPECTED_EARNINGS: {
            keyName = NSLocalizedString(@"str_expected_earnings", nil);
        } break;
        case ATTORN_FIELD_LEFT_TERM: {
            keyName = NSLocalizedString(@"str_left_term", nil);
        } break;
        case ATTORN_FIELD_DEBT_VALUE: {
            keyName = NSLocalizedString(@"str_debt_value", nil);
        } break;
        case ATTORN_FIELD_INCOMING_WAY: {
            keyName = NSLocalizedString(@"str_incoming_way", nil);
        } break;
        case ATTORN_FIELD_REPAYMENT_RECEIVE_DATE: {
            keyName = NSLocalizedString(@"str_repayment_receiving_date", nil);
        } break;
        case ATTORN_FIELD_SCALE_OF_FINANCING: {
            keyName = NSLocalizedString(@"str_scale_of_financing", nil);
        } break;
        case ATTORN_FIELD_INVEST_TERM: {
            keyName = NSLocalizedString(@"str_invest_term", nil);
        } break;
        case ATTORN_FIELD_REPAYMENT_WAY: {
            keyName = NSLocalizedString(@"str_repayment_way", nil);
        } break;
        case ATTORN_FIELD_MIN_INVESTMENT: {
            keyName = NSLocalizedString(@"str_min_investment", nil);
        } break;
        case ATTORN_FIELD_VALUE_DATE: {
            keyName = NSLocalizedString(@"str_value_date", nil);
        } break;
        case ATTORN_FIELD_CEASE_DATE: {
            keyName = NSLocalizedString(@"str_cease_date", nil);
        } break;
        default: {
            [MSLog warning:@"Unexpected attorn field type: %d", type];
        } break;
    }
    
    self.lbKey.text = keyName;
}

- (void)updateInfo:(DebtDetail *)debtInfo withIndex:(NSInteger)index{
    
    NSString *value = @"";
    switch (self.type) {
        case ATTORN_FIELD_EXPECTED_EARNINGS: {
            NSString *format = NSLocalizedString(@"fmt_reward_amount", nil);
            value = [NSString stringWithFormat:format, debtInfo.expectedEarning];
        } break;
        case ATTORN_FIELD_LEFT_TERM: {
            NSString *format = NSLocalizedString(@"fmt_term_day", nil);
            value = [NSString stringWithFormat:format, debtInfo.baseInfo.leftTermCount];
        } break;
        case ATTORN_FIELD_DEBT_VALUE: {
            value = debtInfo.baseInfo.value;
        } break;
        case ATTORN_FIELD_INCOMING_WAY: {
            value = debtInfo.investType;
        } break;
        case ATTORN_FIELD_REPAYMENT_RECEIVE_DATE: {
            value = debtInfo.repayDate;
        } break;
        case ATTORN_FIELD_SCALE_OF_FINANCING: {
            
            NSString *format = NSLocalizedString(@"fmt_reward_amount", nil);
            double amount = debtInfo.baseInfo.loanInfo.totalAmount;
            if (amount >= 10000) {
                amount /= 10000.00;
                value = [NSString stringWithFormat:NSLocalizedString(@"fmt_reward_amount2", @""),amount];
            } else {
                
                value = [NSString stringWithFormat:format,amount];
            }
            
        } break;
        case ATTORN_FIELD_INVEST_TERM: {
            value = [NSString stringWithFormat:@"%d%@", debtInfo.baseInfo.loanInfo.baseInfo.termInfo.termCount,debtInfo.baseInfo.loanInfo.baseInfo.termInfo.term];
        } break;
        case ATTORN_FIELD_REPAYMENT_WAY: {
            value = debtInfo.baseInfo.loanInfo.repayType;
        } break;
        case ATTORN_FIELD_MIN_INVESTMENT: {
            NSString *format = NSLocalizedString(@"fmt_reward_amount", nil);
            value = [NSString stringWithFormat:format, (double)debtInfo.baseInfo.loanInfo.baseInfo.startAmount];
        } break;
        case ATTORN_FIELD_VALUE_DATE: {
            value = debtInfo.baseInfo.loanInfo.interestBeginTime;
        } break;
        case ATTORN_FIELD_CEASE_DATE: {
            value = debtInfo.baseInfo.loanInfo.interestEndTime;
        } break;
    }
    self.lbValue.text = value;
    
    if (index == 0) {
        self.lbValue.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
    }else{
        self.lbValue.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    }
    
}

@end
