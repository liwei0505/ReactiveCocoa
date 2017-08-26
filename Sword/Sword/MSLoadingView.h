//
//  MSDrawView.h
//  showTime
//
//  Created by msj on 16/9/1.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MSLoadingViewType_line,
    MSLoadingViewType_pie,
    MSLoadingViewType_text
}MSLoadingViewType;

@interface MSLoadingView : UIView
@property (assign, nonatomic) CGFloat progress;
@property (assign, nonatomic) MSLoadingViewType loadingViewType;

- (instancetype)init __attribute__((unavailable("init不可用，请使用initWithFrame:")));
+ (instancetype)new __attribute__((unavailable("new不可用，请使用initWithFrame:")));
@end
