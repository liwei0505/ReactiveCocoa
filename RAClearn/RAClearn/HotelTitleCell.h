//
//  HotelTitleCell.h
//  RAClearn
//
//  Created by lw on 2018/4/17.
//  Copyright © 2018年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotelTitleViewModel.h"

@interface HotelTitleCell : UIView
- (void)bindViewModel:(HotelTitleViewModel *)viewModel;
@end
