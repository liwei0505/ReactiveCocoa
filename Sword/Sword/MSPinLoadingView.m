//
//  MSPinLoadingView.m
//  showTime
//
//  Created by msj on 2016/12/21.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "MSPinLoadingView.h"
#import "UIImage+GIF.h"
#import "UIColor+StringColor.h"
#import "MSInputAccessoryView.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width

@interface MSPinLoadingTextField : UITextField
@end
@implementation MSPinLoadingTextField
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{ return NO; }
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{ return NO; }
@end

@interface MSPinLoadingView ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTips;
@property (strong, nonatomic) MSPinLoadingTextField *textField;
@end

@implementation MSPinLoadingView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
        
        self.textField = [[MSPinLoadingTextField alloc] initWithFrame:self.bounds];
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.textColor = [UIColor clearColor];
        self.textField.tintColor = [UIColor clearColor];
        self.textField.inputAccessoryView = [[MSInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:self.textField];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 50)/2.0, (self.frame.size.height - 50)/2.0, 50, 50)];
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2.0;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = [UIImage imageNamed:@"pay_loading"];
        [self addSubview:self.imageView];
        
        self.lbTips = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 13, self.frame.size.width, 14)];
        self.lbTips.textAlignment = NSTextAlignmentCenter;
        self.lbTips.font = [UIFont systemFontOfSize:14];
        self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#000000"];
        [self addSubview:self.lbTips];
        self.lbTips.text = @"验证中...";
        
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (void)startRotation
{
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    ani.fromValue = @0;
    ani.toValue = @(2 * M_PI);
    ani.duration = 0.6;
    ani.fillMode = kCAFillModeForwards;
    ani.removedOnCompletion = NO;
    ani.repeatCount = MAXFLOAT;
    [self.imageView.layer addAnimation:ani forKey:@"ms_rotation"];
}
- (void)stopRotation
{
    [self.imageView.layer removeAnimationForKey:@"ms_rotation"];
}
- (void)toFirstResponder
{
    [self.textField becomeFirstResponder];
}
- (void)unToFirstResponder
{
    [self.textField resignFirstResponder];
}

- (void)setTips:(NSString *)tips
{
    _tips = tips;
    self.lbTips.text = tips;
}
@end
