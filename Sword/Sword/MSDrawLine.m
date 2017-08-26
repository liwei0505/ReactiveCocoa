//
//  MSDrawLine.m
//  showTime
//
//  Created by msj on 2017/3/22.
//  Copyright © 2017年 msj. All rights reserved.
//

#import "MSDrawLine.h"

@implementation MSDrawLine
+ (CALayer *)drawDotLineWidth:(CGFloat)lineWidth lineSpace:(CGFloat)lineSpace lineColor:(UIColor *)lineColor points:(NSArray<NSString *> *)points {
    
    if (![points isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (points == nil || points.count < 2) {
        NSLog(@"至少需要要两个点");
        return nil;
    }
    
    if (lineWidth == 0 && lineSpace == 0) {
        NSLog(@"lineWidth和lineSpace不能同时为0");
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [points enumerateObjectsUsingBlock:^(NSString  * _Nonnull pointStr, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointStr);
        if (index == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = lineColor.CGColor;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = @[@(lineWidth), @(lineSpace)];
    shapeLayer.path = path.CGPath;
    return shapeLayer;
}

+ (CALayer *)drawSolidLineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor points:(NSArray<NSString *> *)points {
    
    if (![points isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (points == nil || points.count < 2) {
        NSLog(@"至少需要要两个点");
        return nil;
    }
    
    if (lineWidth <= 0) {
        NSLog(@"lineWidth必须大于0");
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [points enumerateObjectsUsingBlock:^(NSString  * _Nonnull pointStr, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointStr);
        if (index == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = lineColor.CGColor;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.path = path.CGPath;
    return shapeLayer;
    
}
@end
