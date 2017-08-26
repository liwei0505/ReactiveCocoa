//
//  MSSetTradePassword.h
//  Sword
//
//  Created by lee on 16/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

@interface MSSetTradePassword : MSBaseViewController

@property (nonatomic, copy) void (^backBlock)(void);
@property (nonatomic, assign) TradePassword type;

@end
