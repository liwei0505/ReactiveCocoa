//
//  UIButton+Custom.h
//  Sword
//
//  Created by lee on 16/11/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Custom)

+ (UIButton *)ms_itemButtonWithTitle:(NSString *)title;
+ (UIButton *)ms_createPatternButton:(NSString *)title;
+ (UIButton *)ms_buttonWithTitle:(NSString *)title color:(NSString *)color fontSize:(float)size;
+ (UIButton *)ms_buttonWithAttributeTitle:(NSString *)title color:(NSString *)color fontSize:(float)size;

@end
