//
//  MSChargeHeaderView.h
//  Sword
//
//  Created by msj on 2017/6/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetInfo.h"

typedef NS_ENUM(NSInteger, BALANCE_TYPE) {
    BALANCE_RECHAGE,
    BALANCE_CASH
};

@interface MSBalanceHeaderView : UIView
@property (strong, nonatomic) AssetInfo *assertInfo;
@property (assign, nonatomic, readonly) BALANCE_TYPE balanceType;
@property (copy, nonatomic) void (^block)(BALANCE_TYPE type);

@end
