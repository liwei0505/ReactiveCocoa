//
//  MSInvestTableCell.h
//  Sword
//
//  Created by haorenjie on 16/6/6.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoanDetail.h"

@interface MSInvestTableCell : UITableViewCell
+ (MSInvestTableCell *)cellWithTableView:(UITableView *)tableView;
- (void)updateWithLoanDetail:(LoanDetail *)loanInfo type:(MSSectionListType)type;
@end
