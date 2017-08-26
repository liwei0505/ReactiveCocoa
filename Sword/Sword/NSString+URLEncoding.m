//
//  NSString+URLEncoding.m
//  bbm(user)
//
//  Created by 王洋洋 on 15/4/6.
//  Copyright (c) 2015年 BBM. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString(URLEncoding)

- (NSString *)URLEncodedString{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[] "), kCFStringEncodingUTF8));
    return result;
}

- (NSString*)URLDecodedString{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                                            CFSTR(""),
                                                                                           kCFStringEncodingUTF8));
    return result;
}

@end
