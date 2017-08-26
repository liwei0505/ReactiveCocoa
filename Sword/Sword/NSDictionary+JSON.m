//
//  NSDictionary+JSON.m
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary(JSON)

- (NSString *)jsonToString {
    __autoreleasing NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
