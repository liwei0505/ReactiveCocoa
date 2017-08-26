//
//  MSAlert.h
//  Sword
//
//  Created by haorenjie on 16/6/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^alert_button_clicked_block_t)(NSInteger buttonIndex);

@interface AlertAction : UIAlertAction;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSInteger buttonIndex;
@end

@interface AlertController : UIAlertController

- (void)setTitleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont;
- (void)setMessageColor:(UIColor *)messageColor messageFont:(UIFont *)messageFont;

@end

@interface MSAlert : NSObject

+ (void)showWithTitle:(NSString *)title
                       message:(NSString *)message
              buttonClickBlock:(alert_button_clicked_block_t)block
             cancelButtonTitle:(NSString *)cancelTitle
             otherButtonTitles:(NSString *)ohterTitle, ...NS_REQUIRES_NIL_TERMINATION;

@end
