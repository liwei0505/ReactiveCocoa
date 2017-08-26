//
//  MSPinLoadingView.h
//  showTime
//
//  Created by msj on 2016/12/21.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPinLoadingView : UIView
- (void)toFirstResponder;
- (void)unToFirstResponder;
- (void)startRotation;
- (void)stopRotation;

@property (copy, nonatomic) NSString *tips;

- (instancetype)init __attribute__((unavailable("init不可用，请使用initWithFrame:")));
+ (instancetype)new __attribute__((unavailable("new不可用，请使用initWithFrame:")));
@end
