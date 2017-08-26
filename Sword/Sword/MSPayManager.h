//
//  MSPayManager.h
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

typedef  void(^PaySuccess)(BOOL isSuccess, NSString *completePageUrl);
typedef  void(^RequestError)(NSError *error);

@interface MSPayManager : NSObject

/**
 *  发起支付请求 (APP支付)
 *
 *  @param orderId 需要支付的订单id
 *  @param payType 支付类型  支付宝 or 微信
 *  @param isNeedCheckSyncResult   是否需要校验  三方支付返回的结果
 *  @param success 支付宝返回的支付信息，与商户服务器没关系
 *  @param error   商户服务器返回的错误信息, 还没到达三方支付，与三方支付没关系
 */
+ (void)payWithOrderId:(NSString *)orderId payType:(PayType)payType isNeedCheckSyncResult:(BOOL)isNeedCheckSyncResult paySuccess:(PaySuccess)paySuccess requestError:(RequestError)requestError;


/**
 *  从h5链接中获取订单串并支付接口
 *
 *  @param payUrl         拦截的 url string
 *  @param paySuccess     支付完成回调(异步)
 *
 *  @return YES为成功获取订单信息并发起支付流程；NO为无法获取订单信息，输入url是普通url(同步)
 */
+ (BOOL)payInterceptorWithUrl:(NSString *)payUrl paySuccess:(PaySuccess)paySuccess;

/**
 *  支付宝支付成功处理
 *
 *  @param dic 支付宝支付返回的数据
 */
+ (void)payAliSuccessHandle:(NSDictionary *)dic;

/**
 *  微信支付成功处理
 *
 *  @param resp 微信支付返回的数据
 */
+ (void)payWxSuccessHandle:(PayResp *)resp;
@end
