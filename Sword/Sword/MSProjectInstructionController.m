//
//  MSProjectInstructionController.m
//  Sword
//
//  Created by haorenjie on 16/6/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSProjectInstructionController.h"
#import "MSProjectFileController.h"
#import "MSLog.h"
#import "MSConsts.h"
#import "MSAppDelegate.h"
#import "UIColor+StringColor.h"
#import "MSProjectFileCell.h"
#import "MJRefresh.h"
#import "ProjectInfo.h"
#import "MSFileDownLoader.h"
#import "MSLoadingView.h"
#import "RACError.h"

@interface MSProjectInstructionController ()<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) LoanDetail *loanInfo;
@property (strong, nonatomic) MSLoadingView *loadingView;
@end

@implementation MSProjectInstructionController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.type == INSTRUCTION_TYPE_RISK_WARNING) {
        self.title = NSLocalizedString(@"str_risk_warning", nil);
    } else if (self.type == INSTRUCTION_TYPE_DISCLAIMER) {
        self.title = NSLocalizedString(@"str_disclaimer", nil);
    } else if (self.type == INSTRUCTION_TYPE_TRADING_MANUAL) {
        self.title = NSLocalizedString(@"str_trading_manual", nil);
    } else {
        [MSLog warning:@"Unexpected project instruction type: %d", _type];
    }
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.webView.hidden = YES;
    self.webView.delegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 48;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    
    [self queryProjectInfo];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.title pageId:[self getPageId] params:nil];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [MSLog warning:@"didReceiveMemoryWarning"];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.loanInfo.productInfo.productFileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSProjectFileCell *cell = [MSProjectFileCell cellWithTableView:tableView];
    [cell updateContent:self.loanInfo.productInfo.productFileArray[indexPath.row] index:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSProjectFileController *projectFileController = [[MSProjectFileController alloc] init];
    ProductFileInfo *fileInfo = self.loanInfo.productInfo.productFileArray[indexPath.row];
    [projectFileController updateWithFileName:fileInfo.fileName fileUrl:fileInfo.filepath];
    [self.navigationController pushViewController:projectFileController animated:YES];
}

#pragma mark - privite
- (void)queryProjectInfo
{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryProjectInstructionByType:self.type loanId:self.loanId] subscribeNext:^(NSDictionary *dic) {
        @strongify(self);
        NSNumber *type_ = [dic objectForKey:KEY_INSTRUCTION_TYPE];
        if (type_.integerValue == self.type) {
            self.loanInfo = [[MSAppDelegate getServiceManager] getLoanInfo:self.loanId];
            [self updateProjectInstructionContents:self.loanInfo.productInfo];
        }
        
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSLog error:@"Query invest detail failed, result: %d", result.result];
    }];
}

- (void)updateProjectInstructionContents:(ProductInfo *)productInfo
{
    NSString *content = nil;
    NSArray *dataArr = nil;
    if (productInfo) {
        dataArr = productInfo.productFileArray;
        if (self.type == INSTRUCTION_TYPE_RISK_WARNING) {
            content = productInfo.riskDisclosure;
        } else if (self.type == INSTRUCTION_TYPE_DISCLAIMER) {
            content = productInfo.disclaimer;
        } else if (self.type == INSTRUCTION_TYPE_TRADING_MANUAL) {
            content = productInfo.tradingManual;
        }
    }
    
    if (dataArr && dataArr.count > 0) {
        if (dataArr.count > 1) {
            
            self.tableView.hidden = NO;
            self.webView.hidden = YES;
            [self.tableView reloadData];
            
        }else if (dataArr.count == 1){
            
            self.tableView.hidden = YES;
            ProductFileInfo *fileInfo = dataArr[0];
            self.navigationItem.title = fileInfo.fileName;
            
            [self deleteFile:fileInfo];
            
            self.loadingView = [[MSLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 50) * 0.5, (self.view.frame.size.height - 50) * 0.5, 50, 50)];
            self.loadingView.loadingViewType = MSLoadingViewType_text;
            [self.view addSubview:self.loadingView];
            
            @weakify(self);
            [[MSFileDownLoader shareInstance] ms_startDownloaderWithUrl:[NSURL URLWithString:fileInfo.filepath] pathExtension:[fileInfo.fileName pathExtension] progress:^(NSProgress *downloadProgress) {
                
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
        
    }else{
        
        self.tableView.hidden = YES;
        if (content) {
            self.webView.hidden = NO;
            [self.webView loadHTMLString:content baseURL:nil];
        }else{
            self.webView.hidden = YES;
        }
    }
}

- (void)deleteFile:(ProductFileInfo *)fileInfo
{
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"agreement.%@",[fileInfo.fileName pathExtension]]];
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

- (int)getPageId {

    int pageId = 0;
    switch (self.type) {
        case INSTRUCTION_TYPE_RISK_WARNING:
            pageId = 171;
            break;
        case INSTRUCTION_TYPE_DISCLAIMER:
            pageId = 174;
            break;
        case INSTRUCTION_TYPE_TRADING_MANUAL:
            pageId = 172;
            break;
    }
    return pageId;
}

@end
