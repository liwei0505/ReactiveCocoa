//
//  MSMSRegistController.h
//  Sword
//
//  Created by lee on 16/5/9.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSBaseViewController.h"

@interface MSRegistController : MSBaseViewController
@property (copy, nonatomic) void (^registerSuccess)(NSString *accountNumber, NSString *password);
@end
