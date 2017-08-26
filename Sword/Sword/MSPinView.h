//
//  MSPinView.h
//  showTime
//
//  Created by msj on 2016/12/20.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPinView : UIView
@property (copy, nonatomic) void (^finish)(NSString *password);
- (void)toFirstResponder;
- (void)unToFirstResponder;
- (void)reset;

- (instancetype)init __attribute__((unavailable("init不可用，请使用initWithFrame:")));
+ (instancetype)new __attribute__((unavailable("new不可用，请使用initWithFrame:")));
@end
