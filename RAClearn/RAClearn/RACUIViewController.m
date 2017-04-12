//
//  RACViewController.m
//  RAClearn
//
//  Created by lee on 17/2/17.
//  Copyright © 2017年 mjsfax. All rights reserved.
/*
 rac_signalForSelector：用于替代代理
 rac_valuesAndChangesForKeyPath：用于监听某个对象的属性改变 kvo
 rac_signalForControlEvents：用于监听某个事件
 rac_addObserverForName:用于监听某个通知
 rac_textSignal:只要文本框发出改变就会发出这个信号
 
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
    [tf.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"文本框变化了。。。。。");
    }];
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

#pragma mark - 处理当界面有多次请求时，需要都获取到数据时，才能展示界面
- (void)rac_lifeSelector_forArray {

    //rac_liftSelector:withSignalsFromArray:Signals:当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法
}


- (RACData *)data {

    if (!_data) {
        _data = [[RACData alloc] init];
    }
    return _data;
}
    
@end
