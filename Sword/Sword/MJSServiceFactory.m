//
//  MJSServiceFactory.m
//  Sword
//
//  Created by haorenjie on 2017/2/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MJSServiceFactory.h"
#import "MSUserService.h"
#import "MSPayService.h"
#import "MSOperatingService.h"
#import "ZKProtocol.h"
#import "InsuranceProtocol.h"

@interface MJSServiceFactory()
{
    ZKSessionManager *_sessionManager;
    id<IMJSProtocol> _protocol;
}

@end

@implementation MJSServiceFactory

- (instancetype)initWithSessionManager:(ZKSessionManager *)sessionManager {
    if (self = [super init]) {
        _sessionManager = sessionManager;
        _protocol = [[ZKProtocol alloc] initWithSessionManager:_sessionManager];
#ifdef PROTOCOL_STUB
        if (hostType == HOST_TEST) {
            _protocol = [[ZKProtocolStub alloc] initWithSessionManager:_sessionManager];
        }
#endif
    }
    return self;
}

- (id<IMSUserService>)createUserService {
    return [[MSUserService alloc] initWithProtocol:_protocol];
}

- (id<IMSPayService>)createPayService {
    return [[MSPayService alloc] initWithProtocol:_protocol];
}

- (id<IMSOperatingService>)createOperatingService {
    return [[MSOperatingService alloc] initWithProtocol:_protocol];
}

- (id)getExtensionFactory {
    return self;
}

- (MSFinanceService *)createFinanceService {
    return [[MSFinanceService alloc] initWithProtocol:_protocol];
}

- (MSCurrentService *)createCurrentService {
    return [[MSCurrentService alloc] initWithProtocol:_protocol];
}

- (MJSInsuranceService *)createInsuranceService {
    InsuranceProtocol *protocol = [[InsuranceProtocol alloc] initWithSessionManager:_sessionManager];
    return [[MJSInsuranceService alloc] initWithProtocol:protocol];
}

@end
