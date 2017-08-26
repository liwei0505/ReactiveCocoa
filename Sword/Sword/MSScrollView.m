//
//  MSScrollView.h
//  showTime
//
//  Created by 刘飞 on 16/8/25.
//  Copyright © 2016年 刘飞. All rights reserved.
//

#import "MSScrollView.h"
#import "UIImageView+WebCache.h"
#define DEFAULTNUM  3
#define RGB(r,g,b)  [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1];

@interface MSScrollView ()<UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIImageView *imageViewLeft;
@property (strong, nonatomic) UIImageView *imageViewCenter;
@property (strong, nonatomic) UIImageView *imageViewRight;
@property (assign, nonatomic) NSInteger indexCurrent;
@property (strong, nonatomic) UIPageControl *pageControll;
@end

@implementation MSScrollView
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.contentSize = CGSizeMake(DEFAULTNUM * self.frame.size.width, 0);
        self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        self.pageControll = [[UIPageControl alloc] init];
        self.pageControll.userInteractionEnabled = NO;
        self.pageControll.backgroundColor = [UIColor clearColor];
        self.pageControll.hidesForSinglePage = YES;
        [self addSubview:self.pageControll];
        
        self.imageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imageViewLeft.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewLeft.clipsToBounds = YES;
        [self.scrollView addSubview:self.imageViewLeft];
        
        self.imageViewCenter = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        self.imageViewCenter.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewCenter.clipsToBounds = YES;
        [self.scrollView addSubview:self.imageViewCenter];
        
        self.imageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height)];
        self.imageViewRight.contentMode = UIViewContentModeScaleAspectFill;
        self.imageViewRight.clipsToBounds = YES;
        [self.scrollView addSubview:self.imageViewRight];
        
        self.imageViewLeft.image = [UIImage imageNamed:@"default_banner"];
        self.imageViewCenter.image = [UIImage imageNamed:@"default_banner"];
        self.imageViewRight.image = [UIImage imageNamed:@"default_banner"];
        
        self.indexCurrent = 0;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setUrlArray:(NSArray<NSString *> *)urlArray
{
    [self stop];
    
    _urlArray = urlArray;
    
    self.imageViewLeft.image = self.placeholderImage;
    self.imageViewCenter.image = self.placeholderImage;
    self.imageViewRight.image = self.placeholderImage;
    
    self.pageControll.numberOfPages = urlArray.count;
    
//    CGSize size = [self.pageControll sizeForNumberOfPages:urlArray.count];
//    self.pageControll.frame = CGRectMake(self.bounds.size.width - size.width - 12, self.bounds.size.height - 30, size.width, 30);
    self.pageControll.frame = CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 30);
    
    if (!(self.urlArray && self.urlArray.count > 0)) {
        self.userInteractionEnabled = NO;
        return;
    }
    
    self.userInteractionEnabled = YES;
    
    self.indexCurrent = 0;
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    self.pageControll.currentPage = self.indexCurrent;
//    self.pageControll.pageIndicatorTintColor = self.pageIndicatorTintColor ?: RGB(233, 233, 233);
//    self.pageControll.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor ?: [UIColor whiteColor];
    
    NSInteger indexLeft = (self.indexCurrent + urlArray.count - 1) % urlArray.count;
    NSInteger indexRight = (self.indexCurrent + 1) % urlArray.count;
    
    [self.imageViewCenter sd_setImageWithURL:[NSURL URLWithString:urlArray[self.indexCurrent]] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed];
    [self.imageViewLeft sd_setImageWithURL:[NSURL URLWithString:urlArray[indexLeft]] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed];
    [self.imageViewRight sd_setImageWithURL:[NSURL URLWithString:urlArray[indexRight]] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed];
    
    [self start];
    
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (!(self.urlArray && self.urlArray.count > 0)) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ms_scrollView:didSelectAtIndex:)]) {
        [self.delegate ms_scrollView:self didSelectAtIndex:self.indexCurrent];
    }
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)start
{
    self.timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(cycleRun) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)cycleRun
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setContentOffset:CGPointMake(self.frame.size.width * 2, 0) animated:YES];
    }];
}

- (void)reloadImage
{
    if (!(self.urlArray && self.urlArray.count > 0)) {
        return;
    }
    
    NSInteger indexLeft,indexRight;
    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    if (contentOffsetX > self.frame.size.width) {
        self.indexCurrent = (self.indexCurrent + 1) % self.urlArray.count;
    }else if(contentOffsetX < self.frame.size.width){
        self.indexCurrent = (self.indexCurrent + self.urlArray.count - 1) % self.urlArray.count;
    }
    
    self.pageControll.currentPage = self.indexCurrent;
    
    [self.imageViewCenter sd_setImageWithURL:[NSURL URLWithString:self.urlArray[self.indexCurrent]] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed];
    
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    
    indexLeft = (self.indexCurrent + self.urlArray.count - 1) % self.urlArray.count;
    indexRight = (self.indexCurrent + 1) % self.urlArray.count;
    [self.imageViewLeft sd_setImageWithURL:[NSURL URLWithString:self.urlArray[indexLeft]] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed];
    [self.imageViewRight sd_setImageWithURL:[NSURL URLWithString:self.urlArray[indexRight]] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self start];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stop];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self reloadImage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadImage];
}

@end



