//
//  MSHomeCurrentCell.h
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentInfo.h"

@interface MSHomeCurrentCell : UITableViewCell
+ (MSHomeCurrentCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) CurrentInfo *currentInfo;
@end
