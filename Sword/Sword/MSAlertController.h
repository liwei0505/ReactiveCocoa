//
//  MSAlertController.h
//  showTime
//
//  Created by msj on 2016/12/30.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSAlertAction : UIAlertAction
@property (strong, nonatomic)  UIColor *mstextColor; /**< 按钮title字体颜色 */
@end

@interface MSAlertController : UIAlertController
@property (strong, nonatomic) UIColor *mstintColor; /**< 统一按钮样式 不写系统默认的蓝色 */
- (void)msSetTitleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont;
- (void)msSetMssageColor:(UIColor *)mssageColor mssageFont:(UIFont *)mssageFont;
@end
