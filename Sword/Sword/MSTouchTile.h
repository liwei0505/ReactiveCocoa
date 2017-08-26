//
//  MSTouchTile.h
//  Sword
//
//  Created by haorenjie on 16/7/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TileStatus) {
    TILE_ST_NORMAL,
    TILE_ST_SELECT,
    TILE_ST_ERROR,
};

typedef NS_ENUM(NSInteger, TileType) {
    TILE_TYPE_INFO,
    TILE_TYPE_GESTURE,
};

@interface MSTouchTile : UIView

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) TileStatus status;
@property (assign, nonatomic) TileType type;

@end
