//
//  MSRiskAnswerCell.h
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RiskInfo.h"

@interface MSRiskAnswerCell : UITableViewCell
+ (MSRiskAnswerCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) RiskDetailInfo *riskDetailInfo;
@end
