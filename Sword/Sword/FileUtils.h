//
//  FileUtils.h
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/26.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#ifndef FileUtils_h
#define FileUtils_h

// ==================================================
// Application sandbox directories
// application home
//   - *.app
//   - Documents
//   - Library
//     -- Caches
//     -- Preferences
//   - tmp
// ==================================================

@interface FileUtils : NSObject

+ (NSString *)getHomeDirectory;
+ (NSString *)getDocumentDirectory;
+ (NSString *)getLibraryDirectory;
+ (NSString *)getCacheDirectory;
+ (NSString *)getTempDirectory;

@end


#endif /* FileUtils_h */
