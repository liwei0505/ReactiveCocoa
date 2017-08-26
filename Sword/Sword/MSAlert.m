//
//  MSAlert.m
//  Sword
//
//  Created by haorenjie on 16/6/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSAlert.h"
#import <objc/runtime.h>
#import "MSAppDelegate.h"
#import "MSConfig.h"

@implementation AlertAction
- (void)setTextColor:(UIColor *)textColor {
    
    _textColor = textColor;
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertAction class], &count);
    for(int i = 0;i < count;i ++){
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        if ([ivarName isEqualToString:@"_titleTextColor"]) {
            [self setValue:textColor forKey:@"_titleTextColor"];
            break;
        }
    }
}
@end

@implementation AlertController

- (void)setTitleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont {

    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for(int i = 0;i < count;i ++) {
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        if ([ivarName isEqualToString:@"_attributedTitle"] && self.title && titleColor) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:self.title attributes:@{NSForegroundColorAttributeName:titleColor,NSFontAttributeName:titleFont}];
            [self setValue:attr forKey:@"_attributedTitle"];
            break;
        }
    }
}

- (void)setMessageColor:(UIColor *)messageColor messageFont:(UIFont *)messageFont {

    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for(int i = 0;i < count;i ++){
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        if ([ivarName isEqualToString:@"_attributedMessage"] && self.message && messageColor) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.message attributes:@{NSForegroundColorAttributeName:messageColor, NSFontAttributeName:messageFont}];
            [self setValue:attr forKey:@"_attributedMessage"];
            break;
        }
    }
}

@end

@interface MSAlert()<UIAlertViewDelegate>

@property (copy, nonatomic) alert_button_clicked_block_t clickedBlock;

@end

@implementation MSAlert

+ (void)showWithTitle:(NSString *)title
                       message:(NSString *)message
              buttonClickBlock:(alert_button_clicked_block_t)block
             cancelButtonTitle:(NSString *)cancelTitle
             otherButtonTitles:(NSString *)otherTitles, ...NS_REQUIRES_NIL_TERMINATION
{
    
    AlertController *alertController = [AlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController setTitleColor:UIColorFromRGB(0x555555) titleFont:[UIFont systemFontOfSize:16.0]];
    [alertController setMessageColor:UIColorFromRGB(0x555555) messageFont:[UIFont systemFontOfSize:16.0]];
    AlertAction *cancel = [AlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        AlertAction *act = (AlertAction *)action;
        block(act.buttonIndex);
    }];
    
    [cancel setTextColor:UIColorFromRGB(0x555555)];
    cancel.buttonIndex = 0;
    [alertController addAction:cancel];

    if (otherTitles) {
        NSInteger index = 1;
        AlertAction *action = [AlertAction actionWithTitle:otherTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            AlertAction *act = (AlertAction *)action;
            block(act.buttonIndex);
        }];
        action.buttonIndex = index++;
        [action setTextColor:MS_COLOR_MAIN];
        [alertController addAction:action];
        
        va_list args;
        va_start(args, otherTitles);
        NSString *buttonTitle = (NSString *)va_arg(args, NSString *);
        while (buttonTitle) {
            AlertAction *action = [AlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                AlertAction *act = (AlertAction *)action;
                block(act.buttonIndex);
            }];
            [action setTextColor:MS_COLOR_MAIN];
            action.buttonIndex = index++;
            [alertController addAction:action];
            buttonTitle = (NSString *)va_arg(args, NSString *);
        }
        va_end(args);
    }
    
    MSNavigationController *nav = [[MSAppDelegate getInstance] getNavigationController];
    if(nav.presentedViewController) {
        [nav.visibleViewController presentViewController:alertController animated:YES completion:nil];
    } else {
        [nav presentViewController:alertController animated:YES completion:nil];
    }

}

@end
