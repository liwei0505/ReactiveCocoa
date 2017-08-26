//
//  MSInsuranceButton.m
//  Sword
//
//  Created by msj on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceButton.h"

#define RGB(r,g,b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@implementation MSInsuranceButton
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, contentRect.size.height - 20, contentRect.size.width, 20);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((contentRect.size.width - 48)/2.0, 0, 48, 48);
}

- (void)setModel:(MSInsuranceModel *)model {
    _model = model;
    [self setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
    [self setTitle:model.title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor ms_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [self setTitleColor:RGB(235, 235, 235) forState:UIControlStateHighlighted];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
@end
