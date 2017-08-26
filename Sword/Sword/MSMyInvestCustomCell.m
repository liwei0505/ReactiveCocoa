//
//  MSMyInvestCustomCell.m
//  Sword
//
//  Created by lee on 16/11/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyInvestCustomCell.h"
#import "NSString+Ext.h"
#import "NSDate+Add.h"

@interface MSMyInvestCustomCell()

@property (weak, nonatomic) IBOutlet UILabel *investTitle;

@property (weak, nonatomic) IBOutlet UILabel *investTopTitle;
@property (weak, nonatomic) IBOutlet UILabel *investMidTitle;
@property (weak, nonatomic) IBOutlet UILabel *investBottomTitle;

@property (weak, nonatomic) IBOutlet UILabel *investTopAmount;
@property (weak, nonatomic) IBOutlet UILabel *investMidAmount;
@property (weak, nonatomic) IBOutlet UILabel *investBottomAmount;


@end

@implementation MSMyInvestCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setInvestInfo:(InvestInfo *)investInfo {

    _investInfo = investInfo;
    _investTitle.text = _investInfo.loanInfo.title;
    switch (self.investStatus) {
            
        case STATUS_FUNDRAISING:{
            [self setTitle:@"投资金额(元)：" midTitle:@"str_incoming_rate" bottomTitle:@"投资时间："];
            self.investTopAmount.text =  [NSString convertMoneyFormate:_investInfo.investAmount];
            self.investMidAmount.text =  [NSString stringWithFormat:@"%.2f%%", _investInfo.loanInfo.interest];
            self.investBottomAmount.text = _investInfo.investDate;
        }
            break;
        case STATUS_BACKING:{
            
            [self setTitle:@"投资金额(元)：" midTitle:@"str_tobe_receive_interest" bottomTitle:@"str_repay_date"];
            self.investTopAmount.text = [NSString convertMoneyFormate:_investInfo.investAmount];
            self.investMidAmount.text = [NSString convertMoneyFormate:_investInfo.netIncome];
            self.investBottomAmount.text = _investInfo.nextRepayDate;
        }
            break;
        case STATUS_FINISHED:{
            [self setTitle:@"str_incoming" midTitle:@"str_invest_amount" bottomTitle:@"str_invest_time"];
            self.investTopAmount.text = [NSString convertMoneyFormate:_investInfo.investAmount];
            self.investMidAmount.text = [NSString convertMoneyFormate:_investInfo.netIncome];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_investInfo.repayDate/1000];
            self.investBottomAmount.text = [NSString stringWithFormat:@"%ld-%ld-%ld",(long)date.year,(long)date.month,(long)date.day];
        }
            break;
        default:
            break;
    }
}

- (void)setTitle:(NSString *)top midTitle:(NSString *)mid bottomTitle:(NSString *)bottom {
    
    self.investTopTitle.text = NSLocalizedString(top, @"");
    self.investMidTitle.text = NSLocalizedString(mid, @"");
    self.investBottomTitle.text = NSLocalizedString(bottom, @"");

}

@end
