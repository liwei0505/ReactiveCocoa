//
//  MSLog.m
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/19.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MSLog.h"
#import "Logger.h"

@implementation MSLog

+ (void)configOutput:(LogOutput)output printLevel:(LogLevel)level
{
    Logger *logger = [Logger sharedInstance];
    [logger setOutput:output];
    [logger setPrintLevel:level];
}

+ (void)verbose:(NSString *)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *info = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    [[Logger sharedInstance] print:info level:VERBOSE];
}

+ (void)debug:(NSString *)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *info = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    [[Logger sharedInstance] print:info level:DBG];
}

+ (void)info:(NSString *)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *info = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    [[Logger sharedInstance] print:info level:INFO];
}

+ (void)warning:(NSString *)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *info = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    [[Logger sharedInstance] print:info level:WARNING];
}

+ (void)error:(NSString *)message, ...
{
    va_list args;
    va_start(args, message);
    NSString *info = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);

    [[Logger sharedInstance] print:info level:ERROR];
}

@end