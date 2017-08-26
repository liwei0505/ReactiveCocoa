//
//  MSTouchTile.m
//  Sword
//
//  Created by haorenjie on 16/7/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSTouchTile.h"
#import "MSUtils.h"

const float CircleEdgeWidth = 1.f;

@interface MSTouchTile()

@property (readonly, nonatomic) UIColor *outerCircleColor;
@property (readonly, nonatomic) UIColor *innerCircleColor;
@property (readonly, nonatomic) CGFloat centerRatio;

@end

@implementation MSTouchTile

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 上下文旋转
    CGFloat translateXY = rect.size.width * 0.5f;
    CGContextTranslateCTM(context, translateXY, translateXY);
    CGContextRotateCTM(context, self.angle);
    CGContextTranslateCTM(context, -translateXY, -translateXY);

    // 画圆环
    CGRect circleRect = CGRectMake(CircleEdgeWidth, CircleEdgeWidth, rect.size.width - 2 * CircleEdgeWidth, rect.size.height - 2 * CircleEdgeWidth);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, circleRect);
    CGContextAddPath(context, path);
    [self.outerCircleColor set];
    CGContextSetLineWidth(context, CircleEdgeWidth);
    CGContextStrokePath(context);
    CGPathRelease(path);

    // 画圆心
    CGRect centerRect = CGRectMake(rect.size.width/2 * (1 - self.centerRatio) + CircleEdgeWidth, rect.size.height/2 * (1 - self.centerRatio) + CircleEdgeWidth, rect.size.width * self.centerRatio - CircleEdgeWidth * 2, rect.size.height * self.centerRatio - CircleEdgeWidth * 2);
    path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, centerRect);
    CGContextAddPath(context, path);
    [self.innerCircleColor set];
    CGContextFillPath(context);
    CGPathRelease(path);
}

- (UIColor *)outerCircleColor
{
    switch (self.status) {
        case TILE_ST_SELECT: return UIColorFromRGBDecValue(51, 48, 146);
        case TILE_ST_ERROR: return UIColorFromRGBDecValue(218, 27, 39);
        case TILE_ST_NORMAL:
        default: return UIColorFromRGBDecValue(195, 172, 173);
    }
}

- (UIColor *)innerCircleColor
{
    switch (self.status) {
        case TILE_ST_SELECT: return UIColorFromRGBDecValue(51, 48, 146);
        case TILE_ST_ERROR: return UIColorFromRGBDecValue(218,27,39);
        case TILE_ST_NORMAL:
        default: return [UIColor clearColor];
    }
}

- (CGFloat)centerRatio
{
    if (self.type == TILE_TYPE_INFO) {
        return 1.f;
    }
    return 0.4f;
}

- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    [self setNeedsDisplay];
}

- (void)setStatus:(TileStatus)status
{
    _status = status;
    [self setNeedsDisplay];
}

@end
