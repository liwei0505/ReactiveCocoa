//
//  MSPatternSetController.h
//  Sword
//
//  Created by haorenjie on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
#import "MSConsts.h"

@interface MSPatternSetController : MSBaseViewController

@property (assign, nonatomic) BOOL canJumpOver;
@property (assign, nonatomic) BOOL showBackItem;
@property (copy, nonatomic) void(^patternLockSetBlock)(void);

@end
