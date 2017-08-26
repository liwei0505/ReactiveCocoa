//
//  FileManager.m
//  MJS
//
//  Created by haorenjie on 16/2/1.
//  Copyright © 2016年 lw. All rights reserved.
//

#import "FileManager.h"
#import "FileUtils.h"

@implementation FileManager

+ (NSString *)getDataBasePath {

    return [[FileUtils getDocumentDirectory] stringByAppendingPathComponent:@"FHDB.db"];
}

+ (NSString *)getLogsDirPath {
    NSString *docPath = [FileUtils getDocumentDirectory];
    NSString *logsPath = [docPath stringByAppendingPathComponent:@"logs"];
    return logsPath;
}

+ (NSString *)getImagesDirPath {
    NSString *docPath = [FileUtils getDocumentDirectory];
    NSString *imagesPath = [docPath stringByAppendingPathComponent:@"images"];
    return imagesPath;
}

+ (NSString *)getCrashesDirPath {
    NSString *logsPath = [FileManager getLogsDirPath];
    NSString *crashPath = [logsPath stringByAppendingPathComponent:@"crashes"];
    return crashPath;
}

+ (NSString *)getFeedbackDirPath {
    NSString *docPath = [FileUtils getDocumentDirectory];
    NSString *feedbackPath = [docPath stringByAppendingPathComponent:@"feedback"];
    [self mkdir:feedbackPath];
    return feedbackPath;
}

+ (BOOL)isDirectory:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    [fm fileExistsAtPath:path isDirectory:&isDir];
    return isDir;
}

+ (BOOL)isDirExists:(NSString *)dirPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [fm fileExistsAtPath:dirPath isDirectory:&isDir];
    return isDir && isExists;
}

+ (BOOL)isFileExists:(NSString *)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [fm fileExistsAtPath:filePath isDirectory:&isDir];
    return !isDir && isExists;
}

+ (BOOL)mkdir:(NSString *)dirPath {
    if ([FileManager isDirExists:dirPath]) {
        return YES;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:NULL error:NULL];
}

+ (NSArray *)subDirs:(NSString *)dirPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm subpathsAtPath:dirPath];
}

+ (BOOL)createFile:(NSString *)filePath {
    if ([FileManager isFileExists:filePath]) {
        return YES;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm createFileAtPath:filePath contents:nil attributes:nil];;
}

+ (BOOL)deleteFile:(NSString *)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm removeItemAtPath:filePath error:nil];
}

+ (BOOL)saveString:(NSString *)contents toFile:(NSString *)filePath {
    if (!contents || !filePath) {
        return NO;
    }

    return [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)getStringFromFile:(NSString *)filePath {
    if (!filePath || ![FileManager isFileExists:filePath]) {
        return nil;
    }

    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

+ (BOOL)saveData:(NSData *)contents toFile:(NSString *)filePath {
    if (!contents || !filePath) {
        return NO;
    }

    return [contents writeToFile:filePath atomically:YES];
}

+ (NSData *)getDataFromFile:(NSString *)filePath {
    if (!filePath || ![FileManager isFileExists:filePath]) {
        return nil;
    }

    return [NSData dataWithContentsOfFile:filePath];
}

+ (BOOL)saveArray:(NSArray *)contents toFile:(NSString *)filePath {
    if (!contents || !filePath) {
        return NO;
    }

    return [contents writeToFile:filePath atomically:YES];
}

+ (NSArray *)getArrayFromFile:(NSString *)filePath {
    if (!filePath || ![FileManager isFileExists:filePath]) {
        return nil;
    }

    return [NSArray arrayWithContentsOfFile:filePath];
}

+ (BOOL)saveDictionary:(NSDictionary *)contents toFile:(NSString *)filePath {
    if (!contents || !filePath) {
        return NO;
    }

    return [contents writeToFile:filePath atomically:YES];
}

+ (NSDictionary *)getDictionaryFromFile:(NSString *)filePath {
    if (!filePath || ![FileManager isFileExists:filePath]) {
        return nil;
    }

    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

+ (id)getAttribute:(NSString *)attributeKey ofFile:(NSString *)filePath {
    if (!filePath || ![FileManager isFileExists:filePath]) {
        return nil;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attributesDict = [fm attributesOfItemAtPath:filePath error:nil];
    return [attributesDict valueForKey:attributeKey];
}

+ (BOOL)renameFile:(NSString *)origName toName:(NSString *)modifyName {
    if (!origName || !modifyName) {
        return NO;
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [fm moveItemAtPath:origName toPath:modifyName error:&error];
    return (result && !error);
}

@end
