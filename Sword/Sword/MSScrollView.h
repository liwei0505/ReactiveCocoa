//
//  MSScrollView.h
//  showTime
//
//  Created by 刘飞 on 16/8/25.
//  Copyright © 2016年 刘飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSScrollView;

@protocol MSScrollViewDelegate <NSObject>
- (void)ms_scrollView:(MSScrollView *)msscrollView didSelectAtIndex:(NSInteger)index;
@end

@interface MSScrollView : UIView
@property (strong, nonatomic) NSArray<NSString *> *urlArray;
@property (weak  , nonatomic) id<MSScrollViewDelegate> delegate;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) UIColor *pageIndicatorTintColor;
@property (strong, nonatomic) UIColor *currentPageIndicatorTintColor;

- (instancetype)init __attribute__((unavailable("init不可用，请使用initWithFrame:")));
+ (instancetype)new __attribute__((unavailable("new不可用，请使用initWithFrame:")));
@end
