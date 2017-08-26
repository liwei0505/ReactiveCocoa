//
//  MSInsuranceprotocolViewController.m
//  Sword
//
//  Created by msj on 2017/8/24.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceprotocolViewController.h"
#import "MSFileDownLoader.h"
#import "MSLoadingView.h"

@interface MSInsuranceprotocolViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) MSLoadingView *loadingView;

@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *pathExtension;
@property (copy, nonatomic) NSString *fileUrl;
@end

@implementation MSInsuranceprotocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.webView.hidden = YES;
    self.webView.delegate = self;
    
    self.navigationItem.title = self.fileName;
    
    [self deleteFile];
    
    self.loadingView = [[MSLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 50) * 0.5, (self.view.frame.size.height - 50) * 0.5, 50, 50)];
    self.loadingView.loadingViewType = MSLoadingViewType_text;
    [self.view addSubview:self.loadingView];
    
    
    @weakify(self);
    [[MSFileDownLoader shareInstance] ms_startDownloaderWithUrl:[NSURL URLWithString:self.fileUrl] pathExtension:self.pathExtension  progress:^(NSProgress *downloadProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.loadingView.progress = 1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
        });
        
    } completionHandler:^( NSURL *filePath, NSError *error) {
        @strongify(self);
        [self.loadingView removeFromSuperview];
        self.webView.hidden = NO;
        if (error) {
            NSLog(@"出错了==%@",error);
            [self.webView loadHTMLString:@"下载失败，请检查您的网络连接!" baseURL:nil];
        }else{
            [self.webView loadRequest:[NSURLRequest requestWithURL:filePath]];
            
        }
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)updateWithFileName:(NSString *)fileName fileUrl:(NSString *)fileUrl {
    self.fileName = fileName;
    
    if (fileUrl.pathExtension && fileUrl.pathExtension.length > 0) {
        self.pathExtension = fileUrl.pathExtension;
    } else {
        self.pathExtension = @"pdf";
    }
    
    self.fileUrl = fileUrl;
}

- (void)deleteFile {
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"agreement.%@",self.pathExtension]];
    NSLog(@"%@",fullPath);
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    
    if (isExists) {
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.scrollView.contentSize = CGSizeMake(webView.scrollView.contentSize.width, webView.scrollView.contentSize.height + 60);
}

@end
