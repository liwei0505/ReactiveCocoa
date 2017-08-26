//
//  MSCountDownView.h
//  showTime
//
//  Created by msj on 2016/12/20.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSCountDownStyle) {
    MSCountDownStyleNormal,
    MSCountDownStylePay
};

typedef NS_ENUM(NSInteger, MSCountDownViewMode) {
    MSCountDownViewModeNormal,
    MSCountDownViewModeIntermediate,
    MSCountDownViewModeCountDown
};

@interface MSCountDownView : UIView
//倒计时样式  默认值为:  MSCountDownStyleNormal
@property (assign, nonatomic) MSCountDownStyle  style;
//倒计时状态  默认值为:  MSCountDownViewModeNormal
@property (assign, nonatomic) MSCountDownViewMode  currentMode;
//倒计时数  默认值为:  60秒
@property (assign, nonatomic) int count;
//即将开始倒计时回调
@property (copy, nonatomic) void (^willBeginCountdown)(void);
//结束倒计时回调
@property (copy, nonatomic) void (^didEndCountdown)(void);
//取消倒计时
- (void)invalidate;
//根据业务需求 倒计时未结束时，再次进入页面  要恢复退出页面前的状态
- (void)startCountdownWithMode:(MSCountDownViewMode)mode temporaryCount:(int)temporaryCount;

- (instancetype)init __attribute__((unavailable("init不可用，请使用initWithFrame:")));
+ (instancetype)new __attribute__((unavailable("new不可用，请使用initWithFrame:")));
@end



