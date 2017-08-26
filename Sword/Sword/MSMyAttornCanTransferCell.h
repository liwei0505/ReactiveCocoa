//
//  MSMyAttornCanTransferCell.h
//  Sword
//
//  Created by haorenjie on 16/6/29.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebtTradeInfo.h"

@protocol IDebtTransferDelegate <NSObject>

- (void)onTransferDebt:(NSNumber *)debtId;

@end

@interface MSMyAttornCanTransferCell : UITableViewCell

@property (weak, nonatomic) id<IDebtTransferDelegate> transferDelegate;
@property (strong, nonatomic) DebtTradeInfo *attornInfo;

@end
