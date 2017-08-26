//
//  MSNewPointProductCell.h
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoodsInfo;

@interface MSNewPointProductCell : UICollectionViewCell
@property (strong, nonatomic) GoodsInfo *goodInfo;
@property (copy, nonatomic) void (^exchange)(GoodsInfo *goodInfo);
@end
