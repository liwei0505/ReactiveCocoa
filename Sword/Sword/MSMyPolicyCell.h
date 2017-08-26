//
//  MSMyPolicyCell.h
//  Sword
//
//  Created by msj on 2017/8/9.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsurancePolicy.h"

@interface MSMyPolicyCell : UITableViewCell
+ (MSMyPolicyCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic)InsurancePolicy *insurancePolicy;
@end
