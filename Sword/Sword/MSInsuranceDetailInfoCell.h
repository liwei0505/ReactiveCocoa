//
//  MSInsuranceDetailInfoCell.h
//  Sword
//
//  Created by lee on 2017/8/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSInsuranceDetailViewModel.h"

@interface MSInsuranceDetailInfoCell : UITableViewCell
@property (strong, nonatomic) MSInsuranceDetailViewModel *viewModel;
@property (strong, nonatomic) InsuranceDetail *detail;
@property (copy, nonatomic) void(^updateCountBlock)(int count);
+ (MSInsuranceDetailInfoCell *)cellWithTableView:(UITableView *)tableView;
@end
