//
//  MSVerificationCodeView.h
//  showTime
//
//  Created by msj on 2016/12/21.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCountDownView.h"

@interface MSVerificationCodeView : UIView
@property (copy, nonatomic) void (^makeSureBlock)(NSString *verificationCode);
@property (copy, nonatomic) void (^getVerificationCodeBlock)(void);
@property (copy, nonatomic) void (^cancelBlock)(void);

- (void)updateWithTips:(NSString *)tips  isSuccess:(BOOL)isSuccess;

@property (strong, nonatomic,readonly) MSCountDownView *countDownView;

- (void)toFirstResponder;
- (void)unToFirstResponder;
- (void)reset;
- (instancetype)init __attribute__((unavailable("init不可用，请使用initWithFrame:")));
+ (instancetype)new __attribute__((unavailable("new不可用，请使用initWithFrame:")));
@end
