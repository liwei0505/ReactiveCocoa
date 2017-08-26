//
//  MSSupportBankCell.h
//  Sword
//
//  Created by lee on 16/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BankInfo.h"

@interface MSSupportBankCell : UITableViewCell

@property (nonatomic, strong) BankInfo *bankInfo;
+ (MSSupportBankCell *)cellWithTableView:(UITableView *)tableView;

@end
