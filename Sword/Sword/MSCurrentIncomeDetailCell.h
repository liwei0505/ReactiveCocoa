//
//  MSCurrentIncomeDetailCell.h
//  Sword
//
//  Created by lee on 17/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentEarnings.h"

@interface MSCurrentIncomeDetailCell : UITableViewCell

@property (strong, nonatomic) CurrentEarnings *earnings;
+ (MSCurrentIncomeDetailCell *)cellWithTable:(UITableView *)tableView;

@end
