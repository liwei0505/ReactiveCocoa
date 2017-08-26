//
//  MSHttpsConfigure.m
//  Sword
//
//  Created by msj on 16/10/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSHttpsConfigure.h"
#import "MSLog.h"

@implementation MSHttpsConfigure

+ (AFSecurityPolicy *)ms_setHttpsConfig: (BOOL)distribution {
   
    NSString *certificate = distribution ? @"trust_server" : @"test_server";
    SecIdentityRef identity = NULL;
    SecTrustRef trust = NULL;
    //导入证书
    NSString *path = [[NSBundle mainBundle] pathForResource:certificate ofType:@"p12"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    [self extractIdentity:&identity andTrust:&trust fromPKCS12Data:data];
    
    NSData *certificateData = [self getCertificateData:&identity];
    
    NSArray *certificateArray = [NSArray arrayWithObjects:certificateData,nil];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //是否允许无效证书（也就是自建的证书），默认为NO，如果是需要验证自建证书，需要设置为YES
    //如是自建证书的时候，可以设置为YES，增强安全性；假如是信任的CA所签发的证书没有必要整个证书链一一比对
    securityPolicy.allowInvalidCertificates = YES;
    //是否需要验证域名，默认为YES,假如证书的域名与你请求的域名不一致，需把该项设置为NO
    securityPolicy.validatesDomainName = NO;
    //是否验证整个证书链，默认为YES
    [securityPolicy setPinnedCertificates:[NSSet setWithArray:certificateArray]];
    
    return securityPolicy;
    
}

+ (AFSecurityPolicy *)defaultSecurityPolicy
{
    AFSecurityPolicy *defaultPolicy = [AFSecurityPolicy defaultPolicy];
    defaultPolicy.validatesDomainName = NO;
    return defaultPolicy;
}

+ (NSData *)getCertificateData:(SecIdentityRef *)identity {
    
    SecCertificateRef myReturnedCertificate = NULL;
    OSStatus status = SecIdentityCopyCertificate (*identity,&myReturnedCertificate);
    
    if (!status) {
        CFDataRef certSummary = SecCertificateCopyData(myReturnedCertificate);
        NSData *certSummaryData = (__bridge NSData *)certSummary;
        CFRelease(certSummary);
        return certSummaryData;
        
    } else {
        [MSLog error:@"https certificate get data failed with error code %d",(int)status];
        return nil;
    }

}

//校验证书
+ (BOOL)extractIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef*)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    
    // 证书密钥
    CFStringRef password = CFSTR("mjsfax1017");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL,keys,values,1,NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);//分配内存默认nill；；拷贝数据的个数；A pointer to a CFArrayCallBacks
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,optionsDictionary,&items);
    CFRelease(optionsDictionary);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
        
    } else {
        
        [MSLog error:@"https certificate decipher failed with error code %d",(int)securityError];
        return NO;
    }
    return YES;
}


@end
