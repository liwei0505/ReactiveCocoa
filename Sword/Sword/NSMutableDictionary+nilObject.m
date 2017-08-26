//
//  NSMutableDictionary+nilObject.m
//  Sword
//
//  Created by msj on 2017/3/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "NSMutableDictionary+nilObject.h"

@implementation NSMutableDictionary (nilObject)
- (void)setNoNilObject:(id)anObject forKey:(NSString *)key{
    if (!key || key.length == 0) {
        NSLog(@"key 不能为空");
        return;
    }
    if (!anObject) {
        NSLog(@"%@的value 不能为空",key);
        return;
    }
    [self setObject:anObject forKey:key];
}
@end
