//
//  MSLabel.m
//  Sword
//
//  Created by lee on 16/9/28.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSLabel.h"
#import "UIColor+StringColor.h"

@implementation MSLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)labelWithText:(NSString *)text textSize:(CGFloat)size textColor:(NSString *)hexString {

    MSLabel *label = [[MSLabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = [UIColor ms_colorWithHexString:hexString];
    return label;
}

@end
