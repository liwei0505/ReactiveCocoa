//
//  MSCurrentDetailCell.h
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentDetail.h"

@interface MSCurrentDetailCell : UITableViewCell
+ (MSCurrentDetailCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) CurrentProductItem *productItem;
@end
