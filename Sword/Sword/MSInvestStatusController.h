//
//  MSInvestStatusController.h
//  Sword
//
//  Created by msj on 2017/7/3.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, MSInvestStatusType) {
    MSInvestStatusType_success,
    MSInvestStatusType_error
};

@interface MSInvestStatusController : MSBaseViewController
- (void)updateWithType:(MSInvestStatusType)type money:(NSString *)money message:(NSString *)message;
@end
