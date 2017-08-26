//
//  MSPinView.m
//  showTime
//
//  Created by msj on 2016/12/20.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "MSPinView.h"
#import "MSInputAccessoryView.h"

#define RGB(r,g,b)  [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define DotNumber  6

@interface MSPinTextField : UITextField
@end
@implementation MSPinTextField
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{ return NO; }
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}
@end

@interface MSPinView ()
@property (strong, nonatomic) NSMutableArray *dotArrM;
@property (strong, nonatomic) MSPinTextField *textField;
@end

@implementation MSPinView
- (NSMutableArray *)dotArrM
{
    if (!_dotArrM) {
        _dotArrM = [NSMutableArray array];
    }
    return _dotArrM;
}

- (MSPinTextField *)textField
{
    if (!_textField) {
        _textField = [[MSPinTextField alloc] initWithFrame:self.bounds];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor clearColor];
        _textField.tintColor = [UIColor clearColor];
        _textField.inputAccessoryView = [[MSInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
        _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _textField;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = RGB(171, 171, 171).CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.masksToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
        
        CGFloat width = (self.frame.size.width - 2 * self.layer.borderWidth - (DotNumber - 1) * 0.5) / DotNumber;
        for (int i = 0; i < DotNumber - 1; i++) {
            CGFloat x = (1 + width) + i * (0.5 + width);
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 0.5, self.frame.size.height)];
            line.backgroundColor = RGB(171, 171, 171);
            [self addSubview:line];
        }
        
        CGFloat dotWidth = 12.0;
        CGFloat dotDistance = (width - dotWidth) / 2.0;
        for (int i = 0; i < DotNumber; i++) {
            CGFloat x = (1 + dotDistance) + i * (0.5 + width);
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(x, (self.frame.size.height - dotWidth) / 2.0, dotWidth, dotWidth)];
            dot.backgroundColor = [UIColor blackColor];
            dot.hidden = YES;
            dot.layer.cornerRadius = dotWidth / 2.0;
            [self addSubview:dot];
            [self.dotArrM addObject:dot];
        }
        
        [self addSubview:self.textField];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reset
{
    self.textField.text = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 0; i < DotNumber; i++) {
            UIView *dot = self.dotArrM[i];
            dot.hidden = YES;
        }
    });
}

- (void)toFirstResponder
{
    [self.textField becomeFirstResponder];
}
- (void)unToFirstResponder
{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldTextDidChangeNotification
- (void)textDidChange:(NSNotification *)notification
{
    if (self.textField.text.length > DotNumber) {
        self.textField.text = [self.textField.text substringWithRange:NSMakeRange(0, 6)];
        return;
    }
    
    for (int i = 0; i < DotNumber; i++) {
        UIView *dot = self.dotArrM[i];
        dot.hidden = i < self.textField.text.length ? NO : YES;
    }

    if (self.textField.text.length == DotNumber) {
        if (self.finish) {
            self.finish(self.textField.text);
        }
    }

}
@end
