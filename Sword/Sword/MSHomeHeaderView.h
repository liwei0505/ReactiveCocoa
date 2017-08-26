//
//  MSHomeHeaderView.h
//  Sword
//
//  Created by msj on 16/9/7.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerInfo;

@interface MSHomeHeaderView : UIView
@property (strong, nonatomic) NSArray *bannerList;
@property (copy, nonatomic) void(^block)(NSInteger index,BannerInfo * bannerInfo);
@end
