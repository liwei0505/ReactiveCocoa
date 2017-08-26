//
//  MSWebViewController.m
//  Sword
//
//  Created by haorenjie on 16/6/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSWebViewController.h"
#import "MSLog.h"
#import "MSNetworkMonitor.h"
#import "MSToast.h"
#import "MSTextUtils.h"
#import "MSHttpProxy.h"
#import "MSMyInvestController.h"
#import "TimeUtils.h"
#import "MSUrlManager.h"
#import "MSHttpsConfigure.h"
#import "RACEmptySubscriber.h"
#import "MSPayManager.h"

@interface MSWebViewController()<UIWebViewDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *statusView;

@property (strong, nonatomic) UIWebView *webview;
@property (assign, nonatomic) BOOL authenticated;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (assign, nonatomic) UInt64 startLoadTime;

@property (copy, nonatomic) void (^payCompletion)(void);
@end

@implementation MSWebViewController

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureElement];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.payCompletion) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [MSProgressHUD showWithStatus:@"正在加载中..."];
    }
    
    if (self.loanId) {
        [self queryInvestContract:self.loanId];
    }
    
    if (self.url && self.url.length > 0) {
        [self loadUrl];
    }
    
    if (self.htmlContent && self.htmlContent.length > 0) {
        [self loadHtmlContent];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.payCompletion) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navigationController.interactivePopGestureRecognizer.delegate = (MSNavigationController *)self.navigationController;
    }
}

- (void)dealloc {
    if (self.webview.loading) {
        self.webview.delegate = nil;
        [self.webview stopLoading];
    }
    NSLog(@"%s",__func__);
}

#pragma mark - Public
+ (MSWebViewController *)load {
    MSWebViewController *webVC = [[MSWebViewController alloc] init];
    return webVC;
}

- (void)payUrl:(NSString *)url payCompletion:(void (^)(void))payCompletion {
    self.payCompletion = payCompletion;
    self.url = url;
}

#pragma mark - StatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.payCompletion) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private
- (void)queryInvestContract:(NSNumber *)loanId{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryInvestContractByLoanId:loanId] subscribeNext:^(NSDictionary *dic) {
        @strongify(self);
        NSNumber *loanId_ = [dic objectForKey:KEY_LOAN_ID];
        if (![self.loanId isEqualToNumber:loanId_]) {
            return;
        }
        
        NSNumber *type = [dic objectForKey:KEY_INSTRUCTION_TYPE];
        if (type.integerValue != INSTRUCTION_TYPE_INVEST_CONTRACT) {
            return;
        }
        
        NSString *contractContent = [dic objectForKey:KEY_CONTRACT_CONTENT];
        if (contractContent) {
            self.htmlContent = contractContent;
        } else {
            [MSLog error:@"Invest contract content is empty!"];
        }
        
    } error:^(NSError *error) {
        [MSToast show:NSLocalizedString(@"hint_check_network", nil)];
    }];
}

- (void)loadUrl {
    if ([[MSNetworkMonitor sharedInstance] isNetworkAvailable]) {
        NSURL *requestUrl = [NSURL URLWithString:self.url];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
        [self.webview loadRequest:request];
    } else {
        self.htmlContent = @"请检查您的网络~";
        [self loadHtmlContent];
    }
}

- (void)loadHtmlContent {
    if ([[MSNetworkMonitor sharedInstance] isNetworkAvailable]) {
        if ([MSTextUtils isEmpty:self.htmlContent]) {
            self.htmlContent = NSLocalizedString(@"str_webview_text_empty", @"");
        }
    } else {
        self.htmlContent = NSLocalizedString(@"str_network_error", @"");
    }
    [self.webview loadHTMLString:self.htmlContent baseURL:nil];
}

- (void)configureElement {
    
    self.authenticated = NO;
    
    if (self.payCompletion) {
        self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height)];
    } else {
        self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height - 64)];
    }
    [self.view addSubview:self.webview];
    self.webview.delegate = self;
    self.webview.opaque = NO;
    self.webview.backgroundColor = [UIColor clearColor];
    
    if (self.payCompletion) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        self.statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
        self.statusView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.statusView];
    }
    
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btnBack setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [btnBack addTarget:self action:@selector(backButtonOnClick) forControlEvents:UIControlEventTouchUpInside];

}

- (void)backButtonOnClick {
    
    if (self.payCompletion) {
        [MSNotificationHelper notify:NOTIFY_INVERANCE_LIST_RELOAD result:nil];
        [MSNotificationHelper notify:NOTIFY_POLICY_LIST_RELOAD result:nil];
        self.payCompletion();
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.payCompletion && gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        [self backButtonOnClick];
        return NO;
    }
    
    return YES;
}

#pragma mark - webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlstr = request.URL.absoluteString;
    NSArray  *urlArray = [urlstr componentsSeparatedByString:@"?"];
    NSString *header = [urlArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //单项认证
    NSString *scheme = request.URL.scheme;
    if ([scheme isEqualToString:@"https"] && self.authenticated == NO && ![header containsString:@"alipay.com"]) {
        self.authenticated  = NO;
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self.urlConnection start];
        return NO;
    }

    @weakify(self);
    // 支付跳转（支付宝APP）
    if ([header isEqualToString:@"https://mclient.alipay.com/cashier/mobilepay.htm"]) {
        [MSPayManager payInterceptorWithUrl:urlstr paySuccess:^(BOOL isSuccess, NSString *completePageUrl) {
            @strongify(self);

            if (isSuccess && completePageUrl && completePageUrl.length > 0) {
                NSURL *requestUrl = [NSURL URLWithString:completePageUrl];
                NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
                [self.webview loadRequest:request];
            } else {
                [self backButtonOnClick];
            }
        }];
        return YES;
    }
    
    // h5支付完成页面回调拦截
    if ([header isEqualToString:@"mjs://fhonlinepayresponse"]) {
        [self backButtonOnClick];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.startLoadTime = [TimeUtils currentTimeMillis];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *url = [webView.request.URL absoluteString];
    [MSLog verbose:[NSString stringWithFormat:@"[http_test] %@ %llu %llu",url,self.startLoadTime,[TimeUtils currentTimeMillis]]];
    [MSProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MSProgressHUD dismiss];
}

#pragma mark - NSURLConnection Delegate  //单项认证
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge; {
    if ([challenge previousFailureCount] == 0){
        self.authenticated = YES;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response; {
    self.authenticated = YES;
    NSURL *requestUrl = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    [self.webview loadRequest:request];
    
    [self.urlConnection cancel];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

#pragma mark - statistics
- (void)pageEvent {
    
    if (!self.pageId) {
        return;
    }
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = self.pageId;
    params.title = self.title ? self.title : @"";
    [MJSStatistics sendPageParams:params];
    
}

@end
