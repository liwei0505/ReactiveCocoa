//
//  MSHelpCell.h
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticeInfo.h"

@interface MSHelpCell : UITableViewCell
@property (strong, nonatomic) NoticeInfo *info;
+ (MSHelpCell *)cellWithTableView:(UITableView *)tableView;
@end
