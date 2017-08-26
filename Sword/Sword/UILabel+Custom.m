//
//  UILabel+Custom.m
//  Sword
//
//  Created by lee on 16/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "UILabel+Custom.h"
#import "UIColor+StringColor.h"

@implementation UILabel (Custom)

+ (instancetype)labelWithText:(NSString *)text textSize:(CGFloat)size textColor:(NSString *)hexString {
    
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = [UIColor ms_colorWithHexString:hexString];
    [label sizeToFit];
    return label;
}

@end
