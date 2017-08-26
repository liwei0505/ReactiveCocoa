//
//  MSMyTransferRecordCell.m
//  Sword
//
//  Created by haorenjie on 16/6/29.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyTransferRecordCell.h"
#import "MSLog.h"
#import "MJSStatistics.h"

@interface MSMyTransferRecordCell()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;

@end

@implementation MSMyTransferRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction)onUndoButtonClicked:(id)sender
{
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:113 control:18 params:nil];
    if (self.transferUndoDelegate && [self.transferUndoDelegate respondsToSelector:@selector(onTransferUndo:)]) {
        NSNumber *debtId = [NSNumber numberWithInteger:_attornInfo.debtInfo.debtId];
        [self.transferUndoDelegate onTransferUndo:debtId];
    }
}

- (void)setAttornInfo:(DebtTradeInfo *)attornInfo
{
    _attornInfo = attornInfo;
    self.lbTitle.text = _attornInfo.debtInfo.loanInfo.baseInfo.title;
    self.lbAmount.text = _attornInfo.debtInfo.soldPrice;
    self.lbDate.text = _attornInfo.tradeDate;
    
    if (_attornInfo.debtInfo.status == STATUS_TRANSFERRING) {
        self.btnUndo.hidden = NO;
        self.lbStatus.text = NSLocalizedString(@"str_transferring", nil);
    } else if (_attornInfo.debtInfo.status == STATUS_TRANSFERRED) {
        self.btnUndo.hidden = YES;
        self.lbStatus.text = NSLocalizedString(@"str_transferred", nil);
    } else {
        [MSLog warning:@"Unrecognized status: %d", _attornInfo.debtInfo.status];
    }
}

@end
