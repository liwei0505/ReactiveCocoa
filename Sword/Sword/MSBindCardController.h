//
//  MSBindCardController.h
//  Sword
//
//  Created by lee on 16/12/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

@interface MSBindCardController : MSBaseViewController

@property (copy, nonatomic) void(^bindCardComplete)(void);

@end
