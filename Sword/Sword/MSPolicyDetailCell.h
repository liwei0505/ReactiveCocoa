//
//  MSPolicyDetailCell.h
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPolicyDetailModel.h"

@interface MSPolicyDetailCell : UITableViewCell
+ (MSPolicyDetailCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic)MSPolicyDetailModel *model;
@end
