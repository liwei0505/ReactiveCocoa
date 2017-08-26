//
//  MSSetTradePasswordView.m
//  Sword
//
//  Created by lee on 2017/7/3.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSSetTradePasswordView.h"
#define PASSWORDNUMBER 6

@interface MSSetTradePasswordView()<UIKeyInput>

@property (nonatomic, strong) NSMutableString *textStore;

@end

@implementation MSSetTradePasswordView

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (BOOL)hasText {
    return _textStore.length > 0;
}

- (void)insertText:(NSString *)text {
    
    if (self.textStore.length == PASSWORDNUMBER) {
        return;
    }
    
    [self.textStore appendString:text];
    [self setNeedsDisplay];
    
    if (self.textStore.length == PASSWORDNUMBER && [self.delegate respondsToSelector:@selector(passWordCompleteInput:)]) {
        [self.delegate passWordCompleteInput:self.textStore];

    }
}

- (void)deleteBackward {
    
    if (self.textStore.length > 0) {
        [self.textStore deleteCharactersInRange:NSMakeRange(self.textStore.length-1, 1)];
    }
    [self setNeedsDisplay];
}

- (void)clear {
    self.textStore = nil;
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}


- (void)drawRect:(CGRect)rect {
    
    CGFloat height = rect.size.height;
    CGFloat margin = height*0.5;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (int i=0; i<PASSWORDNUMBER; i++) {
        CGContextAddRect(context, CGRectMake(i*(8+height), 0, height, height));
        
    }
    [[UIColor whiteColor] setFill];
    [[UIColor ms_colorWithHexString:@"E4E4E4"] setStroke];
    CGContextSetLineWidth(context, 1);
    CGContextDrawPath(context, kCGPathFillStroke);

    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    for (int i=0; i<self.textStore.length; i++) {
        CGContextAddArc(context, margin+i*(height+8), margin, 4, 0, M_PI*2, YES);
        CGContextDrawPath(context, kCGPathFill);
    }
    
}

- (NSMutableString *)textStore {

    if (!_textStore) {
        _textStore = [NSMutableString stringWithCapacity:PASSWORDNUMBER];
    }
    return _textStore;
}

@end
