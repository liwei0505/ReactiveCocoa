//
//  MSCurrentTextField.m
//  Sword
//
//  Created by msj on 2017/4/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentTextField.h"

@implementation MSCurrentTextField

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#F7F7F7"];
        self.layer.borderColor = [UIColor ms_colorWithHexString:@"#E5E5E5"].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

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
    rightViewRect.origin.x -= 12;
    return rightViewRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds.origin.x += 10;
    bounds.size.width -= 40;
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds.origin.x += 10;
    bounds.size.width -= 40;
    return bounds;
}

@end
