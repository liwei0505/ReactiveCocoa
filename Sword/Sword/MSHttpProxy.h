//
//  MSHttpProxy.h
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSConsts.h"
#import "MSFormInfo.h"

@interface MSHttpProxy : NSObject

typedef void(^result_block_t)(int result, NSDictionary *response);

- (instancetype)initWithHost:(BOOL)distribution;
- (void)get:(NSString *)url result:(result_block_t)block;
- (void)post:(NSString *)url params:(NSDictionary *)params result:(result_block_t)block;
- (void)postString:(NSString *)url params:(NSDictionary *)params result:(result_block_t)block;
- (void)submitForm:(NSString *)url items:(NSArray<MSFormInfo *> *)items result:(result_block_t)block;

@end
