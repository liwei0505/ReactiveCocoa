//
//  MSAlertController.m
//  showTime
//
//  Created by msj on 2016/12/30.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "MSAlertController.h"
#import <objc/runtime.h>

#pragma mark -  MSAlertAction
@implementation MSAlertAction
- (void)setMstextColor:(UIColor *)mstextColor
{
    _mstextColor = mstextColor;
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertAction class], &count);
    for(int i = 0;i < count;i ++){
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        if ([ivarName isEqualToString:@"_titleTextColor"]) {
            [self setValue:mstextColor forKey:@"_titleTextColor"];
            break;
        }
    }
}
@end

#pragma mark -  MSAlertController
@implementation MSAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setMstintColor:(UIColor *)mstintColor
{
    _mstintColor = mstintColor;
    for (MSAlertAction *action in self.actions) {
        if (!action.mstextColor) {
            action.mstextColor = mstintColor;
        }
    }
}

- (void)msSetTitleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont
{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for(int i = 0;i < count;i ++){
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        if ([ivarName isEqualToString:@"_attributedTitle"] && self.title && titleColor) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:self.title attributes:@{NSForegroundColorAttributeName:titleColor,NSFontAttributeName:titleFont}];
            [self setValue:attr forKey:@"_attributedTitle"];
            break;
        }
    }
}
- (void)msSetMssageColor:(UIColor *)mssageColor mssageFont:(UIFont *)mssageFont
{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for(int i = 0;i < count;i ++){
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        if ([ivarName isEqualToString:@"_attributedMessage"] && self.message && mssageColor) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.message attributes:@{NSForegroundColorAttributeName:mssageColor, NSFontAttributeName:mssageFont}];
            [self setValue:attr forKey:@"_attributedMessage"];
            break;
        }
    }
}
@end



