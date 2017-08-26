//
//  MSInsureObjectCell.h
//  Sword
//
//  Created by lee on 2017/8/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSInsuranceDetailViewModel.h"

@interface MSInsureObjectCell : UITableViewCell
+ (MSInsureObjectCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) MSInsuranceDetailViewModel *viewModel;
@property (strong, nonatomic) InsuranceDetail *detail;
@property (copy, nonatomic) void(^switchBlock)(BOOL on);
@end
