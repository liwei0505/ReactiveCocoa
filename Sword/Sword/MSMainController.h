//
//  MSMainController.h
//  Sword
//
//  Created by lee on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MSModuleIndex) {
    
    MSTab_Home = 0,
    MSTab_Invest = 1,
    MSTab_Account = 2,
};

@interface MSMainController : UITabBarController

- (void)setTabBarSelectedIndex:(NSUInteger)index;

@end
