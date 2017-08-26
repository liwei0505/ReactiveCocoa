//
//  MSNewNoviceCell.h
//  Sword
//
//  Created by msj on 2017/6/13.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSNewNoviceCell : UITableViewCell
+ (MSNewNoviceCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) MSSectionList *list;
@property (copy, nonatomic) void (^block)(NSNumber *loanId);
@end
