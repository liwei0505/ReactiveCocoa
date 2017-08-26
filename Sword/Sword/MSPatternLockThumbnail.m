//
//  MSPatternLockThumbnail.m
//  Sword
//
//  Created by haorenjie on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPatternLockThumbnail.h"
#import "MSTouchTile.h"
#import "MSUtils.h"

@implementation MSPatternLockThumbnail

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

- (void)prepare
{
    self.backgroundColor = [UIColor clearColor];
    for (int i = 0; i < 9; ++i) {
        MSTouchTile *tile = [[MSTouchTile alloc] init];
        tile.type = TILE_TYPE_INFO;
        [self addSubview:tile];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat scaleRatio = screenWidth / 375.f;
    CGFloat radius = 5.5f * scaleRatio;
    CGFloat diameter = 2 * radius;
    CGFloat margin = (self.frame.size.width - 3 * diameter) / 2.f;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof MSTouchTile * _Nonnull tileView, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger row = idx / 3;
        NSUInteger col = idx % 3;
        CGFloat tileX = col * (diameter + margin) + 1;
        CGFloat tileY = row * (diameter + margin) + 1;
        tileView.frame = CGRectMake(tileX, tileY, diameter, diameter);
        tileView.tag = idx + 1;
    }];
}

- (void)showPatternLock:(NSArray *)password {
    
    for (MSTouchTile *tile in self.subviews) {
        NSUInteger count = password.count;
        for (int i=0; i<count; i++) {
            if (tile.tag == [password[i] intValue]) {
                [tile setStatus:TILE_ST_SELECT];
            }
        }
    }
}

- (void)clearPatternLock {

    for (MSTouchTile *tile in self.subviews) {
        NSUInteger count = self.subviews.count;
        for (int i=0; i<count; i++) {
            [tile setStatus:TILE_ST_NORMAL];
        }
    }
}

@end
