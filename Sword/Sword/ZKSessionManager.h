//
//  ZKSessionManager.h
//  Sword
//
//  Created by haorenjie on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSHttpProxy.h"

@interface ZKSessionManager : NSObject

- (instancetype)initWithHttpService:(MSHttpProxy *)httpService;

- (void)resetSession;
- (void)post:(NSString *)url shouldAuthenticate:(BOOL)shouldAuthenticate params:(NSDictionary *)params result:(result_block_t)block;
- (void)postWeb:(NSString *)messageId params:(NSDictionary *)params result:(result_block_t)block;
- (void)get:(NSString *)url result:(result_block_t)block;
- (void)submitForm:(NSString *)url items:(NSArray *)items result:(result_block_t)block;
- (void)reloginForRequest:(NSString *)url result:(result_block_t)block;

- (NSString *)setSessionFor:(NSString *)url;
- (NSString *)getInvestAgreementById:(NSNumber *)debtId;

@end
