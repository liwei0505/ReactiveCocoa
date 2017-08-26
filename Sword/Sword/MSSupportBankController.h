//
//  MSSurpportBankController.h
//  Sword
//
//  Created by lee on 16/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef void(^selectedBank)(NSString *bank, NSString *bankId);

@interface MSSupportBankController : MSBaseViewController

- (void)seletedBankComplete:(selectedBank)block;

@end
