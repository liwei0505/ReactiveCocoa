//
//  FileManager.h
//  MJS
//
//  Created by haorenjie on 16/2/1.
//  Copyright © 2016年 lw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (NSString *)getLogsDirPath;
+ (NSString *)getImagesDirPath;
+ (NSString *)getCrashesDirPath;
+ (NSString *)getFeedbackDirPath;

+ (NSString *)getDataBasePath;

+ (BOOL)isDirectory:(NSString *)path;
+ (BOOL)isDirExists:(NSString *)dirPath;
+ (BOOL)isFileExists:(NSString *)filePath;

+ (BOOL)mkdir:(NSString *)dirPath;
+ (NSArray *)subDirs:(NSString *)dirPath;

+ (BOOL)createFile:(NSString *)filePath;
+ (BOOL)deleteFile:(NSString *)filePath;

+ (BOOL)saveString:(NSString *)contents toFile:(NSString *)filePath;
+ (NSString *)getStringFromFile:(NSString *)filePath;

+ (BOOL)saveData:(NSData *)contents toFile:(NSString *)filePath;
+ (NSData *)getDataFromFile:(NSString *)filePath;

+ (BOOL)saveArray:(NSArray *)contents toFile:(NSString *)filePath;
+ (NSArray *)getArrayFromFile:(NSString *)filePath;

+ (BOOL)saveDictionary:(NSDictionary *)contents toFile:(NSString *)filePath;
+ (NSDictionary *)getDictionaryFromFile:(NSString *)filePath;

+ (id)getAttribute:(NSString *)attributeKey ofFile:(NSString *)filePath;

+ (BOOL)renameFile:(NSString *)origName toName:(NSString *)modifyName;

@end
