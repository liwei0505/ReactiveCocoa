//
//  MSNewPointCell.h
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PointRecord;

@interface MSNewPointCell : UITableViewCell
+ (MSNewPointCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) PointRecord *pointRecord;
@end
