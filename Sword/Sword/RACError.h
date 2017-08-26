//
//  MSRequestResult.h
//  Sword
//
//  Created by haorenjie on 16/5/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACError : NSError

@property (assign, nonatomic) NSInteger result;
@property (copy, nonatomic) NSString *message;

+ (RACError *)createDefaultResult;

@end
