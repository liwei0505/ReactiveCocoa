//
//  TimeUtils.h
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/26.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#ifndef TimeUtils_h
#define TimeUtils_h

@interface TimeUtils : NSObject

+ (NSDate *)date;
+ (UInt64)currentTimeMillis;
+ (NSString *)timeSince1970;
+ (NSDate *)convertToUTCDate:(NSDate *)date;
+ (NSString *)detailDateString;
+ (UInt64)convertToUTCTimestampFromString:(NSString *)timeStr;
+ (NSString *)convertToDateStringFromTimestamp:(UInt64)timestamp;

@end

#endif /* TimeUtils_h */
