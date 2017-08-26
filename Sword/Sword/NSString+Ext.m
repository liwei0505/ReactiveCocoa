//
//  NSString+Ext.m
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "NSString+Ext.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString(Ext)

- (NSString *)md5 {
    const char *string = self.UTF8String;
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), buffer);
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x",buffer[i]];
    }
    return [result copy];
}

- (id)jsonToObject {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
}

- (NSDecimalNumber *)toDecicmalNumber {
    return [NSDecimalNumber decimalNumberWithString:self];
}

- (NSString *)hideWithKeepHeadLength:(NSUInteger)headLen tailLength:(NSUInteger)tailLen {
    if (self.length <= (headLen + tailLen)) {
        return self;
    }
    NSRange replaceRange = NSMakeRange(headLen, self.length - tailLen - headLen);

    return [self stringByReplacingCharactersInRange:replaceRange withString:@"*"];
}

- (NSString *)keepTailLength:(NSUInteger)tailLen {
    if (tailLen <= 0) {
        return self;
    }
    
    if (self.length < tailLen) {
        return self;
    }
    return [NSString stringWithFormat:@"***%@",[self substringFromIndex:self.length - tailLen]];
}

//密码加密  NSString* Des(NSString* str, NSString* key3Des)
+ (NSString*)desWithKey:(NSString*)str key:(NSString*)key3Des {
    if (key3Des == nil) {
        key3Des = @"123456789!@#$%^&*()_+QWE";
    }
    const void *vplainText;
    size_t plainTextBufferSize;
    
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    plainTextBufferSize = [data length];
    vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    // memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    const void *vkey = (const void *)[key3Des UTF8String];
    //加密的key
    NSString *gIv = @"01234567";
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       [gIv UTF8String],
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);

    if (ccStatus != kCCSuccess) {
        [MSLog error:@"Crypt failed, result: %d!", ccStatus];
        return nil;
    }
    
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    
    NSString *result = nil;
    
#ifdef __IPHONE_7_0
        result = [myData base64EncodedStringWithOptions:0];
#else
        result = [myData base64Encoding];
#endif
    return result;
}

+ (NSString *)countNumAndChangeformat:(NSString *)num
{
    int count = 0;
    long long int a = num.longLongValue;
    while (a != 0)
    {
        count++;
        a /= 10;
    }
    NSMutableString *string = [NSMutableString stringWithString:num];
    NSMutableString *newstring = [NSMutableString string];
    while (count > 3) {
        count -= 3;
        NSRange rang = NSMakeRange(string.length - 3, 3);
        NSString *str = [string substringWithRange:rang];
        [newstring insertString:str atIndex:0];
        [newstring insertString:@"," atIndex:0];
        [string deleteCharactersInRange:rang];
    }
    [newstring insertString:string atIndex:0];
    return newstring;
}

+ (NSString *)convertMoneyFormate:(double)amount {
    return [self convertMoneyFormate:amount style:MSAccuracyStyle_Two];
}

+ (NSString *)convertMoneyFormate:(double)amount style:(MSAccuracyStyle)style{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    switch (style) {
        case MSAccuracyStyle_Zero:
        {
            [numberFormatter setPositiveFormat:@"###,##0"];
            break;
        }
        case MSAccuracyStyle_One:
        {
            [numberFormatter setPositiveFormat:@"###,##0.0"];
            break;
        }
        case MSAccuracyStyle_Two:
        {
            [numberFormatter setPositiveFormat:@"###,##0.00"];
            break;
        }
        case MSAccuracyStyle_Three:
        {
            [numberFormatter setPositiveFormat:@"###,##0.000"];
            break;
        }
        case MSAccuracyStyle_Four:
        {
            [numberFormatter setPositiveFormat:@"###,##0.0000"];
            break;
        }
        default:
            break;
    }
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:amount]];
    return formattedNumberString;
    
}

+ (NSString *)convertMoneyFormate:(NSNumber *)amount accuracyStyle:(MSAccuracyStyle)style{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingMode = kCFNumberFormatterRoundDown;
    formatter.minimumIntegerDigits = 1;
    
    int accuracy = 0;
    switch (style) {
        case MSAccuracyStyle_Zero:
        {
            accuracy = 0;
            break;
        }
        case MSAccuracyStyle_One:
        {
            accuracy = 1;
            break;
        }
        case MSAccuracyStyle_Two:
        {
            accuracy = 2;
            break;
        }
        case MSAccuracyStyle_Three:
        {
            accuracy = 3;
            break;
        }
        case MSAccuracyStyle_Four:
        {
            accuracy = 4;
            break;
        }
        default:
            break;
    }
    
    
    formatter.minimumFractionDigits = accuracy;
    formatter.maximumFractionDigits = accuracy;
    
    NSString *str = [formatter stringFromNumber:amount];
    NSNumber *strNum = [formatter numberFromString:str];
    
    switch (style) {
        case MSAccuracyStyle_Zero:
        {
            [formatter setPositiveFormat:@"###,##0"];
            break;
        }
        case MSAccuracyStyle_One:
        {
            [formatter setPositiveFormat:@"###,##0.0"];
            break;
        }
        case MSAccuracyStyle_Two:
        {
            [formatter setPositiveFormat:@"###,##0.00"];
            break;
        }
        case MSAccuracyStyle_Three:
        {
            [formatter setPositiveFormat:@"###,##0.000"];
            break;
        }
        case MSAccuracyStyle_Four:
        {
            [formatter setPositiveFormat:@"###,##0.0000"];
            break;
        }
        default:
            break;
    }
    
    return [formatter stringFromNumber:strNum];
}

+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

+ (BOOL)stringCommentCheck:(NSString *)string {

    if (!string) {
        return false;
    }
    
    NSString *pattern = @"^[a-zA-Z0-9,.\u4e00-\u9fa5\\s\u3002\uff0c]+$";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"regular error");
    }
    NSTextCheckingResult *result;
    result = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if (result == nil) {
        return false;
    }
    return true;

}

@end
