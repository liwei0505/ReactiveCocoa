//
//  MSHttpProxy.m
//  Sword
//
//  Created by haorenjie on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSHttpProxy.h"
#import "MSNetworkMonitor.h"
#import "NSDictionary+JSON.h"
#import "NSString+Ext.h"
#import "AFHTTPSessionManager.h"
#import "MSHttpsConfigure.h"
#import "MSHttpsConfigure.h"
#import "MSLog.h"
#import "MSDeviceUtils.h"
#import "MSFormFile.h"

@interface MSHttpProxy()
{
    AFURLSessionManager *_urlSession;
}

@property (nonatomic, strong) AFHTTPSessionManager *httpSession;

@end

@implementation MSHttpProxy

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _httpSession = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _httpSession.securityPolicy = [MSHttpsConfigure defaultSecurityPolicy];
    }
    return self;
}

- (instancetype)initWithHost:(BOOL)distribution {

    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _httpSession = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        _httpSession.securityPolicy = [MSHttpsConfigure ms_setHttpsConfig:distribution];

//https 双向认证 服务器认证
         __weak typeof(self)weakSelf = self;
        [_httpSession setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
            
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *clientCredential = nil;
            if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                if([weakSelf.httpSession.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                    clientCredential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    if(clientCredential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                } else {
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
                
                NSString *certificateP12 = distribution ? @"trust_client" : @"test_client";
                
                // client authentication
                SecIdentityRef identity = NULL;
                SecTrustRef trust = NULL;
                NSString *p12 = [[NSBundle mainBundle] pathForResource:certificateP12 ofType:@"p12"];
                NSData *PKCS12Data = [NSData dataWithContentsOfFile:p12];
                if ([MSHttpsConfigure extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data]) {
                    SecCertificateRef certificate = NULL;
                    SecIdentityCopyCertificate(identity, &certificate);

                    const void*certs[] = {certificate};
                    CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs,1,NULL);
                    NSArray *array = (__bridge  NSArray*)certArray;
                    clientCredential = [NSURLCredential credentialWithIdentity:identity certificates:array persistence:NSURLCredentialPersistencePermanent];
                    disposition = NSURLSessionAuthChallengeUseCredential;
                    CFRelease(certArray);
                }
            } else {
                [MSLog error:@"challenge.protectionSpace.authenticationMethod unknown - %@!", challenge.protectionSpace.authenticationMethod];
            }
            *credential = clientCredential;
            return disposition;
            
        }];
    }
    return self;
    
}

- (void)get:(NSString *)url result:(result_block_t)block
{
    if (![[MSNetworkMonitor sharedInstance] isNetworkAvailable]) {
        block(ERR_NETWORK, nil);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self setHttpHeader:request method:@"GET"];

    [[_httpSession dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            block(ERR_SERVER, nil);
            return;
        }

        if (!responseObject) {
            block(ERR_UNKNOWN, nil);
            return;
        }

        NSDictionary *data = (NSDictionary *)responseObject;
        block(ERR_NONE, data);
    }] resume];
}

- (void)post:(NSString *)url params:(NSDictionary *)params result:(result_block_t)block
{
    if (![[MSNetworkMonitor sharedInstance] isNetworkAvailable]) {
        block(ERR_NETWORK, nil);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    [self setHttpHeader:request method:@"POST"];

    NSData *httpBody = [[params jsonToString] dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[httpBody length]] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:httpBody];
    
    [[_httpSession dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            block(ERR_SERVER, nil);
            return;
        }

        if (!responseObject) {
            block(ERR_UNKNOWN, nil);
            return;
        }

        NSDictionary *data = (NSDictionary *)responseObject;
        block(ERR_NONE, data);

    }] resume];
}

- (void)postString:(NSString *)url params:(NSDictionary *)params result:(result_block_t)block
{
    if (![[MSNetworkMonitor sharedInstance] isNetworkAvailable]) {
        block(ERR_NETWORK, nil);
        return;
    }

    [[_httpSession POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        // DO NOTHING.
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *data = (NSDictionary *)responseObject;
        block(ERR_NONE, data);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(ERR_SERVER, nil);
    }] resume];
}

- (void)submitForm:(NSString *)url items:(NSArray<MSFormInfo *> *)items result:(result_block_t)block {
    if (![[MSNetworkMonitor sharedInstance] isNetworkAvailable]) {
        block(ERR_NETWORK, nil);
        return;
    }

    [[_httpSession POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (MSFormInfo *formInfo in items) {
            if ([formInfo isKindOfClass:[MSFormFile class]]) {
                MSFormFile *formFile = (MSFormFile *)formInfo;
                [formData appendPartWithFileData:formFile.data name:formFile.name fileName:formFile.fileName mimeType:formFile.mime];
            } else {
                [formData appendPartWithFormData:formInfo.data name:formInfo.name];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
            // Do nothing.
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *data = (NSDictionary *)responseObject;
        block(ERR_NONE, data);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"HTTP request failed: %@", error);
        block(ERR_SERVER, nil);
    }] resume];
}

- (void)setHttpHeader:(NSMutableURLRequest *)request method:(NSString *)method {
    [request setHTTPMethod:method];
    NSString *userAgent = [NSString stringWithFormat:@"iPhone/%@;com.mjsfax.mjs/%@", [MSDeviceUtils systemVersion], [MSDeviceUtils appVersion]];
    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setTimeoutInterval:10.f];
}

@end
