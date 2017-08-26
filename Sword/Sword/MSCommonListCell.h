//
//  MSCommonListCell.h
//  Sword
//
//  Created by haorenjie on 2017/1/3.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSMyInfoModel.h"

@interface MSCommonListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIButton *avatar;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (strong, nonatomic) MSMyInfoModel *model;

@end
