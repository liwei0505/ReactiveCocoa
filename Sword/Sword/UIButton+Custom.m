//
//  UIButton+Custom.m
//  Sword
//
//  Created by lee on 16/11/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "UIButton+Custom.h"
#import "UIColor+StringColor.h"

@implementation UIButton (Custom)

+ (UIButton *)ms_createPatternButton:(NSString *)title {

    UIButton *button = [self ms_buttonWithAttributeTitle:title color:@"#555555" fontSize:18];
    NSDictionary *attributeHighlight = @{NSForegroundColorAttributeName:[UIColor ms_colorWithHexString:@"#44C0FF"]};
    NSAttributedString *stringHighlight = [[NSAttributedString alloc] initWithString:title attributes:attributeHighlight];
    [button setAttributedTitle:stringHighlight forState:UIControlStateHighlighted];
    
    return button;

}

+ (UIButton *)ms_buttonWithAttributeTitle:(NSString *)title color:(NSString *)color fontSize:(float)size {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *attributeNormal = @{NSFontAttributeName:[UIFont systemFontOfSize:size],NSForegroundColorAttributeName:[UIColor ms_colorWithHexString:color]};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:attributeNormal];
    [button setAttributedTitle:string forState:UIControlStateNormal];
    return button;
    
}

+ (UIButton *)ms_buttonWithTitle:(NSString *)title color:(NSString *)color fontSize:(float)size {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor ms_colorWithHexString:color] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:size]];
    [button setTitle:title forState:UIControlStateNormal];
    return  button;
}

+ (UIButton *)ms_itemButtonWithTitle:(NSString *)title {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button_all"] forState:UIControlStateNormal];
    //    NSDictionary *attributeNormal = @{NSFontAttributeName:[UIFont systemFontOfSize:18.0]};
    //    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:attributeNormal];
    //    [button setAttributedTitle:string forState:UIControlStateNormal];
    return button;
}

@end
