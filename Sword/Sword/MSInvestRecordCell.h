//
//  MSInvestRecordCell.h
//  Sword
//
//  Created by haorenjie on 16/6/14.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InvestRecord.h"

@interface MSInvestRecordCell : UITableViewCell
+ (MSInvestRecordCell *)cellWithTableView:(UITableView *)tableView;
@property (weak, nonatomic)InvestRecord *recordInfo;

@end
