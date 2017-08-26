//
//  SensorsAnalyticsImpl.m
//  Sword
//
//  Created by lee on 16/11/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "SensorsAnalyticsImpl.h"
#import "MSDeviceUtils.h"
#import "TimeUtils.h"
#import "SensorsAnalyticsSDK.h"
#import "NSMutableDictionary+nilObject.h"

@interface SensorsAnalyticsImpl()

@property (assign, nonatomic) int forwardPageId;
@property (copy, nonatomic) NSString *forwardPageTitle;

@end

@implementation SensorsAnalyticsImpl

+ (SensorsAnalyticsImpl *)getInstance {

    static SensorsAnalyticsImpl *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SensorsAnalyticsImpl alloc] init];
    });
    
    return instance;
}

- (instancetype)init {

    if (self = [super init]) {
    }
    return self;
}

- (void)sendEventParams:(MSEventParams *)params {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setNoNilObject:self.sessionID forKey:@"session_id"];
    [dict setNoNilObject:[NSNumber numberWithInt:params.pageId] forKey:@"page_id"];
    [dict setNoNilObject:params.title forKey:@"$title"];
    [dict setNoNilObject:[NSNumber numberWithInt:params.elementId] forKey:@"element_id"];
    [dict setNoNilObject:params.elementText forKey:@"element_text"];
    
    if (params.params && params.params.allKeys.count > 0) {
        NSString *string = [self dictToString:params.params];
        [dict setObject:string forKey:@"params"];
    } else {
        [dict setObject:@"" forKey:@"params"];
    }
    [[SensorsAnalyticsSDK sharedInstance] track:@"AppElementClick" withProperties:dict];
    
}

- (void)sendPageParams:(MSPageParams *)params {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setNoNilObject:self.sessionID forKey:@"session_id"];
    [dict setNoNilObject:[NSNumber numberWithInt:params.pageId] forKey:@"page_id"];
    [dict setNoNilObject:params.title forKey:@"$title"];
    [dict setNoNilObject:[NSNumber numberWithInt:self.forwardPageId] forKey:@"referrer_page_id"];
    [dict setNoNilObject:self.forwardPageTitle forKey:@"referrer_title"];
    if (params.params && params.params.allKeys.count > 0) {
        NSString *string = [self dictToString:params.params];
        [dict setObject:string forKey:@"params"];
    } else {
        [dict setObject:@"" forKey:@"params"];
    }
    [[SensorsAnalyticsSDK sharedInstance] track:@"AppViewScreen" withProperties:dict];
    
    self.forwardPageId = params.pageId;
    self.forwardPageTitle = params.title;
}

- (void)sendEventName:(NSString *)name params:(NSDictionary *)params {
    [[SensorsAnalyticsSDK sharedInstance] track:name withProperties:params];
}

#pragma mark - private

- (NSString *)userID {
    if (!_userID) {
        _userID = @"";
    }
    return _userID;
}

- (NSString *)sessionID {
    if (!_sessionID) {
        _sessionID = @"";
    }
    return _sessionID;
}

- (NSString *)forwardPageTitle {
    if (!_forwardPageTitle) {
        _forwardPageTitle = @"";
    }
    return _forwardPageTitle;
}

- (NSString *)dictToString:(NSDictionary *)dict {

    NSError *error;
    //kNilOptions代替NSJSONWritingPrettyPrinted非格式化输出
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error]; //
    if (!data) {
        return @"";
    }
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return string;

}

@end
