//
//  MSProgressBar.m
//  Sword
//
//  Created by haorenjie on 16/6/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSProgressBar.h"

@interface MSProgressBar()
{
    UIView *_progressView;
}

@end

@implementation MSProgressBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.backgroundColor = [UIColor colorWithRed:233.0/256.0 green:233.0/256.0 blue:233.0/256.0 alpha:1];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 3.f;
    _progressView = [[UIView alloc] init];
    _progressView.layer.masksToBounds = YES;
    _progressView.layer.cornerRadius = 3.f;
    _progressView.backgroundColor = [UIColor colorWithRed:167.f/255.f green:222.f/255.f blue:124.f/255.f alpha:1.f];
    [self addSubview:_progressView];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat progress = self.progress / 100.f;
    [UIView animateWithDuration:0.5 animations:^{
        _progressView.frame = CGRectMake(0, 0, self.frame.size.width * progress, self.frame.size.height);
    }];
}

- (void)setProgress:(double)progress
{
    _progressView.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    _progress = progress;
    [self setNeedsDisplay];
}

@end
