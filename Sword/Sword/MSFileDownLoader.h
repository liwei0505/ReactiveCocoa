//
//  MSFileDownLoader.h
//  showTime
//
//  Created by msj on 16/9/27.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSFileDownLoader : NSObject
+ (instancetype)shareInstance;
- (void)ms_startDownloaderWithUrl:(NSURL *)url pathExtension:(NSString *)pathExtension progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                               completionHandler:(void (^)(NSURL *filePath, NSError * error))completionHandler;
- (void)ms_cancel;
- (void)ms_suspend;
- (void)ms_resume;
@end
