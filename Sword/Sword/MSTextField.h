//
//  MSPasswordTextField.h
//  Sword
//
//  Created by lee on 16/9/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTextField : UITextField

+ (instancetype)ms_createWithPlaceholder:(NSString *)holder;
//校验空格
- (BOOL)spacingCheckout;
//校验密码格式
- (BOOL)passwordFormateError;
//校验手机号格式
- (BOOL)phoneNumberFormateError;
//校验验证码位数
- (BOOL)verifyCodeFormateError;
//校验密码位数
- (BOOL)passwordLengthError;
//校验身份证号
- (BOOL)idCardNumberFormateError;
//校验银行卡号
- (BOOL)bankCardNumberFormateError;
//校验交易密码
- (BOOL)tradePasswordError;
//校验真实姓名
- (BOOL)realNameFormateError;

@end
