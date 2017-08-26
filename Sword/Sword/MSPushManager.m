//
//  MSPushManager.m
//  Sword
//
//  Created by haorenjie on 2017/3/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPushManager.h"
#import "GeTuiSdk.h"

@interface MSPushManager() <GeTuiSdkDelegate>
@property (copy, nonatomic) NSString *geTuiToken;
@end

@implementation MSPushManager

+ (instancetype)getInstance {
    static MSPushManager *sPushInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPushInstance = [[MSPushManager alloc] init];
    });
    
    return sPushInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self registerRemoteNotification];
    }
    return self;
}

- (NSString *)getDeviceToken{
    return self.geTuiToken;
}

- (void)registerDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.geTuiToken = token;
    [MSLog info:@"[DeviceToken Success]:%@",token];
    //向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

- (void)start:(BOOL)distribution {
    if (distribution) {
        [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    } else {
        [GeTuiSdk startSdkWithAppId:kGtTestAppId appKey:kGtTestAppKey appSecret:kGtTestAppSecret delegate:self];
    }
}

- (void)resume {
    [GeTuiSdk resume];
}

- (void)destroy {
    [GeTuiSdk destroy];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo {
    //标签推送
    NSString *tagName = @"个推,推送,iOS";
    NSArray *tagNames = [tagName componentsSeparatedByString:@","];
    if (![GeTuiSdk setTags:tagNames]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"设置失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

    [MSLog info:@"[Receive RemoteNotification - Background Fetch]:%@",userInfo];
}

#pragma mark - GeTuiSdkDelegate
/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    [MSLog info:@"[GeTuiSdk RegisterClient]:%@",clientId];
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //如果集成后，无法正常收到消息，查看这里的通知。
    [MSLog info:@"[GexinSdk error]:%@", [error localizedDescription]];
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes
                                              length:payloadData.length
                                            encoding:NSUTF8StringEncoding];
    }

    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@",taskId,msgId, payloadMsg,offLine ? @"<离线消息>" : @""];
    [MSLog info:@"[GexinSdk ReceivePayload]:%@", msg];

    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];

}

/**别名推送**
 // 绑定别名
 [GeTuiSdk bindAlias:@"个推研发"];
 // 取消绑定别名
 [GeTuiSdk unbindAlias:@"个推研发"];
 */

#pragma mark - private
- (void)registerRemoteNotification {
#ifdef __IPHONE_8_0
    UIUserNotificationType types = (UIUserNotificationTypeAlert |
                                    UIUserNotificationTypeSound |
                                    UIUserNotificationTypeBadge);

    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                   UIRemoteNotificationTypeSound |
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

@end
