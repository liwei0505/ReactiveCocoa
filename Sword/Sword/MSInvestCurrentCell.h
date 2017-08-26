//
//  MSInvestCurrentCell.h
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSInvestCurrentCell : UITableViewCell
+ (MSInvestCurrentCell *)cellWithTableView:(UITableView *)tableView;
- (void)updateWithCurrentInfo:(CurrentInfo *)currentInfo index:(NSInteger)index;
@end
