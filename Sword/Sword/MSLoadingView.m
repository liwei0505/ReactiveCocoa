//
//  MSDrawView.m
//  showTime
//
//  Created by msj on 16/9/1.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "MSLoadingView.h"

@interface MSLoadingView ()
@property (strong, nonatomic) UILabel *lbTitle;
@end


@implementation MSLoadingView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - 10)/2.0, frame.size.width, 10)];
        self.lbTitle.font = [UIFont systemFontOfSize:10];
        self.lbTitle.backgroundColor = [UIColor clearColor];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        self.lbTitle.textColor = [UIColor whiteColor];
        [self addSubview:self.lbTitle];
        self.lbTitle.hidden = YES;
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = frame.size.width / 2.0;
        self.loadingViewType = MSLoadingViewType_text;
        
        self.progress = 0.01;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    if (self.loadingViewType == MSLoadingViewType_text) {
        self.lbTitle.hidden = NO;
        if (progress == 1) {
            self.lbTitle.text = @"100%";
        }else{
            self.lbTitle.text = [NSString stringWithFormat:@"%.1f%%",progress*100];
        }
    }else{
        self.lbTitle.hidden = YES;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGFloat x = rect.size.width * 0.5;
    CGFloat y = rect.size.height * 0.5;
    CGFloat radius = rect.size.width * 0.5 - 4;
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = - M_PI_2 + self.progress * M_PI * 2;
    
    if (self.loadingViewType == MSLoadingViewType_line || self.loadingViewType == MSLoadingViewType_text) {
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, 2);
        CGContextAddArc(context, x, y, radius, startAngle, endAngle, 0);
        CGContextStrokePath(context);
    }else{
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x, y - radius);
        CGContextAddArc(context, x, y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    
}

@end
