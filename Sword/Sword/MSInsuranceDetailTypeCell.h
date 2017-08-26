//
//  MSInsuranceDetailTypeCell.h
//  Sword
//
//  Created by lee on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSInsuranceTypeView.h"
#import "MSInsuranceDetailViewModel.h"

@interface MSInsuranceDetailTypeCell : UITableViewCell
@property (strong, nonatomic) MSInsuranceDetailViewModel *viewModel;
@property (strong, nonatomic) InsuranceDetail *detail;
@property (copy, nonatomic) void(^selectBlock)(InsuranceTypeSelected type);
+ (MSInsuranceDetailTypeCell *)cellWithTableView:(UITableView *)tableView;
@end
