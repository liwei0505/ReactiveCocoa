//
//  MSVerifyCodeTextField.m
//  Sword
//
//  Created by msj on 2017/3/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSVerifyCodeTextField.h"

@implementation MSVerifyCodeTextField
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{ return NO; }
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}
- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewRect = [super rightViewRectForBounds:bounds];
    rightViewRect.origin.x -= 10;
    return rightViewRect;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect leftViewRect = [super leftViewRectForBounds:bounds];
    leftViewRect.origin.x += 16;
    return leftViewRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds.origin.x += 46;
    bounds.size.width -= 150;
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds.origin.x += 46;
    bounds.size.width -= 150;
    return bounds;
}

@end
