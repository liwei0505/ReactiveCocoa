//
//  MSFormFile.m
//  Sword
//
//  Created by haorenjie on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSFormFile.h"
#import "FileManager.h"
#import "SSZipArchive.h"

@implementation MSFormFile

- (void)setFileName:(NSString *)fileName {
    _fileName = [fileName copy];
    if (self.filePath && [FileManager isDirectory:self.filePath]) {
        if (![self.fileName hasSuffix:@".zip"]) {
            self.fileName = [self.fileName stringByAppendingPathExtension:@"zip"];
        }
    }
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = [filePath copy];
    if (self.fileName && [FileManager isDirectory:_filePath]) {
        if (![self.fileName hasSuffix:@".zip"]) {
            self.fileName = [self.fileName stringByAppendingPathExtension:@"zip"];
        }
    }
}

- (NSData *)data {
    NSString *filePath = self.filePath;
    BOOL zipped = NO;
    if ([FileManager isDirectory:self.filePath]) {
        NSString *zipPath = [self.filePath stringByDeletingLastPathComponent];
        zipPath = [zipPath stringByAppendingPathComponent:self.fileName];
        if ([SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:self.filePath]) {
            filePath = zipPath;
            zipped = YES;
        } else {
            [MSLog error:@"File inflate failed."];
        }
    }
    NSData *contentsOfFile = [NSData dataWithContentsOfFile:filePath];
    if (zipped) {
        [FileManager deleteFile:filePath];
    }
    return contentsOfFile;
}

- (NSString *)mime {
    if ([self.fileName hasSuffix:@".zip"]) {
        return @"application/zip";
    } else if ([self.fileName hasSuffix:@".png"]) {
        return @"image/png";
    } else if ([self.fileName hasSuffix:@".jpg"] || [self.fileName hasSuffix:@".jpeg"]) {
        return @"image/jpeg";
    } else {
        return @"text/plain";
    }
}

@end
