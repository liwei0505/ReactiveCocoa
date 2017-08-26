//
//  RACEmptySubscriber.h
//  Sword
//
//  Created by haorenjie on 2017/3/22.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACEmptySubscriber : NSObject <RACSubscriber>

+ (instancetype)empty;

@end
