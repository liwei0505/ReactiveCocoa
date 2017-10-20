//
//  RACHandler.h
//  RAClearn
//
//  Created by lee on 2017/10/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACHandler : NSObject
+ (void)broadcast:(id)event;
+ (RACSignal *)observe:(Class)classType;

+ (void)publish:(id)subject;
+ (RACSignal *)subscribe:(Class)classType;
@end
