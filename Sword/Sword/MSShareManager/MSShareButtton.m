//
//  MSShareButtton.m
//  Sword
//
//  Created by msj on 16/10/17.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSShareButtton.h"

#define RGB(r,g,b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@implementation MSShareButtton

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, contentRect.size.height - 14, contentRect.size.width, 14);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((contentRect.size.width - 54)/2.0, (contentRect.size.height - 54 - 14)/2.0, 54, 54);
}

- (void)setShareModel:(MSShareModel *)shareModel
{
    _shareModel = shareModel;
    [self setImage:[UIImage imageNamed:shareModel.icon] forState:UIControlStateNormal];
    [self setTitle:shareModel.title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:RGB(235, 235, 235) forState:UIControlStateHighlighted];
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
}
@end
