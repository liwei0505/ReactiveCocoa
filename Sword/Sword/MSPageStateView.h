//
//  MSPageStateView.h
//  showTime
//
//  Created by msj on 2017/5/15.
//  Copyright © 2017年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPageStateMachineConst.h"

@interface MSPageStateView : UIView
@property (assign, nonatomic) MSPageStateMachineType state;
@property (copy, nonatomic) void (^refreshBlock)(void);
- (void)showInView:(UIView *)superView;
@end
