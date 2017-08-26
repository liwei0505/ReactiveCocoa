//
//  MSInsuranceCell.h
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsuranceInfo.h"

@interface MSInsuranceCell : UITableViewCell
+ (MSInsuranceCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) InsuranceInfo *insuranceInfo;
@end
