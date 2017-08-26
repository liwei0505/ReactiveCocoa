//
//  MSHttpsConfigure.h
//  Sword
//
//  Created by msj on 16/10/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "MSConsts.h"

@interface MSHttpsConfigure : NSObject

+ (AFSecurityPolicy *)ms_setHttpsConfig:(BOOL)distribution;
+ (AFSecurityPolicy *)defaultSecurityPolicy;
+ (BOOL)extractIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef*)outTrust fromPKCS12Data:(NSData *)inPKCS12Data;

@end
