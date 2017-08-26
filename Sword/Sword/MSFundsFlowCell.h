//
//  MSFundsFlowCell.h
//  Sword
//
//  Created by lee on 16/6/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FundsFlow.h"
#import "UIColor+StringColor.h"

@interface MSFundsFlowCell : UITableViewCell

+ (MSFundsFlowCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) FundsFlow *fundsFlow;

@end
