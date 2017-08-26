//
//  MSProductInfo.h
//  mobip2p
//
//  Created by lee on 16/5/20.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsInfo : NSObject

@property (copy, nonatomic) NSString *pictureUrl;   //图片路径
@property (copy, nonatomic) NSString *name;         //商品名称
@property (assign, nonatomic) int goodId;           //商品id
@property (assign, nonatomic) int points;           //商品需积分额
@property (copy, nonatomic) NSString *datetime;     //商品上架时间
@property (assign, nonatomic) double price;         //商品价格


@end
