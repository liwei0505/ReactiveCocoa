//
//  MSWebViewController.h
//  Sword
//
//  Created by haorenjie on 16/6/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
#import "MSAppDelegate.h"

@interface MSWebViewController : MSBaseViewController

@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *htmlContent;
@property (strong, nonatomic) NSNumber *loanId;
@property (assign, nonatomic) int pageId;

+ (MSWebViewController *)load;

/**
 *  支付
 *  @param url 支付UrlpayCompletion
 *  @param payCompletion 支付成功或失败  都会调用此 Block
 */
- (void)payUrl:(NSString *)url payCompletion:(void (^)(void))payCompletion;

@end
