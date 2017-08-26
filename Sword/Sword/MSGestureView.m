    //
//  MSPatternLockView.m
//  Sword
//
//  Created by haorenjie on 16/7/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSGestureView.h"
#import "MSTouchTile.h"
#import "MSUtils.h"

@interface MSGestureView()

@property (strong, nonatomic) NSMutableArray *selectedTiles;
@property (assign, nonatomic) CGPoint currentPosition;

@end

@implementation MSGestureView

- (instancetype)init
{
    if (self = [super init]) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self prepare];
    }
    return self;
}

- (void)setLockStatus:(PatternLockStatus)lockStatus
{
    _lockStatus = lockStatus;
    if (_lockStatus == PATTERN_LOCK_ST_ERROR) {
        for (MSTouchTile *tile in self.selectedTiles) {
            tile.status = TILE_ST_ERROR;
        }
    } else {
        [self resetView];
    }
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat scaleRatio = screenWidth /  375.f;
    CGFloat radius = 33.f * scaleRatio;
    CGFloat diameter = 2 * radius;
    CGFloat margin = (self.frame.size.width - 3 * diameter) / 2.f;

    [self.subviews enumerateObjectsUsingBlock:^(__kindof MSTouchTile * _Nonnull tileView, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger row = idx / 3;
        NSUInteger col = idx % 3;
        CGFloat tileX = col * (diameter + margin);
        CGFloat tileY = row * (diameter + margin);
        tileView.frame = CGRectMake(tileX, tileY, diameter, diameter);
        tileView.tag = idx + 1;
    }];
}

- (void)drawRect:(CGRect)rect
{
    if (self.selectedTiles.count == 0) {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();

    //绘制边框
    //CGContextAddRect(context, rect);

    if (self.clip) {
        for (MSTouchTile *tile in self.subviews) {
            CGContextAddEllipseInRect(context, tile.frame);
        }
        CGContextEOClip(context);
    }

    [self.selectedTiles enumerateObjectsUsingBlock:^(MSTouchTile * _Nonnull tile, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            CGContextMoveToPoint(context, tile.center.x, tile.center.y);
        } else {
            CGContextAddLineToPoint(context, tile.center.x, tile.center.y);
        }
    }];

    if (!CGPointEqualToPoint(self.currentPosition, CGPointZero)) {
        if (self.lockStatus == PATTERN_LOCK_ST_NORMAL) {
            CGContextAddLineToPoint(context, self.currentPosition.x, self.currentPosition.y);
        }
    }

    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 1.f);
    UIColor *lineColor = (self.lockStatus == PATTERN_LOCK_ST_ERROR) ? UIColorFromRGBDecValue(218.f, 27.f, 39.f) : UIColorFromRGBDecValue(51.f, 48.f, 146.f);
    [lineColor set];

    CGContextStrokePath(context);
}

#pragma mark - touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self resetView];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof MSTouchTile * _Nonnull tile, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(tile.frame, location)) {
            tile.status = TILE_ST_SELECT;
            [self.selectedTiles addObject:tile];
        }
    }];

    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof MSTouchTile * _Nonnull tile, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(tile.frame, location)) {
            if (![self.selectedTiles containsObject:tile]) {
                [self.selectedTiles addObject:tile];
                [self checkAndAddLostTile];
            }
        } else {
            self.currentPosition = location;
        }
    }];

    [self.selectedTiles enumerateObjectsUsingBlock:^(MSTouchTile * _Nonnull tile, NSUInteger idx, BOOL * _Nonnull stop) {
        tile.status = TILE_ST_SELECT;
    }];

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray *password = [self getPassword:self.selectedTiles];
    if (self.delegate) {
        [self.delegate onGestureInputResult:password];
    }
}

#pragma mark - privates

- (void)prepare
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat scaleRatio = screenWidth /  375.f;
    CGFloat margin = 52.5f * scaleRatio;
    CGRect frame = CGRectMake(0.f, 0.f, screenWidth - 2 * margin, screenWidth - 2 * margin);
    [self setFrame:frame];

    CGFloat centerX = screenWidth / 2;
    CGFloat centerY = 225 * scaleRatio - 44 * scaleRatio + (screenWidth - margin * 2) * 0.5;
    [self setCenter:CGPointMake(centerX, centerY)];

    self.backgroundColor = [UIColor clearColor];

    for (NSUInteger i = 0; i < 9; ++i) {
        MSTouchTile *tile = [[MSTouchTile alloc] init];
        tile.userInteractionEnabled = NO;
        tile.type = TILE_TYPE_GESTURE;
        [self addSubview:tile];
    }
}

- (NSMutableArray *)selectedTiles
{
    if (!_selectedTiles) {
        _selectedTiles = [[NSMutableArray alloc] init];
    }
    return _selectedTiles;
}

- (void)resetView
{
    self.currentPosition = CGPointZero;
    @synchronized (self) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof MSTouchTile * _Nonnull tile, NSUInteger idx, BOOL * _Nonnull stop) {
            tile.status = TILE_ST_NORMAL;
        }];

        [self.selectedTiles removeAllObjects];
    }
}

- (void)checkAndAddLostTile
{
    NSUInteger tileCount = self.selectedTiles.count;
    if (tileCount < 2) {
        return;
    }

    MSTouchTile *beginTile = [self.selectedTiles objectAtIndex:tileCount - 2];
    MSTouchTile *endTile = [self.selectedTiles objectAtIndex:tileCount - 1];
    CGFloat angle = atan2(endTile.center.y - beginTile.center.y, endTile.center.x - beginTile.center.x) + M_PI_2;
    beginTile.angle = angle;

    CGPoint centerPostion = CGPointMake((beginTile.center.x + endTile.center.x) / 2, (beginTile.center.y + endTile.center.y) / 2);
    for (MSTouchTile *tile in self.subviews) {
        if (CGRectContainsPoint(tile.frame, centerPostion)) {
            tile.angle = angle;
            if (![self.selectedTiles containsObject:tile]) {
                [self.selectedTiles insertObject:tile atIndex:tileCount - 1];
            }
        }
    }
}

- (NSArray *)getPassword:(NSArray *)selectedTiles
{
    NSMutableArray *password = [[NSMutableArray alloc] init];
    for (MSTouchTile *tile in selectedTiles) {
        [password addObject:[NSNumber numberWithInteger:tile.tag]];
    }
    return password;
}

@end
