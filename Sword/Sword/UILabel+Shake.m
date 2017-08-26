//
//  UILabel+Shake.m
//  Sword
//
//  Created by lee on 16/7/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "UILabel+Shake.h"
#import "CALayer+Anim.h"
#import "UIColor+StringColor.h"

@implementation UILabel (Shake)

- (void)setShakeText:(NSString *)text {

    [self setText:text];
    [self setTextColor:[UIColor colorWithRed:254/255.0 green:82/255.0 blue:92/255.0 alpha:1.0]];
    [self.layer shake];
}

- (void)setPatternLockHintText:(NSString *)text {

    [self setText:text];
    [self setTextColor:[UIColor ms_colorWithHexString:@"#555555"]];
}

@end
