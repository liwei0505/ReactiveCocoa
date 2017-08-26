//
//  MSMyAttornBoughtCell.m
//  Sword
//
//  Created by haorenjie on 16/6/29.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyAttornBoughtCell.h"

@interface MSMyAttornBoughtCell()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;

@end

@implementation MSMyAttornBoughtCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setAttornInfo:(DebtTradeInfo *)attornInfo
{
    _attornInfo = attornInfo;
    self.lbTitle.text = _attornInfo.debtInfo.loanInfo.baseInfo.title;
    self.lbAmount.text = _attornInfo.debtInfo.soldPrice;
    self.lbDate.text = _attornInfo.tradeDate;
}

@end
