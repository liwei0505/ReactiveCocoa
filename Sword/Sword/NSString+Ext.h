//
//  NSString+Ext.h
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSAccuracyStyle) {
    MSAccuracyStyle_Zero,
    MSAccuracyStyle_One,
    MSAccuracyStyle_Two,
    MSAccuracyStyle_Three,
    MSAccuracyStyle_Four
};

@interface NSString(Ext)

- (NSString *)md5;
- (id)jsonToObject;
- (NSDecimalNumber *)toDecicmalNumber;

- (NSString *)hideWithKeepHeadLength:(NSUInteger)headLen tailLength:(NSUInteger)tailLen;
- (NSString *)keepTailLength:(NSUInteger)tailLen;
+ (NSString*)desWithKey:(NSString*)str key:(NSString*)key3Des;
+ (NSString *)countNumAndChangeformat:(NSString *)num;
+ (NSString *)convertMoneyFormate:(double)amount;
+ (NSString *)convertMoneyFormate:(double)amount style:(MSAccuracyStyle)style;
+ (NSString *)convertMoneyFormate:(NSNumber *)amount accuracyStyle:(MSAccuracyStyle)style;


+ (BOOL)stringContainsEmoji:(NSString *)string;
+ (BOOL)stringCommentCheck:(NSString *)string;

@end
