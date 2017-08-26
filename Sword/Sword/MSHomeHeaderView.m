//
//  MSHomeHeaderView.m
//  Sword
//
//  Created by msj on 16/9/7.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSHomeHeaderView.h"
#import "MSScrollView.h"
#import "UIView+FrameUtil.h"
#import "BannerInfo.h"

@interface MSHomeHeaderView ()<MSScrollViewDelegate>
@property (strong, nonatomic) MSScrollView *scrollView;
@end

@implementation MSHomeHeaderView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addScrollView];
    }
    return self;
}

- (void)addScrollView
{
    self.scrollView = [[MSScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.scrollView.delegate = self;
    self.scrollView.placeholderImage = [UIImage imageNamed:@"default_banner"];
    [self addSubview:self.scrollView];
}

- (void)setBannerList:(NSArray *)bannerList
{
    _bannerList = bannerList;
    NSMutableArray *urlArr = [NSMutableArray array];
    for (int i = 0; i < bannerList.count; i++) {
        BannerInfo *info = bannerList[i];
        [urlArr addObject:info.bannerUrl];
    }
    self.scrollView.urlArray = urlArr;
}

#pragma mark - MSScrollViewDelegate
- (void)ms_scrollView:(MSScrollView *)msscrollView didSelectAtIndex:(NSInteger)index
{
    if (self.block) {
        self.block(index, self.bannerList[index]);
    }
}
@end
