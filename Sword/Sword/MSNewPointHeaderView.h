//
//  MSNewPointHeaderView.h
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserPoint;

@interface MSNewPointHeaderView : UIView
@property (strong, nonatomic) UserPoint *userPoint;
@property (copy, nonatomic) void(^showRules)(void);
@property (copy, nonatomic) void(^enterPointShop)(void);
@end
