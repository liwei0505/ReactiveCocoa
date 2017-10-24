//
//  LoginController.m
//  RAClearn
//
//  Created by lee on 17/4/21.
//  Copyright © 2017年 mjsfax. All rights reserved.
/*
    bind
 
 */

#import "LoginController.h"

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self prepare];
    [self loginTextField];
}

- (void)prepare {
    [[self.username.rac_textSignal map:^id(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

//监听文本框内容拼接信息
- (void)after {
    // 返回结果后拼接
    [self.username.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"username");
    }];
    [self.password.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"password");
    }];
}

- (void)loginTextField {

    RACSignal *userNameSignal = [self.username.rac_textSignal map:^id(NSString *text) {
        return @(text.length);
    }];
    
    RACSignal *passwordSignal = [self.password.rac_textSignal map:^id(NSString *text) {
        return @(text.length);
    }];
    
    // 通过信道返回的值，设置文本框的文字色
    RAC(self.username, backgroundColor) = [userNameSignal map:^id(id value) {
        return [value boolValue] ? [UIColor clearColor] : [UIColor redColor];
    }];
    RAC(self.password, backgroundColor) = [passwordSignal map:^id(id value) {
        return [value boolValue] ? [UIColor clearColor] : [UIColor redColor];
    }];
    
    // 创建登录按扭的信号，把用户名与密码合成一个信道
    RACSignal *loginSignal = [RACSignal combineLatest:@[userNameSignal, passwordSignal] reduce:^id(NSNumber *username, NSNumber *password){
        return @([username boolValue] && [password boolValue]);
    }];
    
    [loginSignal subscribeNext:^(NSNumber *x) {
        if ([x boolValue]) {
            [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        } else {
            [self.loginBtn setTitle:@"错误" forState:UIControlStateNormal];
        }
    }];
    
    
}

@end
