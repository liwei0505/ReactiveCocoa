//
//  MSTextUtils.m
//  Sword
//
//  Created by haorenjie on 16/5/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSTextUtils.h"
#import <UIKit/UIKit.h>

@implementation MSTextUtils

+ (BOOL)isEmpty:(NSString *)text {
    return !text || [text isKindOfClass:[NSNull class]] || text.length == 0;
}

+ (NSAttributedString *)attributedString:(NSString *)string unitLength:(NSInteger)unitLength
{
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:string];

    [attribString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:19] range:NSMakeRange(0, string.length - unitLength)];
    NSRange range = NSMakeRange(string.length - unitLength, unitLength);
    [attribString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:range];
    [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];

    return attribString;
}

+ (NSString *)format:(NSString *)format time:(long)interval
{
    int days = (int)interval / (3600 * 24);
    interval = interval % (3600 * 24);
    int hours = (int)interval / 3600;
    interval = interval % 3600;
    int minutes = (int)interval / 60;
    int seconds = (int)interval % 60;
    return [NSString stringWithFormat:format, days, hours, minutes, seconds];
}

+ (BOOL)isDigit:(NSString *)string
{
    return [MSTextUtils isPureInt:string] || [MSTextUtils isPureFloat:string];
}

+ (BOOL)isPureInt:(NSString *)string
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    int val;
    return [scanner scanInt:&val] && [scanner isAtEnd];
}

+ (BOOL)isPureFloat:(NSString *)string
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    float val;
    return [scanner scanFloat:&val] && [scanner isAtEnd];
}

+ (NSString *)parserHeaderInteger:(NSString *)checkString
{
    NSString *patten = @"^[0-9]+";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:patten options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:checkString options:0 range:NSMakeRange(0, checkString.length)];
    for (NSTextCheckingResult *result in results) {
        return [checkString substringWithRange:result.range];
    }
    return nil;
}



@end
