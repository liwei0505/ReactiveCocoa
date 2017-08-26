//
//  MSNoticeCell.h
//  Sword
//
//  Created by lee on 16/6/30.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticeInfo.h"

@interface MSNoticeCell : UITableViewCell
@property (strong, nonatomic) NoticeInfo *info;
+ (MSNoticeCell *)cellWithTableView:(UITableView *)tableView;
@end
