//
//  ConsolePrinter.m
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/25.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConsolePrinter.h"

@implementation ConsolePrinter

- (void)print:(NSString *)log
{
    printf("%s", [log UTF8String]);
}

@end