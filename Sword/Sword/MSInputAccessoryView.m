//
//  MSInputAccessoryView.m
//  Sword
//
//  Created by msj on 2016/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInputAccessoryView.h"
#import "UIView+FrameUtil.h"
#import "MSAppDelegate.h"
#define RGB(r,g,b)  [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
@implementation MSInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        imageView.center = self.center;
        [self addSubview:imageView];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.7)];
        topLine.backgroundColor = RGB(165,165,165);
        [self addSubview:topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.7, self.width, 0.7)];
        bottomLine.backgroundColor = RGB(165,165,165);
        [self addSubview:bottomLine];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    }
    return self;
}
- (void)tap
{
    [[MSAppDelegate getInstance].window endEditing:YES];
}
@end
