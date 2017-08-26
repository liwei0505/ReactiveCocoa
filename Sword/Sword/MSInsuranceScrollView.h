//
//  MSInsuranceScrollView.h
//  Sword
//
//  Created by lee on 2017/8/26.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSInsuranceDetailViewModel.h"

@interface MSInsuranceScrollView : UIScrollView

@property (strong, nonatomic) MSInsuranceDetailViewModel *viewModel;
@property (strong, nonatomic) NSDictionary *imageDict;
@property (copy, nonatomic) void(^changeHeightBlock)();
- (void)setupSubviews;

@end
