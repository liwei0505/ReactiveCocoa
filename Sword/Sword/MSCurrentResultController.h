//
//  MSCurrentResultController.h
//  Sword
//
//  Created by msj on 2017/4/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, MSCurrentResultMode) {
    MSCurrentResultModePurchase,  //申购
    MSCurrentResultModeRedeem     //赎回
};

@interface MSCurrentResultController : MSBaseViewController
- (void)updateWithTimes:(NSArray *)times mode:(MSCurrentResultMode)mode;
@end
