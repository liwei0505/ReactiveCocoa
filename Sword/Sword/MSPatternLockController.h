//
//  MSPatternLockController.h
//  Sword
//
//  Created by haorenjie on 16/7/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

@interface MSPatternLockController : MSBaseViewController

@property (weak, nonatomic) UIWindow *window;
@property (copy, nonatomic) void(^patternLockInputBlock)();

@end
