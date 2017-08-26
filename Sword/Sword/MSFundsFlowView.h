//
//  MSFundsFlowView.h
//  Sword
//
//  Created by msj on 2017/7/4.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSFundsFlowView : UIView
- (instancetype)initWithFrame:(CGRect)frame point:(CGPoint)point;
@property (copy, nonatomic) void (^blcok)(int recordTypeIndex);
@end
