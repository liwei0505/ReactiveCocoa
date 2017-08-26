//
//  MSPageStateView.m
//  showTime
//
//  Created by msj on 2017/5/15.
//  Copyright © 2017年 msj. All rights reserved.
//

#import "MSPageStateView.h"

#pragma mark - MSPageEmptyStateView
@interface MSPageEmptyStateView : UIView
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTips;
@end
@implementation MSPageEmptyStateView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = [UIImage imageNamed:@"page_empty"];
        [self addSubview:self.imageView];
        
        self.lbTips = [[UILabel alloc] init];
        self.lbTips.textAlignment = NSTextAlignmentCenter;
        self.lbTips.font = [UIFont systemFontOfSize:13];
        self.lbTips.text = @"暂无数据，点击屏幕重新加载!";
        self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#A8A8A8"];
        [self addSubview:self.lbTips];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageW = 160;
    self.imageView.frame = CGRectMake((self.frame.size.width - imageW)/2.0, (self.frame.size.height - imageW)/2.0 - 35, imageW, imageW);
    self.imageView.layer.cornerRadius = imageW / 2.0;
    
    self.lbTips.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 10, self.frame.size.width, 14);
}
@end

#pragma mark - MSPageErrorStateView
@interface MSPageErrorStateView : UIView
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTips;
@end
@implementation MSPageErrorStateView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = [UIImage imageNamed:@"page_error"];
        [self addSubview:self.imageView];
        
        self.lbTips = [[UILabel alloc] init];
        self.lbTips.textAlignment = NSTextAlignmentCenter;
        self.lbTips.font = [UIFont systemFontOfSize:13];
        self.lbTips.text = @"加载失败，点击屏幕重新加载!";
        self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#A8A8A8"];
        [self addSubview:self.lbTips];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageW = 160;
    self.imageView.frame = CGRectMake((self.frame.size.width - imageW)/2.0, (self.frame.size.height - imageW)/2.0 - 35, imageW, imageW);
    self.imageView.layer.cornerRadius = imageW / 2.0;
    
    self.lbTips.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 10, self.frame.size.width, 14);
}
@end

#pragma mark - MSPageLoadingStateView
@interface MSPageLoadingStateView : UIView
@property (strong, nonatomic) UIImageView *imageView;
@end
@implementation MSPageLoadingStateView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = [UIImage imageNamed:@"pay_loading"];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    if (hidden) {
        [self stopRotation];
    }else{
        [self startRotation];
    }
    [super setHidden:hidden];
}

- (void)startRotation{
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    ani.fromValue = @0;
    ani.toValue = @(2 * M_PI);
    ani.duration = 0.6;
    ani.fillMode = kCAFillModeForwards;
    ani.removedOnCompletion = NO;
    ani.repeatCount = MAXFLOAT;
    [self.imageView.layer addAnimation:ani forKey:@"ms_rotation"];
}
- (void)stopRotation{
    [self.imageView.layer removeAnimationForKey:@"ms_rotation"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageW = 40;
    self.imageView.frame = CGRectMake((self.frame.size.width - imageW)/2.0, (self.frame.size.height - imageW)/2.0, imageW, imageW);
    self.imageView.layer.cornerRadius = imageW / 2.0;
}
@end

#pragma mark - MSPageStateView
@interface MSPageStateView ()
@property (strong, nonatomic) MSPageErrorStateView *pageErrorView;
@property (strong, nonatomic) MSPageEmptyStateView *pageEmptyView;
@property (strong, nonatomic) MSPageLoadingStateView *pageLoadingView;
@end

@implementation MSPageStateView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.pageEmptyView = [[MSPageEmptyStateView alloc] init];
        [self addSubview:self.pageEmptyView];
        self.pageEmptyView.hidden = YES;
        
        self.pageErrorView = [[MSPageErrorStateView alloc] init];
        [self addSubview:self.pageErrorView];
        self.pageErrorView.hidden = YES;
        
        self.pageLoadingView = [[MSPageLoadingStateView alloc] init];
        [self addSubview:self.pageLoadingView];
        self.pageLoadingView.hidden = YES;
    }
    return self;
}

- (void)setState:(MSPageStateMachineType)state {

    _state = state;
    switch (_state) {
        case MSPageStateMachineType_idle:
        case MSPageStateMachineType_loaded:
        {
            [self dismiss];
            break;
        }
        case MSPageStateMachineType_loading:
        {
            self.pageEmptyView.hidden = YES;
            self.pageErrorView.hidden = YES;
            self.pageLoadingView.hidden = NO;
            break;
        }
        case MSPageStateMachineType_empty:
        {
            self.pageEmptyView.hidden = NO;
            self.pageErrorView.hidden = YES;
            self.pageLoadingView.hidden = YES;
            break;
        }
        case MSPageStateMachineType_error:
        {
            self.pageEmptyView.hidden = YES;
            self.pageErrorView.hidden = NO;
            self.pageLoadingView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (void)showInView:(UIView *)superView {
    if (!superView || ![superView isKindOfClass:[UIView class]]) {
        return;
    }
    
    if (self.superview) {
        return;
    }
    
    [superView addSubview:self];
    self.frame = superView.bounds;
    self.state = MSPageStateMachineType_loading;
}

- (void)dismiss {
    if (self.superview) {
        self.pageEmptyView.hidden = YES;
        self.pageErrorView.hidden = YES;
        self.pageLoadingView.hidden = YES;
        [self removeFromSuperview];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    switch (self.state) {
        case MSPageStateMachineType_empty:
        case MSPageStateMachineType_error:
        {
            if (self.refreshBlock) {
                self.state = MSPageStateMachineType_loading;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.refreshBlock();
                });
            }
            break;
        }
        default:
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.pageLoadingView.frame = self.bounds;
    self.pageErrorView.frame = self.bounds;
    self.pageEmptyView.frame = self.bounds;
}
@end
