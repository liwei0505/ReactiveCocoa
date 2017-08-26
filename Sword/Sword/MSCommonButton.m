//
//  MSCommonButton.m
//  Sword
//
//  Created by lee on 2017/6/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCommonButton.h"

@implementation MSCommonButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepare];
    }
    return self;
}

- (void)prepare {

    [self setBackgroundImage:[UIImage imageNamed:@"ms_btn_common_default"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"ms_btn_common_disable"] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"ms_btn_common_highlight"] forState:UIControlStateHighlighted];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Semibold" size:16]];
    [self.titleLabel setTextColor: [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1/1.0]];
    
}

//- (CGRect)contentRectForBounds:(CGRect)bounds{
//    NSLog(@"内容边界:%@",NSStringFromCGRect(bounds));
//    return CGRectMake(0, 0, 10, 10);
//}

// 返回标题边界
- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.height-10);
}
// 返回图片边界
//- (CGRect)imageRectForContentRect:(CGRect)contentRect{
//    NSLog(@"图片边界:%@",NSStringFromCGRect(contentRect));
//    return CGRectMake(0, 0, 100, 60);
//}

@end
