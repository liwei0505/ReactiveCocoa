//
//  MSStatsAppInfo.m
//  Sword
//
//  Created by haorenjie on 16/7/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSStatsAppInfo.h"

@implementation MSStatsAppInfo

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.sessId forKey:@"sessId"];
    [dict setObject:self.uuid forKey:@"imei"];
    [dict setObject:@"Apple" forKey:@"brand"];
    [dict setObject:self.model forKey:@"model"];
    [dict setObject:@"iOS" forKey:@"os"];
    [dict setObject:self.osVer forKey:@"osVer"];
    [dict setObject:@"" forKey:@"ip"];
    [dict setObject:[NSNumber numberWithBool:self.root] forKey:@"root"];
    [dict setObject:self.appVer forKey:@"appVer"];
    [dict setObject:@"AppStore" forKey:@"channel"];
    [dict setObject:[NSNumber numberWithUnsignedLongLong:self.timestamp] forKey:@"timestamp"];
    [dict setObject:[NSNumber numberWithInt:self.netType] forKey:@"netType"];
    [dict setObject:[NSNumber numberWithInt:self.opType] forKey:@"sim"];
    return dict;
}

- (NSString *)toString
{
    NSMutableString *appInfoStr = [[NSMutableString alloc]init];
    [appInfoStr appendString:@"{"];
    NSDictionary *dict = [self toDictionary];
    for (NSString *key in dict.allKeys) {
        [appInfoStr appendString:[NSString stringWithFormat:@"%@ = %@, ", key, [dict objectForKey:key]]];
    }
    [appInfoStr appendString:@"}"];
    return appInfoStr;
}

@end
