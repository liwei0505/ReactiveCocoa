//
//  MSLog.h
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/19.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#ifndef MSLog_h
#define MSLog_h

#import "Logger.h"

#define LOGV(FORMAT, ...) { \
    NSString *message = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; \
    NSString *filename = [NSString stringWithUTF8String:__FILE__]; \
    NSString *log = [NSString stringWithFormat:@"%@ [%@:%d]", message, [filename lastPathComponent], __LINE__]; \
    [MSLog verbose:log];\
}

#define LOGD(FORMAT, ...) { \
    NSString *message = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; \
    NSString *filename = [NSString stringWithUTF8String:__FILE__]; \
    NSString *log = [NSString stringWithFormat:@"%@ [%@:%d]", message, [filename lastPathComponent], __LINE__]; \
    [MSLog debug:log];\
}

#define LOGI(FORMAT, ...) { \
    NSString *message = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; \
    NSString *filename = [NSString stringWithUTF8String:__FILE__]; \
    NSString *log = [NSString stringWithFormat:@"%@ [%@:%d]", message, [filename lastPathComponent], __LINE__]; \
    [MSLog info:log];\
}

#define LOGW(FORMAT, ...) { \
    NSString *message = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; \
    NSString *filename = [NSString stringWithUTF8String:__FILE__]; \
    NSString *log = [NSString stringWithFormat:@"%@ [%@:%d]", message, [filename lastPathComponent], __LINE__]; \
    [MSLog warning:log];\
}

#define LOGE(FORMAT, ...) { \
    NSString *message = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; \
    NSString *filename = [NSString stringWithUTF8String:__FILE__]; \
    NSString *log = [NSString stringWithFormat:@"%@ [%@:%d]", message, [filename lastPathComponent], __LINE__]; \
    [MSLog error:log];\
}

#define LOG_CONFIG(OUTPUT, PRINT_LEVEL) { \
    [MSLog configOutput:OUTPUT printLevel:PRINT_LEVEL]; \
}

@interface MSLog : NSObject

+ (void)configOutput:(LogOutput)output printLevel:(LogLevel)level;
+ (void)verbose:(NSString *)message, ...;
+ (void)debug:(NSString *)message, ...;
+ (void)info:(NSString *)message, ...;
+ (void)warning:(NSString *)message, ...;
+ (void)error:(NSString *)message, ...;

@end

#endif /* MSLog_h */
