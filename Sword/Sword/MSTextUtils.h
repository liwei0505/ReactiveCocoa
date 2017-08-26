//
//  MSTextUtils.h
//  Sword
//
//  Created by haorenjie on 16/5/26.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSTextUtils : NSObject

+ (BOOL)isEmpty:(NSString *)text;
+ (NSAttributedString *)attributedString:(NSString *)string unitLength:(NSInteger)unitLength;
+ (NSString *)format:(NSString *)format time:(long)interval;
+ (BOOL)isDigit:(NSString *)string;
+ (BOOL)isPureInt:(NSString *)string;
+ (BOOL)isPureFloat:(NSString *)string;
+ (NSString *)parserHeaderInteger:(NSString *)checkString;

@end
