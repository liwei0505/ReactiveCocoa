//
//  NSMutableDictionary+nilObject.h
//  Sword
//
//  Created by msj on 2017/3/15.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (nilObject)
- (void)setNoNilObject:(id)anObject forKey:(NSString *)key;
@end
