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
#import "RACService.h"
#import "RACEXTScope.h" //@weakify @strongify

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) RACService *server;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loginTextField];
}

- (void)prepare {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self linkSignal];
}

- (void)map {
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
    // reduce
    RACSignal *loginSignal = [RACSignal combineLatest:@[userNameSignal, passwordSignal] reduce:^id(NSNumber *username, NSNumber *password){
        return @([username boolValue] && [password boolValue]);
    }];
    @weakify(self);
    [loginSignal subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        } else {
            [self.loginBtn setTitle:@"错误" forState:UIControlStateNormal];
        }
    }];

#warning map 与 flattenMap区别
/*
 * map 返回RACDynamicSignal 类型
 * flattenMap 正确返回转换类型
 * doNext 添加附加操作
 */
//    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
//        return [self loginSignal];
//    }] subscribeNext:^(id x) {
//        NSLog(@"login result %@",x); //返回RACDynamicSignal
//    }];
    
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        //block无返回值，添加附加逻辑，不改变事件本身
        self.loginBtn.enabled = NO;
        
    }] flattenMap:^RACStream *(id value) {
        return [self loginSignal];
    }] subscribeNext:^(id x) {
        @strongify(self);
        self.loginBtn.enabled = YES;
        NSLog(@"login result %@",x); //返回登录结果做登录处理
    }];
 
}

- (RACSignal *)loginSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[RACService alloc] init] login:^(BOOL status) {
            if (status) {
                [subscriber sendNext:@(status)];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[[NSError alloc] init]];
            }
        }];
        return nil;
    }];
}

//链接signal
/*
 * then方法会等待completed事件的发送，然后再订阅由then block返回的signal。
 * 这样就高效地把控制权从一个signal传递给下一个
 * then方法会跳过error事件
 */
- (void)linkSignal {
    @weakify(self);
//    [[[self loginSignal] then:^RACSignal *{
//        @strongify(self);
//        return self.username.rac_textSignal;
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    } error:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
    
    [[[[[self loginSignal] then:^RACSignal *{
        @strongify(self);
        return self.username.rac_textSignal;
    }] filter:^BOOL(id value) {
        @strongify(self);
        return [self isValid];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        
    }];
     
}

- (void)filterText {
    
}

- (BOOL)isValid {
    return YES;
}

@end
