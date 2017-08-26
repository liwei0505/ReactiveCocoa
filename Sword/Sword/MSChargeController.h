//
//  MSChargeController.h
//  Sword
//
//  Created by lee on 16/6/14.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, ChargeType) {
    
    ChargeType_push = 1,
    ChargeType_present = 2,
};

@interface MSChargeController : MSBaseViewController
@property (assign, nonatomic) ChargeType type;
@property (assign, nonatomic) double chargeMoney;
@end
