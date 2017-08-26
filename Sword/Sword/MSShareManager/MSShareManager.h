//
//  MSShareManager.h
//  Sword
//
//  Created by lee on 16/7/12.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSQQApiResponse.h"
#import "MSWXApiResponse.h"
#import "MSWBApiResponse.h"

typedef enum {
    MSShareManager_invite,
    MSShareManager_share
}MSShareManagerType;

@interface MSShareManager : NSObject
@property (strong, nonatomic, readonly) MSQQApiResponse *qqApiResponse;
@property (strong, nonatomic, readonly) MSWXApiResponse *wxApiResponse;
@property (strong, nonatomic, readonly) MSWBApiResponse *wbApiResponse;
@property (copy, nonatomic) void(^selectedShareType)(NSString *title);

/**
  Forbids to create a new `MSShareManager` object, uses `[MSShareManager sharedManager]` instead.
*/
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedManager;
/**
 *  注册三方SDK
 */
- (void)ms_registerThirdShareSDK;
/**
 *  回调代理设置
 */
- (BOOL)ms_application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (BOOL)ms_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
/**
 *  UI界面
 */
- (void)ms_setShareUrl:(NSString *)shareUrl shareTitle:(NSString *)title shareContent:(NSString *)content shareIcon:(NSString *)iconUrl shareId:(NSString *)shareId shareType:(MSShareManagerType)shareType;
@end
