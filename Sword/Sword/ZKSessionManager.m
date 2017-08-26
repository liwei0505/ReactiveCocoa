//
//  ZKSessionManager.m
//  Sword
//
//  Created by haorenjie on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "ZKSessionManager.h"
#import "MSUrlManager.h"
#import "ZKRequest.h"
#import "MSConsts.h"
#import "MSDeviceUtils.h"
#import "MSTextUtils.h"
#import "MJSNotifications.h"
#import "MSToast.h"
#import "MSLog.h"
#import "MSUrlManager.h"
#import "MSPushManager.h"

const unsigned int SESSION_TIMEOUT = -200;

typedef NS_ENUM(NSInteger, ZKSessionStatus) {
    ZKSESSION_INVALID,
    ZKSESSION_REFETCHING,
    ZKSESSION_ACTIVITED,
};

@interface ZKSessionManager()
{
    MSHttpProxy *_httpService;
    MSHttpProxy *_h5Service;
    NSMutableArray *_pendingRequestList;
    ZKSessionStatus _sessionStatus;
}

@property (copy, nonatomic) NSString *sessionId;
@property (strong, nonatomic) ZKRequest *loginRequest;

@end

@implementation ZKSessionManager

- (instancetype)initWithHttpService:(MSHttpProxy *)httpService
{
    if (self = [super init]) {
        _httpService = httpService;
        _h5Service = [[MSHttpProxy alloc] init];
        _pendingRequestList = [[NSMutableArray alloc] init];
        _sessionStatus = ZKSESSION_INVALID;
    }
    return self;
}

- (NSString *)getInvestAgreementById:(NSNumber *)debtId;
{
    if ([MSTextUtils isEmpty:self.sessionId]) {
        return nil;
    }
    NSString *url = [self getWebUrl:@"debt/debtAgreementOut?"];
    NSString *result = [NSString stringWithFormat:@"%@sessionId=%@&loanInvestorId=%@", url, self.sessionId, debtId];
    return result;
}

- (void)resetSession
{
    self.loginRequest = nil;
    self.sessionId = nil;
    _sessionStatus = ZKSESSION_INVALID;
}

- (void)post:(NSString *)url shouldAuthenticate:(BOOL)shouldAuthenticate params:(NSDictionary *)params result:(result_block_t)block
{
    ZKRequest *request = [ZKRequest new];
    request.url = url;
    request.shouldAuthenticate = shouldAuthenticate;
    [request.params setDictionary:params];
    request.block = block;

    if (request.shouldAuthenticate) {
        if (_sessionStatus == ZKSESSION_INVALID || [MSTextUtils isEmpty:self.sessionId]) {
            request.block(ERR_NOT_LOGIN, nil);
        } else if (_sessionStatus == ZKSESSION_REFETCHING) {
            [_pendingRequestList addObject:request];
        } else {
            [request.params setObject:self.sessionId forKey:@"sessionId"];
            [self post:request];
        }
        
    } else {
        [self post:request];
    }
}

- (void)post:(ZKRequest *)request
{
    [_httpService post:request.url params:request.params result:^(int httpResult, NSDictionary *response) {
        int result = [self getResult:httpResult fromResponse:response];
        if (result == ERR_NONE && [self isLoginRequest:request.url]) {
            self.loginRequest = request;
            [self saveSession:[response objectForKey:@"sessionId"]];
        }

        NSString *sessionId = [response objectForKey:@"sessionId"];
        if (![MSTextUtils isEmpty:sessionId] && _sessionStatus != ZKSESSION_REFETCHING && ![sessionId isEqualToString:_sessionId]) {
            [MSLog warning:@"Drop the response of the request: %@", request.url];
            request.block(ERR_INVALID_STATE, nil);
            return;
        }
        
        if (result == SESSION_TIMEOUT) {
            if (_sessionStatus == ZKSESSION_REFETCHING) {
                [_pendingRequestList addObject:request];
            } else if (_sessionStatus == ZKSESSION_INVALID) {
                request.block(ERR_INVALID_STATE, nil);
                for (ZKRequest *pendingRequest in _pendingRequestList) {
                    pendingRequest.block(ERR_CANCELLED, nil);
                }
                [_pendingRequestList removeAllObjects];
            } else {
                [self refetchSession:^(int httpResult, NSDictionary *response) {
                    int result = [self getResult:httpResult fromResponse:response];
                    if (result == ERR_NONE) {
                        [self saveSession:[response objectForKey:@"sessionId"]];
                        [request.params setObject:self.sessionId forKey:@"sessionId"];
                        [self post:request];
                    } else {
                        [self resetSession];
                        request.block(ERR_NOT_LOGIN, nil);
                    }
                }];
            }
        } else {
            if (request.shouldAuthenticate && _sessionStatus == ZKSESSION_INVALID) {
                request.block(ERR_INVALID_STATE, nil);
                return;
            }

            request.block(result, response);

            if (result == ERR_LOGIN_KICK) {
                //互踢通知
                [self resetSession];
                [MSNotificationHelper notify:NOTIFY_USER_KICK result:nil];
            } else if (self.sessionId && _pendingRequestList.count > 0) {
                ZKRequest *request = [_pendingRequestList lastObject];
                [_pendingRequestList removeLastObject];
                [request.params setObject:self.sessionId forKey:@"sessionId"];
                [self post:request];
            }
        }
    }];
}

- (void)postWeb:(NSString *)messageId params:(NSDictionary *)params result:(result_block_t)block
{
    NSString *baseUrl = [self getWebUrl:messageId];
    NSMutableDictionary *httpParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [httpParams setObject:self.sessionId forKey:@"sessionId"];
    [_httpService postString:baseUrl params:httpParams result:block];
}

- (void)get:(NSString *)url result:(result_block_t)block
{
    if (!url) {
        [MSLog error:@"url is empty."];
        return;
    }

    NSString *baseUrl = [MSUrlManager getBaseUrl];
    if ([url containsString:baseUrl]) {
        [_httpService get:url result:block];
    } else {
        [_h5Service get:url result:block];
    }
}

- (void)submitForm:(NSString *)url items:(NSArray *)items result:(result_block_t)block {
    [_httpService submitForm:url items:items result:block];
}

- (void)reloginForRequest:(NSString *)url result:(result_block_t)block
{
    [self refetchSession:^(int httpResult, NSDictionary *response) {
        int result = [self getResult:httpResult fromResponse:response];
        if (result == ERR_NONE) {
            [self saveSession:[response objectForKey:@"sessionId"]];

            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSString *updatedUrl = [self updateURLSessionID:url];
            if (updatedUrl) {
                [dict setObject:updatedUrl forKey:@"url"];
                block(ERR_NONE, dict);
            } else {
                block(ERR_INPUT_INVALID, nil);
            }
        } else {
            [self resetSession];
            block(ERR_NOT_LOGIN, nil);
        }
    }];
}

- (void)saveSession:(NSString *)sessionID
{
    self.sessionId = sessionID;
    _sessionStatus = ZKSESSION_ACTIVITED;
    
    [MJSStatistics setSessionID:self.sessionId];
}

- (NSString *)setSessionFor:(NSString *)url
{
    if ([MSTextUtils isEmpty:self.sessionId]) {
        return nil;
    }

    NSString *format = @"%@?sessionId=%@";
    if ([url containsString:@"?"]) {
        format = @"%@&sessionId=%@";
    }
    return [NSString stringWithFormat:format, url, self.sessionId];
}

- (NSString *)getWebUrl:(NSString *)messageId {
    NSString *protocol = [MSUrlManager getBaseUrl];
    return [NSString stringWithFormat:@"%@%@", protocol, messageId];
}

- (BOOL)isLoginRequest:(NSString *)url
{
    return url && [url containsString:@"login"];
}

- (int)getResult:(int)httpResult fromResponse:(NSDictionary *)response {
    int result = httpResult;
    
    if (httpResult == ERR_NONE) {
        result = [[response objectForKey:@"statusCode"] intValue];
        NSString *message = [response objectForKey:@"statusMessage"];
        if (result == -200 || result == -100) {
            result = SESSION_TIMEOUT;
        } else if (result == -2 || [NSLocalizedString(@"hint_login_kick_out", nil) isEqualToString:message]) {
            result = ERR_LOGIN_KICK;
        } else if (result == -3) {
            result = ERR_NOT_SUPPORT;
        } else if (result == -4) {
            result = ERR_SERVER;
        }
    }
    return result;
}

- (void)refetchSession:(result_block_t)block
{
    self.sessionId = nil;
    _sessionStatus = ZKSESSION_REFETCHING;
    [_httpService post:self.loginRequest.url params:self.loginRequest.params result:block];
}

- (NSString *)updateURLSessionID:(NSString *)url {
    if ([MSTextUtils isEmpty:url]) {
        return nil;
    }

    NSRange range = [url rangeOfString:@"?"];
    NSString *paramString = [url substringFromIndex:range.location + 1];

    NSArray *params = [paramString componentsSeparatedByString:@"&"];

    NSString *sessionValue = nil;
    for (NSString *param in params) {
        NSArray *kv = [param componentsSeparatedByString:@"="];
        if (kv.count != 2) {
            continue;
        }

        NSString *key = [kv firstObject];
        if ([@"sessionId" isEqualToString:key]) {
            sessionValue = [kv lastObject];
            break;
        }
    }

    if (sessionValue) {
        return [url stringByReplacingOccurrencesOfString:sessionValue withString:self.sessionId];
    }

    return nil;
}

@end
