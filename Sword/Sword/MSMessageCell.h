//
//  MSMessageCell.h
//  Sword
//
//  Created by lee on 16/7/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageInfo.h"

@interface MSMessageCell : UITableViewCell

+ (MSMessageCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) MessageInfo *message;

@end
