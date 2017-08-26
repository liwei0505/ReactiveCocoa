//
//  MSInsuranceDetailContentCell.h
//  Sword
//
//  Created by lee on 2017/8/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSInsuranceDetailViewModel.h"

@interface MSInsuranceDetailContentCell: UITableViewCell
@property (assign, nonatomic) BOOL canScroll;
@property (strong, nonatomic) InsuranceDetail *detail;
@property (strong, nonatomic) MSInsuranceDetailViewModel *viewModel;
+ (MSInsuranceDetailContentCell *)cellWithTableView:(UITableView *)tableView;
@end
