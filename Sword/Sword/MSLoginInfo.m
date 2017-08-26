//
//  MSLoginInfo.m
//  Sword
//
//  Created by haorenjie on 2017/2/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSLoginInfo.h"

NSString * const KEY_USER_NAME = @"k_u";
NSString * const KEY_PASSWORD = @"k_p";
NSString * const KEY_UID = @"k_uid";

@implementation MSLoginInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _userId = [aDecoder decodeObjectForKey:KEY_UID];
        _userName = [aDecoder decodeObjectForKey:KEY_USER_NAME];
        _password = [aDecoder decodeObjectForKey:KEY_PASSWORD];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userId forKey:KEY_UID];
    [aCoder encodeObject:self.userName forKey:KEY_USER_NAME];
    [aCoder encodeObject:self.password forKey:KEY_PASSWORD];
}

@end
