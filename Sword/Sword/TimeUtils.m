//
//  TimeUtils.m
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/26.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TimeUtils.h"

@implementation TimeUtils

+ (NSDate *)date
{
    return [TimeUtils convertToUTCDate:[NSDate date]];
}

+ (UInt64)currentTimeMillis
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    return time * 1000;
}

+ (NSString *)timeSince1970 {

    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%ld",(long)time];
    return timeString;
}

+ (NSDate *)convertToUTCDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }

    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    return [date dateByAddingTimeInterval:interval];
}

+ (NSString *)detailDateString {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd HH:mm:ss"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    return date;
}

+ (UInt64)convertToUTCTimestampFromString:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:timeStr];
    return [date timeIntervalSince1970] * 1000;
}

+ (NSString *)convertToDateStringFromTimestamp:(UInt64)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(timestamp / 1000)];
    return [formatter stringFromDate:date];
}

@end
