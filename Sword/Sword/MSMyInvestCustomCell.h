//
//  MSMyInvestCustomCell.h
//  Sword
//
//  Created by lee on 16/11/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InvestInfo.h"

@interface MSMyInvestCustomCell : UITableViewCell

@property (strong, nonatomic) InvestInfo *investInfo;
@property (assign, nonatomic) InvestStatus investStatus;

@end
