//
//  MSInsuranceDetailBottomView.h
//  Sword
//
//  Created by lee on 2017/8/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSInsuranceBottomButton : UIButton

@end

@interface MSInsuranceDetailBottomView : UIView
@property (copy, nonatomic) void(^clickBlock)(void);
@property (strong, nonatomic) UILabel *lbAmount;
@property (strong, nonatomic) NSString *phone;
@end
