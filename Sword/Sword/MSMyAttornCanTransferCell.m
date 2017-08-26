//
//  MSMyAttornCanTransferCell.m
//  Sword
//
//  Created by haorenjie on 16/6/29.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyAttornCanTransferCell.h"
#import "MJSStatistics.h"

@interface MSMyAttornCanTransferCell()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbInterest;
@property (weak, nonatomic) IBOutlet UILabel *lbEarnings;

@end

@implementation MSMyAttornCanTransferCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setAttornInfo:(DebtTradeInfo *)attornInfo
{
    _attornInfo = attornInfo;
    self.lbTitle.text = _attornInfo.debtInfo.loanInfo.baseInfo.title;
    self.lbTime.text = _attornInfo.investDate;
    self.lbAmount.text = [NSString stringWithFormat:@"%.2f", _attornInfo.incomingPrincipal];
    self.lbInterest.text = _attornInfo.debtInfo.annualInterestRate;
    self.lbEarnings.text = [NSString stringWithFormat:@"%.2f", _attornInfo.incomingInterest];
    
}

- (IBAction)onTransferButtonClicked:(id)sender
{
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:112 control:17 params:nil];
    if (self.transferDelegate) {
        NSInteger debtId = self.attornInfo.debtInfo.debtId;
        [self.transferDelegate onTransferDebt:[NSNumber numberWithInteger:debtId]];
    }
}

@end
