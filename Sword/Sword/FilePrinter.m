//
//  FilePrinter.m
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/25.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FilePrinter.h"
#import "FileManager.h"
#import "TimeUtils.h"

const double LOG_SAVE_TIME_INTERVAL = 3 * 24 * 60 * 60; // 3 days.

@interface FilePrinter()
{
    dispatch_queue_t mPrintQueue;
    NSFileHandle *mFileHandle;
}

@end

@implementation FilePrinter

- (id)init
{
    mPrintQueue = dispatch_queue_create("FileLogPrinter", NULL);

    dispatch_async(mPrintQueue, ^{
        NSString *logPath = [FileManager getLogsDirPath];
        [FileManager mkdir:logPath];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy_MM_dd"];
        NSDate *now = [TimeUtils date];
        NSString *filename = [[formatter stringFromDate:now] stringByAppendingPathExtension:@"log"];
        NSString *fullname = [logPath stringByAppendingPathComponent:filename];
        [FileManager createFile:fullname];

        mFileHandle = [NSFileHandle fileHandleForWritingAtPath:fullname];

        NSArray *logFiles = [FileManager subDirs:logPath];
        for (int i = 0; i < logFiles.count; ++i) {
            NSString *logFullName = [logFiles objectAtIndex:i];
            NSString *logName = [[logFullName lastPathComponent] stringByDeletingPathExtension];
            NSDate *date = [TimeUtils convertToUTCDate:[formatter dateFromString:logName]];
            NSTimeInterval interval = [now timeIntervalSinceDate:date];
            if (interval > LOG_SAVE_TIME_INTERVAL) {
                [FileManager deleteFile:logFullName];
            }
        }
    });

    return self;
}

- (void)dealloc
{
    dispatch_async(mPrintQueue, ^{
        [mFileHandle closeFile];
        mFileHandle = nil;
    });

}

- (void)print:(NSString *)log
{
    dispatch_async(mPrintQueue, ^{
        if (mFileHandle) {
            [mFileHandle seekToEndOfFile];
            [mFileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        }
    });
}

@end