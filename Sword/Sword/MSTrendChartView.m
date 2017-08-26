//
//  MSTrendChartView.m
//  showTime
//
//  Created by msj on 2017/3/20.
//  Copyright © 2017年 msj. All rights reserved.
//

#import "MSTrendChartView.h"
#import "UIView+FrameUtil.h"
#import "MSDrawLine.h"
#import "NSDate+Add.h"

#define RGB(r,g,b)      [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define LEFTMARGIN      65
#define RIGHTMARGIN     18
#define TOPMARGIN       20
#define BOTTOMMARGIN    TOPMARGIN
#define REALSPACEY      ((self.chartView.height - TOPMARGIN - BOTTOMMARGIN) / (self.lineCount - 1))

@interface MSTrendChartView ()<CAAnimationDelegate>
@property (strong, nonatomic) NSMutableArray *lbTrendArr;
@property (strong, nonatomic) NSMutableArray *lbTimeArr;
@property (strong, nonatomic) UILabel *lbTitleView;
@property (strong, nonatomic) UIView *chartView;
@property (strong, nonatomic) CAShapeLayer *trendChartLayer;
@property (strong, nonatomic) CAShapeLayer *maskShapeLayer;

@property (strong, nonatomic) NSNumber *minTrend;
@property (strong, nonatomic) NSNumber *maxTrend;
@property (assign, nonatomic) NSInteger lineCount;
@property (strong, nonatomic) UIColor *brokenLineColor;
@property (strong, nonatomic) NSArray *times;
@property (strong, nonatomic) NSArray *points;

@property (assign, nonatomic) CGPoint lastPoint;
@end

@implementation MSTrendChartView

- (NSMutableArray *)lbTrendArr {
    if (!_lbTrendArr) {
        _lbTrendArr = [NSMutableArray array];
    }
    return _lbTrendArr;
}

- (NSMutableArray *)lbTimeArr {
    if (!_lbTimeArr) {
        _lbTimeArr = [NSMutableArray array];
    }
    return _lbTimeArr;
}

- (CAShapeLayer *)trendChartLayer {
    if (!_trendChartLayer) {
        _trendChartLayer = [CAShapeLayer layer];
        _trendChartLayer.lineWidth = 1;
        _trendChartLayer.lineJoin = kCALineJoinRound;
        _trendChartLayer.lineCap = kCALineCapRound;
        _trendChartLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _trendChartLayer;
}

- (CAShapeLayer *)maskShapeLayer {
    if (!_maskShapeLayer) {
        _maskShapeLayer = [CAShapeLayer layer];
        _maskShapeLayer.strokeColor = [UIColor clearColor].CGColor;
        _maskShapeLayer.opacity = 0.05;
    }
    return _maskShapeLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lineCount = 5;
        self.backgroundColor = [UIColor whiteColor];
        [self drawDefaultChartView];
    }
    return self;
}

- (void)drawDefaultChartView {
    NSMutableArray *times = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        NSDate *date = [NSDate date];
        date = [date dateByAddingDays:-i];
        [times insertObject:[NSString stringWithFormat:@"%02ld-%02ld",(long)date.month,(long)date.day] atIndex:0];
    }
    NSArray *points = @[@0,@0.025,@0.05,@0.025,@0,@0.025,@0.05];
    [self updateWithMinTrend:@(0) maxTrend:@(0.05) lineCount:6 brokenLineColor:RGB(206,206,206) times:times points:points mask:NO animation:NO];
    UILabel *lbTips = [[UILabel alloc] initWithFrame:self.chartView.bounds];
    lbTips.text = @"暂无数据";
    lbTips.textColor = RGB(206,206,206);
    lbTips.textAlignment = NSTextAlignmentCenter;
    lbTips.font = [UIFont systemFontOfSize:25];
    [self.chartView addSubview:lbTips];
    
}

- (void)setLineCount:(NSInteger)lineCount {
    if (lineCount < 2) {
        _lineCount = 5;
    }else{
        _lineCount = lineCount;
    }
}

- (void)updateWithMinTrend:(NSNumber *)minTrend maxTrend:(NSNumber *)maxTrend lineCount:(NSInteger)lineCount brokenLineColor:(UIColor *)brokenLineColor times:(NSArray *)times points:(NSArray *)points mask:(BOOL)mask animation:(BOOL)animation{
    
    if (minTrend.doubleValue >= maxTrend.doubleValue) {
        NSLog(@"minTrend 和 maxTrend大小不对");
        return;
    }
    
    if (!times || times.count == 0) {
        NSLog(@"时间轴没数据");
        return;
    }
    
    if (!points || points.count == 0) {
        NSLog(@"描点数据没有");
        return;
    }
    
    self.minTrend = minTrend;
    self.maxTrend = maxTrend;
    self.lineCount = lineCount;
    self.brokenLineColor = brokenLineColor;
    self.times = times;
    self.points = points;
    
    [self clear];
    [self addTitleView];
    [self addChartView];
    
    [self drawWithMin:self.minTrend max:self.maxTrend points:self.points mask:mask animation:animation];
}

- (void)clear {
    [self.chartView removeFromSuperview];
    [self.lbTimeArr removeAllObjects];
    [self.lbTrendArr removeAllObjects];
    [self.trendChartLayer removeFromSuperlayer];
    [self.trendChartLayer removeAllAnimations];
    self.trendChartLayer = nil;
    [self.maskShapeLayer removeFromSuperlayer];
    [self.maskShapeLayer removeAllAnimations];
    self.maskShapeLayer = nil;
}

- (void)addTitleView {
    self.lbTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.width, 25)];
    self.lbTitleView.text = @"近七日年化收益率曲线图";
    self.lbTitleView.textColor = [UIColor ms_colorWithHexString:@"#9C9C9C"];
    self.lbTitleView.textAlignment = NSTextAlignmentCenter;
    self.lbTitleView.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.lbTitleView];
}

- (void)addChartView {
    double chartViewY = CGRectGetMaxY(self.lbTitleView.frame) + 8;
    self.chartView = [[UIView alloc] initWithFrame:CGRectMake(0, chartViewY, self.width, self.height - chartViewY - 5)];
    [self addSubview:self.chartView];
    for (int i = 0; i < self.lineCount; i++) {
        NSArray *arr = @[NSStringFromCGPoint(CGPointMake(LEFTMARGIN, (REALSPACEY * i + TOPMARGIN))),
                         NSStringFromCGPoint(CGPointMake(self.width - RIGHTMARGIN, (REALSPACEY * i + TOPMARGIN)))];
        CALayer *layer = nil;
        if (i == self.lineCount - 1) {
            layer = [MSDrawLine drawSolidLineWidth:0.5 lineColor:RGB(206,206,206) points:arr];
        } else {
            layer = [MSDrawLine drawDotLineWidth:4 lineSpace:4 lineColor:RGB(206,206,206) points:arr];
        }
        [self.chartView.layer addSublayer:layer];
        
        UILabel *lbTrend = [[UILabel alloc] initWithFrame:CGRectMake(0, (REALSPACEY * i + TOPMARGIN + 0.5/2.0 - 11/2.0), 50, 11)];
        lbTrend.font = [UIFont systemFontOfSize:11];
        lbTrend.textAlignment = NSTextAlignmentRight;
        lbTrend.textColor = RGB(151,151,151);
        [self.chartView addSubview:lbTrend];
        [self.lbTrendArr addObject:lbTrend];
    }
    
    double height = BOTTOMMARGIN;
    double y = (self.chartView.height - BOTTOMMARGIN);
    double x = 0;
    double width = 0;
    for (int i = 0; i < self.times.count; i++) {
        if (self.times.count > 1) {
            width = (self.width - (LEFTMARGIN + RIGHTMARGIN) - 15)/(self.times.count - 1);
            x = i * width + (LEFTMARGIN - width/2.0);
        } else {
            width = self.width - (LEFTMARGIN + RIGHTMARGIN) - 15;
            x = LEFTMARGIN;
        }
        UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        lbTime.font = [UIFont systemFontOfSize:9];
        lbTime.textColor = RGB(151,151,151);
        lbTime.textAlignment = NSTextAlignmentCenter;
        
        NSArray *arr = @[NSStringFromCGPoint(CGPointMake(x + width/2.0, y)),
                         NSStringFromCGPoint(CGPointMake(x + width/2.0, y + 3))];
        CALayer *layer = [MSDrawLine drawSolidLineWidth:0.5 lineColor:RGB(206,206,206) points:arr];
        [self.chartView.layer addSublayer:layer];
        
        [self.chartView addSubview:lbTime];
        [self.lbTimeArr addObject:lbTime];
    }

}

- (void)drawWithMin:(NSNumber *)min max:(NSNumber *)max points:(NSArray *)points mask:(BOOL)mask animation:(BOOL)animation{
    NSDecimalNumber *maxY = [NSDecimalNumber decimalNumberWithString:max.stringValue];
    NSDecimalNumber *minY = [NSDecimalNumber decimalNumberWithString:min.stringValue];
    NSDecimalNumber *intervalCount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld", (long)(self.lineCount - 1)]];
    NSDecimalNumber *intervalHeight = [[maxY decimalNumberBySubtracting:minY] decimalNumberByDividingBy:intervalCount];
    NSMutableArray *dataM = [NSMutableArray array];
    double spaceX = (self.width - (LEFTMARGIN + RIGHTMARGIN) - 15)/(points.count - 1);
    [points enumerateObjectsUsingBlock:^(NSNumber  * _Nonnull value, NSUInteger index, BOOL * _Nonnull stop) {
        double x = 0;
        if (points.count > 1) {
            x = index * spaceX + LEFTMARGIN;
        } else {
            x = (self.width - (LEFTMARGIN + RIGHTMARGIN) - 15) * 0.5 + LEFTMARGIN;
        }
        NSDecimalNumber *deltY = [[[NSDecimalNumber decimalNumberWithString:value.stringValue] decimalNumberBySubtracting:minY] decimalNumberByDividingBy:intervalHeight];
        double y = self.chartView.height - (deltY.doubleValue * REALSPACEY + BOTTOMMARGIN);
        CGPoint point = CGPointMake(x, y);
        [dataM addObject:NSStringFromCGPoint(point)];
        if (index == points.count - 1) {
            self.lastPoint = point;
        }
    }];
    
    [self.lbTrendArr enumerateObjectsUsingBlock:^(UILabel *  _Nonnull lbTrend, NSUInteger index, BOOL * _Nonnull stop) {
        NSDecimalNumber *multiplyFactor = [NSDecimalNumber decimalNumberWithString:@"100"];
        NSDecimalNumber *decIndex = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
        if (index == 0) {
            lbTrend.text = [NSString stringWithFormat:@"%.2f%%", [maxY decimalNumberByMultiplyingBy:multiplyFactor].doubleValue];
        } else if (index == self.lbTrendArr.count - 1){
            lbTrend.text = [NSString stringWithFormat:@"%.2f%%", [minY decimalNumberByMultiplyingBy:multiplyFactor].doubleValue];
        } else {
            NSDecimalNumber *decY = [[maxY decimalNumberBySubtracting:[intervalHeight decimalNumberByMultiplyingBy:decIndex]] decimalNumberByMultiplyingBy:multiplyFactor];
            lbTrend.text = [NSString stringWithFormat:@"%.2f%%", decY.doubleValue];
        }
    }];
    
    [self.lbTimeArr enumerateObjectsUsingBlock:^(UILabel *  _Nonnull lbTime, NSUInteger index, BOOL * _Nonnull stop) {
        lbTime.text = self.times[index];
    }];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [dataM enumerateObjectsUsingBlock:^(NSString *  _Nonnull pointStr, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointStr);
        if (index == 0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }];
    
    self.trendChartLayer.path = path.CGPath;
    self.trendChartLayer.strokeColor = self.brokenLineColor.CGColor;
    [self.chartView.layer addSublayer:self.trendChartLayer];
    
    if (animation) {
        CABasicAnimation *pathAniamtion = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAniamtion.duration = 0.75;
        pathAniamtion.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAniamtion.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAniamtion.toValue = [NSNumber numberWithFloat:1.0];
        pathAniamtion.autoreverses = NO;
        pathAniamtion.fillMode = kCAFillModeForwards;
        pathAniamtion.delegate = self;
        [self.trendChartLayer addAnimation:pathAniamtion forKey:nil];
    }
    
    if (!mask || points.count == 1) {
        return;
    }
    
    [dataM addObject:NSStringFromCGPoint(CGPointMake(LEFTMARGIN + (dataM.count - 1) * spaceX, self.chartView.height - BOTTOMMARGIN))];
    [dataM addObject:NSStringFromCGPoint(CGPointMake(LEFTMARGIN, self.chartView.height - BOTTOMMARGIN))];
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [dataM enumerateObjectsUsingBlock:^(NSString *  _Nonnull pointStr, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointStr);
        if (index == 0) {
            [maskPath moveToPoint:point];
        }else{
            [maskPath addLineToPoint:point];
        }
    }];
    [maskPath closePath];
    self.maskShapeLayer.path = maskPath.CGPath;
    self.maskShapeLayer.fillColor = self.brokenLineColor.CGColor;
    [self.chartView.layer addSublayer:self.maskShapeLayer];
    
    if (animation) {
        CABasicAnimation *opacityAniamtion = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAniamtion.duration = 1.25;
        opacityAniamtion.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        opacityAniamtion.fromValue = @0;
        opacityAniamtion.toValue = @0.05;
        opacityAniamtion.autoreverses = NO;
        opacityAniamtion.fillMode = kCAFillModeForwards;
        [self.maskShapeLayer addAnimation:opacityAniamtion forKey:nil];
    }
    
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    circle.center = self.lastPoint;
    circle.backgroundColor = [UIColor whiteColor];
    circle.layer.cornerRadius = 5;
    circle.layer.borderColor = self.brokenLineColor.CGColor;
    circle.layer.borderWidth = 2;
    circle.layer.masksToBounds = YES;
    circle.alpha = 0;
    [self.chartView addSubview:circle];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"current_arrow"]];
    arrowImageView.frame = CGRectMake(self.lastPoint.x - 48, self.lastPoint.y - 33, 48, 21);
    [self.chartView addSubview:arrowImageView];
    arrowImageView.alpha = 0;
    
    UILabel *lbTips = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, arrowImageView.width, arrowImageView.height)];
    lbTips.textColor = [UIColor whiteColor];
    lbTips.backgroundColor = [UIColor clearColor];
    lbTips.textAlignment = NSTextAlignmentCenter;
    lbTips.font = [UIFont systemFontOfSize:12];
    lbTips.text = [NSString stringWithFormat:@"%.2f%%",[self.points.lastObject doubleValue] * 100];
    [arrowImageView addSubview:lbTips];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        circle.alpha = 1;
        arrowImageView.alpha = 1;
    }];
    
}

@end
