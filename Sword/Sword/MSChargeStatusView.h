//
//  MSChargeStatusView.h
//  Sword
//
//  Created by msj on 2017/7/3.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSChargeStatusType) {
    MSChargeStatusType_success,
    MSChargeStatusType_error
};

@interface MSChargeStatusView : UIView
- (void)showWithStyle:(MSChargeStatusType)style message:(NSString *)message;
@property (copy, nonatomic) void (^block)(void);
@end
