//
//  MSCheckInfoUtils.h
//  Sword
//
//  Created by lw on 16/5/8.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCheckInfoUtils : NSObject

+ (BOOL)realNameCheckout:(NSString *)string;
+ (BOOL)phoneNumCheckout:(NSString *)num;
+ (BOOL)passwordCheckout:(NSString *)string;
+ (BOOL)numberCheckout:(NSString *)string;
+ (BOOL)amountOfChargeAndCashCheckou:(NSString *)string;
+ (BOOL)spacingCheckout:(NSString *)string;
+ (BOOL)identityCardCheckout:(NSString *)string;
+ (BOOL)bankCardNumberCheckout:(NSString *)string;
+ (BOOL)tradePasswordCheckout:(NSString *)string;
+ (BOOL)checkCode:(NSString *)code;
+ (BOOL)emailCheckout:(NSString *)string;

@end
