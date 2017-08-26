//
//  MSMyTransferRecordCell.h
//  Sword
//
//  Created by haorenjie on 16/6/29.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebtTradeInfo.h"

@protocol ITransferUndoDelegate <NSObject>

- (void)onTransferUndo:(NSNumber *)debtId;

@end

@interface MSMyTransferRecordCell : UITableViewCell

@property (weak, nonatomic) id<ITransferUndoDelegate> transferUndoDelegate;
@property (strong, nonatomic) DebtTradeInfo *attornInfo;

@end
