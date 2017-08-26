//
//  MSInviteButton.m
//  Sword
//
//  Created by msj on 2017/3/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInviteButton.h"

#define RGB(r,g,b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@implementation MSInviteButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, contentRect.size.height - 12, contentRect.size.width, 12);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((contentRect.size.width - 35)/2.0, (contentRect.size.height - 35 - 14)/2.0, 35, 35);
}

- (void)setShareModel:(MSShareModel *)shareModel
{
    _shareModel = shareModel;
    [self setImage:[UIImage imageNamed:shareModel.icon] forState:UIControlStateNormal];
    [self setTitle:shareModel.title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor ms_colorWithHexString:@"#999999"] forState:UIControlStateNormal];
    [self setTitleColor:RGB(235, 235, 235) forState:UIControlStateHighlighted];
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
}
@end
