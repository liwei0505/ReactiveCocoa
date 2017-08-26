//
//  Logger.m
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/25.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Logger.h"
#import "ConsolePrinter.h"
#import "FilePrinter.h"
#import "FileManager.h"
#import "TimeUtils.h"

@interface Logger()
{
    LogOutput mOutput;
    LogLevel mPrintLevel;
    NSMutableArray<ILogPrinter> *mPrinters;
}

@end

@implementation Logger

+ (instancetype)sharedInstance
{
    static Logger *sInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[Logger alloc] init];
    });

    return sInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        mPrinters = [[NSMutableArray<ILogPrinter> alloc] init];
        mOutput = OUTPUT_UNKNOWN;
        mPrintLevel = INFO;
    }
    return self;
}

- (void)setOutput:(LogOutput)output
{
    if (mOutput != OUTPUT_UNKNOWN) {
        // Avoid duplicate function calls.
        return;
    }

    mOutput = output;

    if (mOutput & OUTPUT_CONSOLE) {
        ConsolePrinter *console = [[ConsolePrinter alloc] init];
        [mPrinters addObject:console];
    }

    if (mOutput & OUTPUT_FILE) {
        FilePrinter *filePrinter = [[FilePrinter alloc] init];
        [mPrinters addObject:filePrinter];
    }
}

- (void)setPrintLevel:(LogLevel)level
{
    mPrintLevel = level;
}

- (void)print:(NSString *)message level:(NSInteger)level
{
    
    if (level < mPrintLevel) {
        // Log level is lower than current print requirement, ignored.
        return;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSS"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *log = [NSString stringWithFormat:@"[%@] [%@] %@\n", dateStr, [Logger logLevelToString:level], message];

    if (mOutput == OUTPUT_UNKNOWN) {
        [self setOutput:OUTPUT_CONSOLE];
    }

    unsigned long count = [mPrinters count];
    for (unsigned long i = 0; i < count; ++i) {
        NSObject<ILogPrinter> *printer = [mPrinters objectAtIndex:i];
        [printer print:log];
    }
}

+ (NSString *) logLevelToString:(NSInteger) level
{
    switch (level) {
        case VERBOSE: return @"V";
        case DBG: return @"D";
        case INFO: return @"I";
        case WARNING: return @"W";
        case ERROR: return @"E";
        default: return @"U";
    }
}

@end
