//
//  FileUtils.m
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/26.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileUtils.h"

@implementation FileUtils

+ (NSString *)getHomeDirectory
{
    return NSHomeDirectory();
}

+ (NSString *)getDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)getLibraryDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)getCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)getTempDirectory
{
    return NSTemporaryDirectory();
}

@end