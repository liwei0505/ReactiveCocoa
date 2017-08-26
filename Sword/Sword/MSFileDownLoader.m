//
//  MSFileDownLoader.m
//  showTime
//
//  Created by msj on 16/9/27.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "MSFileDownLoader.h"
#import "AFNetworking.h"
#import "MSHttpsConfigure.h"
#import "MSUrlManager.h"

@interface MSFileDownLoader ()
@property (strong, nonatomic) AFURLSessionManager *manager;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@end

@implementation MSFileDownLoader
+ (instancetype)shareInstance
{
    static MSFileDownLoader *fileDownLoader = nil;
    static dispatch_once_t sigletonOnceToken;
    dispatch_once(&sigletonOnceToken, ^{
        fileDownLoader = [[self alloc] init];
    });
    return fileDownLoader;
}
- (void)ms_startDownloaderWithUrl:(NSURL *)url pathExtension:(NSString *)pathExtension progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                completionHandler:(void (^)(NSURL *filePath, NSError * error))completionHandler;
{
    self.downloadTask = [self.manager downloadTaskWithRequest:[NSURLRequest requestWithURL:url] progress:^(NSProgress * _Nonnull downloadProgress) {
    
        downloadProgressBlock(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"agreement.%@",pathExtension]];
        return [NSURL fileURLWithPath:fullPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        completionHandler(filePath,error);
        
    }];
    
    [self.downloadTask resume];
}
- (void)ms_cancel
{
    [self.downloadTask cancel];
}
- (void)ms_suspend
{
    [self.downloadTask suspend];
}
- (void)ms_resume
{
    [self.downloadTask resume];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[AFURLSessionManager alloc] init];
        self.manager.securityPolicy = [MSHttpsConfigure defaultSecurityPolicy];
    }
    return self;
}
@end
