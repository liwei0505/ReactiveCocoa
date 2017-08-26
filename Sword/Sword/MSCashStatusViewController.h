//
//  MSCashStatusViewController.h
//  Sword
//
//  Created by msj on 2017/7/4.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, MSCashStatusType) {
    MSCashStatusType_success,
    MSCashStatusType_error
};

@interface MSCashStatusViewController : MSBaseViewController
- (void)updateWithType:(MSCashStatusType)type money:(NSString *)money message:(NSString *)message;
@end
