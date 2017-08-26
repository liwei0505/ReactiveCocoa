//
//  Logger.h
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/25.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#ifndef Logger_h
#define Logger_h

typedef enum {
    VERBOSE,  // 0
    DBG,      // 1
    INFO,     // 2
    WARNING,  // 3
    ERROR,    // 4
    LEVEL_MAX // 5
} LogLevel;

typedef enum {
    OUTPUT_UNKNOWN, // 0
    OUTPUT_FILE,    // 1
    OUTPUT_CONSOLE, // 2
    OUTPUT_BOTH     // 3
} LogOutput;

@interface Logger : NSObject

+ (instancetype)sharedInstance;
- (void)setOutput:(LogOutput)output;
- (void)setPrintLevel:(LogLevel)level;
- (void)print:(NSString *)message level:(NSInteger)level;

@end

#endif /* Logger_h */
