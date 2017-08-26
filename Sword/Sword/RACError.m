//
//  MSRequestResult.m
//  Sword
//
//  Created by haorenjie on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "RACError.h"
#import "MSTextUtils.h"

@implementation RACError

+ (RACError *)createDefaultResult {
    RACError *result = [[RACError alloc] init];
    result.result = ERR_NONE;
    return result;
}

- (instancetype)init
{
    if (self = [super initWithDomain:@"com.mjsfax.mjs" code:ERR_NONE userInfo:nil]) {
        _result = ERR_NONE;
        _message = @"";
    }
    return self;
}

- (NSString *)message {
    if (_result == ERR_UNKNOWN) {
        return [MSTextUtils isEmpty:_message] ?  NSLocalizedString(@"err_unknonw", @"") : _message;
    }

    if (_result == ERR_NETWORK) {
        return NSLocalizedString(@"err_network", @"");
    }

    if (_result == ERR_JSON_PARSE) {
        return NSLocalizedString(@"err_json_parser", @"");
    }

    if (_result == ERR_ALREADY_EXISTS) {
        return NSLocalizedString(@"err_already_exist", @"");
    }

    if (_result == ERR_SERVER) {
        return NSLocalizedString(@"err_server", @"");
    }

    if (_result == ERR_NOT_LOGIN) {
        return NSLocalizedString(@"err_not_login", @"");
    }

    if (_result == ERR_NOT_EXISTS) {
        return NSLocalizedString(@"err_not_exists", @"");
    }

    if (_result == ERR_LOGIN_KICK) {
        return NSLocalizedString(@"err_login_kick", @"");
    }

    if (_result == ERR_NOT_SUPPORT) {
        return NSLocalizedString(@"err_not_support", @"");
    }

    if (_result == ERR_CANCELLED) {
        return NSLocalizedString(@"err_cancelled", @"");
    }

    if (_result == ERR_INVALID_STATE) {
        return NSLocalizedString(@"err_invalid_state", @"");
    }

    return _message;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"RACError result: %ld, message: %@", (long)self.result, self.message];
}

@end
