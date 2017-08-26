//
//  ZKRequest.h
//  Sword
//
//  Created by haorenjie on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSHttpProxy.h"

@interface ZKRequest : NSObject

@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (copy, nonatomic) result_block_t block;
@property (assign, nonatomic) BOOL shouldAuthenticate;

@end
