//
//  AppDelegate.m
//  Sword
//
//  Created by lee on 16/5/3.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSAppDelegate.h"
#import "MSMainController.h"
#import "MSNetworkMonitor.h"
#import "ZKSessionManager.h"
#import "MJSNotifications.h"
#import "MSLog.h"
#import "MSSettings.h"
#import "MSPatternLockController.h"
#import "MSHttpProxy.h"
#import "MJSStatistics.h"
#import "MSNetworkStatus.h"
#import "MSUrlManager.h"
#import "MSShareManager.h"
#import "MSConfig.h"
#import "MSVersionUtils.h"
#import "MJSServiceFactory.h"
#import "MSPushManager.h"
#import "MSDeviceUtils.h"
#import "MSTextUtils.h"

@interface MSAppDelegate ()<BuglyDelegate>

@property (strong, nonatomic) MSServiceManager *serviceManager;
@property (assign, nonatomic) BOOL isBackgroundLoad;

@end

@implementation MSAppDelegate

+ (MSAppDelegate *)getInstance {
    return (MSAppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (MSServiceManager *)getServiceManager {
    return [MSAppDelegate getInstance].serviceManager;
}

- (MSNavigationController *)getNavigationController {
    return (MSNavigationController *)self.window.rootViewController;
}

- (void)popViewControllerAnimated:(BOOL)animated {
    MSNavigationController *navi = (MSNavigationController *)self.window.rootViewController;
    [navi popViewControllerAnimated:YES];
}

#pragma mark - 判断加载控制器
- (void)chooseStartViewController {
    MSMainController *main = [[MSMainController alloc]init];
    MSNavigationController *rootNavController = [[MSNavigationController alloc] initWithRootViewController:main];
    self.window.rootViewController = rootNavController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    [MSLog configOutput:OUTPUT_BOTH printLevel:DBG];
    [MSUrlManager setHost:HOST_TEST];
#else
    [MSLog configOutput:OUTPUT_FILE printLevel:INFO];
    [MSUrlManager setHost:HOST_TEST];
#endif

    [MSLog info:@"applicationDidFinishLaunching"];

    //崩溃原因
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    [self initialize];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self chooseStartViewController];
    [self.window makeKeyAndVisible];
    [[MSShareManager sharedManager] ms_registerThirdShareSDK];
    [[MSPushManager getInstance] start:([MSUrlManager getHost] == HOST_PRODUCT)];
    [self buglyRegist];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [MSLog info:@"applicationWillResignActive"];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [MSSettings handleEnterBackground];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.isBackgroundLoad = YES;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithDouble:[MSSettings appActiveTime]] forKey:@"event_duration"];
    [MJSStatistics sendEventName:@"$AppEnd" params:params];
    [MSLog info:@"applicationDidEnterBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [MSLog info:@"applicationWillEnterForeground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [MSLog info:@"applicationDidBecomeActive"];
    
    //进入后台超过 300 秒
    if (![MSSettings isEnterBackgroundTimein]) {
        [RACEventHandler publish:[MJSUserBackOvertimeEvent new]];
    }
    
    MSLoginInfo *loginInfo = [MSSettings getLastLoginInfo];
    if ([MSSettings shouldShowPatternLockView:loginInfo.userId]) {
        
        MSPatternLockController *lockController = [[MSPatternLockController alloc] init];
        lockController.window = self.window;
        __weak typeof(self)weakSelf = self;
        lockController.patternLockInputBlock = ^{
        
            MSLoginInfo *loginInfo = [MSSettings getLastLoginInfo];
            if (loginInfo && ![MSTextUtils isEmpty:loginInfo.userName] && ![MSTextUtils isEmpty:loginInfo.password]) {
                [[[MSAppDelegate getServiceManager] loginWithUserName:loginInfo.userName password:loginInfo.password] subscribe:[RACEmptySubscriber empty]];
            } else {
                [MSLog error:@"user phonenumber is nil during patter lock login"];
                [MSToast show:@"手势密码失效，请重新登录"];
            }
            [weakSelf.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        
        };
        MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:lockController];
        [self.window.rootViewController presentViewController:nav animated:NO completion:nil];
    } else if (![MSSettings isEnterBackgroundTimein] && [[MSAppDelegate getServiceManager] isLogin]) {
        
        [[MSAppDelegate getServiceManager] logout];
        MSMainController *main = self.window.rootViewController.childViewControllers[0];
        main.selectedIndex = 0;
    }
    
    // 1:不需要更新 2:建议更新 3:强制更新
    if (![MSVersionUtils isAlertViewAlreadyShow]) {
        UpdateInfo *info = [[MSAppDelegate getServiceManager] getUpdateInfo];
        if (info.flag == 3) {
            [MSVersionUtils updateVersion:info];
        }
    }
    
    //Statistics
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithBool:[MSSettings isFirstVisit]] forKey:@"$is_first_time"];
    [params setObject:[NSNumber numberWithBool:_isBackgroundLoad] forKey:@"$resume_from_background"];
    [MJSStatistics sendEventName:@"$AppStart" params:params];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MSLog info:@"applicationWillTerminate"];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[MSShareManager sharedManager] ms_application:application handleOpenURL:url];
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[MSShareManager sharedManager] ms_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return NO;
}

void UncaughtExceptionHandler(NSException *exception){

    NSArray *arr = [exception callStackSymbols];//当前调用栈信息
    NSString *reason = [exception reason];//崩溃原因
    NSString *name = [exception name];//异常类型
    NSDictionary *dic = [exception userInfo];//用户信息
    NSLog(@"异常类型:%@\r\n崩溃原因:%@\r\n用户信息:%@\r\n当前调用栈信息:%@\r\n",name,reason,dic,arr);
    
}

//禁止三方键盘
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
    return NO;
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[MSPushManager getInstance] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[MSPushManager getInstance] resume];
    completionHandler(UIBackgroundFetchResultNewData);
}

/* 接受推送消息 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[MSPushManager getInstance] handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - Bugly callback

- (void)buglyRegist {

    NSString *appId;
    if ([MSUrlManager getHost] == HOST_PRODUCT) {
        appId = @"b59cd21f46";
    } else {
        appId = @"e18deba8a6";
    }
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.delegate = self;
    [Bugly setUserValue:[MSUrlManager getBaseUrl] forKey:@"BASE_URL"];
    [Bugly startWithAppId:appId config:config];
    
}

- (NSString *)attachmentForException:(NSException *)exception {

    NSString *message = nil;
    if ([MSAppDelegate getServiceManager].isLogin) {
        message = [NSString stringWithFormat:@"UserId:%@",[MSSettings getLastLoginInfo].userId];
    }
    return message;
}

- (void)initialize {
    HOST_TYPE hostType = [MSUrlManager getHost];
    MSHttpProxy *httpService = [[MSHttpProxy alloc] initWithHost:(hostType == HOST_PRODUCT)];
    ZKSessionManager *sessionManager = [[ZKSessionManager alloc] initWithHttpService:httpService];

//    [MJSStatistics regist];

    MJSServiceFactory *serviceFactory = [[MJSServiceFactory alloc] initWithSessionManager:sessionManager];
    _serviceManager = [[MSServiceManager alloc] initWithServiceFactory:serviceFactory];
    [[MSNetworkMonitor sharedInstance] startMonitor:^(NSInteger status) {
        [MSNotificationHelper notify:NOTIFY_NETWORK_STATUS_CHANGED result:[NSNumber numberWithInteger:status]];
        if (status == MSNetworkReachableViaWiFi || status == MSNetworkReachableViaWWAN) {
        }
    }];
}

@end
