//
//  MSInsurancePolicyDetailCell.h
//  Sword
//
//  Created by lee on 2017/8/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSInsurancePolicyDetailCell : UITableViewCell
@property (strong, nonatomic) InsuranceDuty *duty;
+ (MSInsurancePolicyDetailCell *)cellWithTableView:(UITableView *)tableView;
@end
