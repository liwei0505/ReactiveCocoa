//
//  InsurantInfo.m
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "InsurantInfo.h"

@implementation InsurantInfo

- (instancetype)init {
    if (self = [super init]) {
        _relationship = RELATIONSHIP_SELF;
        _certificateType = CERTIFICATE_TYPE_ID_CARD;
    }
    return self;
}

- (NSString *)description {
    
    
    NSMutableString *sb = [[NSMutableString alloc] init];
    [sb appendFormat:@"Class InsurantInfo \n"];
    [sb appendFormat:@" name: %@ \n", self.name];
    [sb appendFormat:@" relationship: %lu \n", (unsigned long)self.relationship];
    [sb appendFormat:@" certificateType: %lu \n", (unsigned long)self.certificateType];
    [sb appendFormat:@" certificateId: %@ \n", self.certificateId];
    [sb appendFormat:@" mobile: %@ \n", self.mobile];
    [sb appendFormat:@"} \n"];
    return sb;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:5];
    [dict setObject:self.name forKey:@"name"];
    [dict setObject:[NSNumber numberWithUnsignedInteger:self.relationship] forKey:@"relationship"];
    [dict setObject:[NSNumber numberWithUnsignedInteger:self.certificateType] forKey:@"certificateType"];
    [dict setObject:self.certificateId forKey:@"certificateId"];
    [dict setObject:self.mobile forKey:@"mobile"];
    return dict;
}

@end
