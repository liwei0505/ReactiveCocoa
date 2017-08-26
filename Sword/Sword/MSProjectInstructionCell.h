//
//  MSProjectInstructionCell.h
//  Sword
//
//  Created by haorenjie on 16/6/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSProjectInstructionModel : NSObject
@property (copy, nonatomic, readonly) NSString *title;
@property (assign, nonatomic) ProjectInstructionType type;
@end

@interface MSProjectInstructionCell : UITableViewCell
+ (MSProjectInstructionCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) MSProjectInstructionModel *model;
@end
