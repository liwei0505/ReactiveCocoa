//
//  MSUrlManager.m
//  mobip2p
//
//  Created by lee on 16/5/23.
//  Copyright © 2016年 zkbc. All rights reserved.
//

#import "MSUrlManager.h"
#import "MSLog.h"

static HOST_TYPE sHostType;

@implementation MSUrlManager

+ (void)setHost:(HOST_TYPE)hostType
{
    sHostType = hostType;
    [MSLog info:@"Host type: %d", sHostType];
}

+ (NSString *)getBaseUrl {
    switch (sHostType) {
        case HOST_ZK:
            return @"http://10.0.110.67:6500/";
        case HOST_TEST:
            return @"http://101.200.156.252:9081/";//功能测试
        case HOST_PERFORMANCE:
            return @"http://mjstest.minshengjf.com:6101/";
        case HOST_PREREALSE:
            return @"https://mjsytc.minshengjf.com:6108/";//准生产
        case HOST_PRODUCT:
            return @"https://www.mjsfax.com:6108/";
        default:
            return @"https://www.mjsfax.com:6108/";
    }
}

+ (HOST_TYPE)getHost {
    return sHostType;
}

+ (NSString *)getUpLoadUrl {

    return [NSString stringWithFormat:@"%@%@", [MSUrlManager getBaseUrl], @"fileupload/png/"];
}

+ (NSString *)getWebSiteUrl:(NSString *)name {

    return  [NSString stringWithFormat:@"%@%@%@.html", @"https://www.mjsfax.com/h5/", @"static/agreement/", name];
}

//注册：服务协议
+ (NSString *)getRegistUseTerms {

    return [self getWebSiteUrl:@"sytk"];
}
//注册：隐私条款
+ (NSString *)getRegistPrivacyTerms {

    return [self getWebSiteUrl:@"ystk"];
}

+ (NSString *)getFHOLPayUrl {
    if (sHostType == HOST_PRODUCT) {
        return @"https://h5pay.mjsfax.com/pay/pay/orderInfo.do";
    } else {
        return @"http://mjsjctesth5pay.minshengjf.com/pay/pay/orderInfo.do";
    }
}

+ (NSString *)getImageUrlPrefix {
    if (sHostType == HOST_PRODUCT) {
        return @"http://10.0.110.30";
    } else {
        return @"http://10.0.110.30";
    }
}

@end
