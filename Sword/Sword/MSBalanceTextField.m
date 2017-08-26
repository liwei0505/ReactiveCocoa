//
//  MSBalanceTextField.m
//  Sword
//
//  Created by msj on 2017/6/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBalanceTextField.h"

@implementation MSBalanceTextField
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{ return NO; }
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect frame = [super placeholderRectForBounds:bounds];
    frame.origin.y += 3;
    return frame;
}
@end
