//
//  MSPopoverController.h
//  Sword
//
//  Created by lee on 2017/8/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

@interface MSPopoverController : MSBaseViewController
@property (copy, nonatomic) void(^selectedBlock)(NSUInteger relation);
@end
