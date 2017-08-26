//
//  MSStatsEvent.m
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSStatsEvent.h"
#import "NSDictionary+JSON.h"

@implementation MSStatsEvent

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.sessId forKey:@"sessId"];
    [dict setObject:self.userId forKey:@"userId"];
    [dict setObject:[NSNumber numberWithUnsignedLongLong:self.timestamp] forKey:@"timestamp"];
    [dict setObject:[NSNumber numberWithInt:self.pageId] forKey:@"pageId"];
    [dict setObject:[NSNumber numberWithInt:self.eventId] forKey:@"eventId"];
    [dict setObject:[NSNumber numberWithInt:self.controlId] forKey:@"controlId"];
    if (self.param) {
        NSString *jsonStr = [self.param jsonToString];
        NSString *trimStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        trimStr = [trimStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        [dict setObject:trimStr forKey:@"param"];
    }
    return dict;
}

- (NSString *)toString
{
    NSMutableString *eventStr = [[NSMutableString alloc]init];
    [eventStr appendString:@"{"];
    NSDictionary *dict = [self toDictionary];
    for (NSString *key in dict.allKeys) {
        [eventStr appendString:[NSString stringWithFormat:@"%@ = %@, ", key, [dict objectForKey:key]]];
    }
    [eventStr appendString:@"}"];
    return eventStr;
}

@end
