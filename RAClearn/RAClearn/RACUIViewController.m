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
 rac_liftSelector:withSignalsFromArray:Signals:处理当界面有多次请求时，需要都获取到数据时，才处理
 */

#import "RACUIViewController.h"
#import "RACData.h"

@interface RACUIViewController ()

@property (strong, nonatomic) UILabel *lbName;
@property (strong, nonatomic) RACData *data;
@property (strong, nonatomic) UIButton *btnTest;
@property (strong, nonatomic) UITextField *tf;

@end

@implementation RACUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ui];
//    [self systemMessageSend];
//    [self urlResult];
    [self textFieldDemo];
    [self rac_define];
}
    
- (void)ui {
    //rac手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan.rac_gestureSignal subscribeNext:^(id x) {
        
    }];
    [self.view addGestureRecognizer:pan];
    
    //监听文本框文字改变
    [self textFieldDemo];
    
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
    [[self.btnTest rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
    }];
    
}

- (void)tap {
    
}

- (void)textFieldDemo {
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(50, 50, 200, 50)];
    tf.placeholder = @"测试键盘rac";
    self.tf = tf;
    [self.view addSubview:tf];
    
//    [tf.rac_textSignal subscribeNext:^(id x) {
//        NSLog(@"文本框变化了。。。。。");
//    }];
    
    /*filter操作控制事件流
     * rac_textSignal ==> filter ==> subscribeNext
     * 起始事件 =》数据通过filter可以按照一定规则过滤 =》符合规则数据在block中打印
     * filter输出也是RACSignal
     */
    [[tf.rac_textSignal filter:^BOOL(id value) {
        NSString *text = value;
        return text.length > 3;
    }] subscribeNext:^(id x) {
        NSLog(@"filter---%@",x);
    }];
    //    RACSignal *tfSignal = [tf.rac_textSignal filter:^BOOL(id value) {
    //        NSString *text = value;
    //        return text.length > 3;
    //    }];
    //    [tfSignal subscribeNext:^(id x) {
    //        NSLog(@"%@",x);
    //    }];
    
    /*map操作
     * rac_textSignal ==> map ==> filter ==> subscribeNext
     * map后收到的都是NSNumber实例：可用map操作把接收的数据转换成想要的类型，只要他是对象
     * textlength基本类型作为事件的内容，需要封装： @()
     */
    [[[tf.rac_textSignal map:^id(NSString *text) {
        return @(text.length);
    }] filter:^BOOL(NSNumber *length) {
        return [length integerValue] > 3;
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - 常用宏
- (void)rac_define {
    //RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定
    // 只要文本框文字改变，就会修改label的文字
    RAC(self.lbName, text) = self.tf.rac_textSignal;
    
    //RACObserve(self, name):监听某个对象的某个属性,返回的是信号:见kvo
    
    //@weakify(Obj)和@strongify(Obj),一般两个都是配套使用,在主头文件(ReactiveCocoa.h)中并没有导入，需要自己手动导入，RACEXTScope.h才可以使用。但是每次导入都非常麻烦，只需要在主头文件自己导入就好了
    
    //RACTuplePack：把数据包装成RACTuple（元组类）
    RACTuple *tuple = RACTuplePack(@10,@20);
    // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
    // name = @"xmg" age = @20
    RACTupleUnpack(NSString *name, NSNumber *age) = tuple;
    
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
    [self rac_lifeSelector_forArray];
}

- (void)systemMessageSend {

    //kvo
    __weak typeof(self)weakSelf = self;
    [RACObserve(self, data.name) subscribeNext:^(id x) {
        NSLog(@"%@",weakSelf.data.name);
    }];
    [[self.data.name rac_valuesAndChangesForKeyPath:@"name" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

    // target-actinon
    self.btnTest.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSLog(@"rac_command点击按钮");
        return [RACSignal empty];
    }];
    
    // 事件监听
    [[self.btnTest rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
        NSLog(@"rac_control_event按钮被点击");
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
    //使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据
    [self rac_liftSelector:@selector(updateData1:data2:) withSignalsFromArray:@[request1,request2]];
     
}

- (void)updateData1:(id)data1 data2:(id)data2 {
    NSLog(@"更新%@--%@",data1,data2);
}

- (RACData *)data {

    if (!_data) {
        _data = [[RACData alloc] init];
    }
    return _data;
}
    
@end
