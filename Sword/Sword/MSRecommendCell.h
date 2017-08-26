//
//  MSRecommendCell.h
//  Sword
//
//  Created by haorenjie on 16/6/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoanDetail.h"

@interface MSRecommendCell : UITableViewCell

+ (MSRecommendCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic)LoanDetail *loanDetail;

@end
