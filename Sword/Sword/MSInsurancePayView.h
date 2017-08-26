//
//  MSInsurancePayView.h
//  Sword
//
//  Created by msj on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSInsurancePayView : UIView
@property (copy, nonatomic) void (^payBlock)(PayType payType);
@property (copy, nonatomic) void (^cancelBlock)(void);
- (void)show;
- (void)dismiss;
@end

//MSInsurancePayView *payView = [[MSInsurancePayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//[payView show];
