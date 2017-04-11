//
//  RACViewController.m
//  RAClearn
//
//  Created by lee on 17/2/17.
//  Copyright © 2017年 mjsfax. All rights reserved.
/*
 ReactiveCocoa结合了几种编程风格：
 函数式编程（Functional Programming）
 响应式编程（Reactive Programming）
 */

#import "RACUIViewController.h"
#import "RACData.h"

@interface RACUIViewController ()


@property (strong, nonatomic) UILabel *lbName;
@property (strong, nonatomic) RACData *data;
@property (strong, nonatomic) UIButton *btnTest;


@end

@implementation RACUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ui];
    [self systemMessageSend];
//    [self urlResult];

}
    
- (void)ui {
    
    UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:rec];
    
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(50, 50, 200, 50)];
    tf.placeholder = @"测试键盘rac";
    [self.view addSubview:tf];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 50, 20);
    label.textColor = [UIColor orangeColor];
    label.text = self.data.name;
    label.center = self.view.center;
    self.lbName = label;
    [self.view addSubview:self.lbName];
    
    self.btnTest = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnTest.frame = CGRectMake(0, 0, 50, 50);
    [self.btnTest setTitle:@"按钮" forState:UIControlStateNormal];
    self.btnTest.center = CGPointMake(self.lbName.center.x, self.lbName.center.y+50);
    [self.view addSubview:self.btnTest];
    
}

- (void)tap {
    
}


#pragma mark - 用户自定义信号(创建了一个下载指定网站内容的信号)

- (RACSignal *)urlResult {

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      
        NSError *error;
        NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.devtang.com"] encoding:NSUTF8StringEncoding error:&error];
        
        NSLog(@"download");
        if (!result) {
            [subscriber sendError:error];
        } else {
            [subscriber sendNext:result];
            [subscriber sendCompleted];
        }
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"clean up");
        }];
        
    }];

}



#pragma mark - 统一的消息传递机制
    
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)systemMessageSend {

    //kvo
    __weak typeof(self)weakSelf = self;
    [RACObserve(self, data.name) subscribeNext:^(id x) {
        NSLog(@"%@",weakSelf.data.name);
    }];

    // target-actinon
    self.btnTest.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSLog(@"点击按钮");
        return [RACSignal empty];
    }];
    
    //notification
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidChangeFrameNotification object:nil] subscribeNext:^(id x) {
       
        NSLog(@"键盘frame 改变");
    }];
    
    //delegate
    [[self rac_signalForSelector:@selector(touchesBegan:withEvent:)] subscribeNext:^(id x) {
        NSLog(@" touch 方法被调用");
        self.data.name = [NSString stringWithFormat:@"zhang %d",arc4random_uniform(100)];
    }];
    
    [[self rac_signalForSelector:@selector(tap)] subscribeNext:^(id x) {
       
        [weakSelf.view endEditing:YES];
        
    }];
    
}

- (RACData *)data {

    if (!_data) {
        _data = [[RACData alloc] init];
    }
    return _data;
}
    
@end
