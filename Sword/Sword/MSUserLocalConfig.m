//
//  MSUserLocalConfig.m
//  Sword
//
//  Created by lee on 17/3/13.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSUserLocalConfig.h"

NSString * const KEY_USER_ID = @"k_user_id";
NSString * const KEY_PATTERNLOCK = @"k_pl";
NSString * const KEY_SWITCH = @"k_switch";
NSString * const KEY_PHONE_NUMBER = @"k_pn";
NSString * const KEY_PATTERN_ERROR_COUNT = @"k_pattern_error_count";

@implementation MSUserLocalConfig

- (instancetype)init {
    if (self = [super init]) {
        _switchStatus = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if (self = [super init]) {
         _userId = [aDecoder decodeObjectForKey:KEY_USER_ID];
        _phoneNumber = [aDecoder decodeObjectForKey:KEY_PHONE_NUMBER];
        _patternLock = [aDecoder decodeObjectForKey:KEY_PATTERNLOCK];
        _switchStatus = [aDecoder decodeBoolForKey:KEY_SWITCH];
        _patternLockErrorCount = [aDecoder decodeIntForKey:KEY_PATTERN_ERROR_COUNT];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
 
    [aCoder encodeObject:self.userId forKey:KEY_USER_ID];
    [aCoder encodeObject:self.phoneNumber forKey:KEY_PHONE_NUMBER];
    [aCoder encodeObject:self.patternLock forKey:KEY_PATTERNLOCK];
    [aCoder encodeBool:self.switchStatus forKey:KEY_SWITCH];
    [aCoder encodeInt:self.patternLockErrorCount forKey:KEY_PATTERN_ERROR_COUNT];
}


@end
