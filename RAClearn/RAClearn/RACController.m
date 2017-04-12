//
//  RACSignalController.m
//  RAClearn
//
//  Created by lee on 17/4/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RACController.h"

@interface RACController ()

@end

@implementation RACController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self racreplaysubject_demo];
    
}

#pragma mark - RACSignal简单使用
- (void)racsignal_demo {

    //1.信号类(RACSiganl)，表示当数据改变时，信号内部会发出数据，本身不具备发送信号的能力，而是交给内部一个订阅者去发出
    //2.默认一个信号都是冷信号，就是值改变了也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发
    //3.订阅信号：调用信号RACSignal的subscribeNext
    
    // RACSignal底层实现：
    // 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
    // 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
    // 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
    // 2.1 subscribeNext内部会调用siganl的didSubscribe
    // 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
    // 3.1 sendNext底层其实就是执行subscriber的nextBlock
    
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block：每当有订阅者订阅信号，就会调用block
        
        // 2.发送信号
        [subscriber sendNext:@1];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            // block调用：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号 执行完Block后，当前信号就不在被订阅了
            NSLog(@"信号被销毁");
        }];
        
    }];
    
    // 3.订阅信号,才会激活信号
    [signal subscribeNext:^(id x) {
        // block调用：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    } error:^(NSError *error) {
        NSLog(@"error");
    } completed:^{
        NSLog(@"complete");
    }];
    
    //RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
    //RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。(使用场景:不想监听某个信号时，可以通过它主动取消订阅信号)
    //
}

#pragma mark - RACSubject
- (void)racsubject_demo {

    //RACSubject:信号提供者，自己可以充当信号，又能发送信号。使用场景:通常用来代替代理，有了它，就不必要定义代理了
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    
    [subject subscribeNext:^(id x) {
        // block调用：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"1"];
    
}

- (void)racreplaysubject_demo {

    //RACReplaySubject:重复提供信号类，RACSubject的子类，RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以
    //使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类
    //使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值
    
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACReplaySubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];
    
}

#pragma mark - 元组RACTuple，集合类RACSequence

- (void)ractuple_demo {

    //RACTuple:元组类,类似NSArray,用来包装值
    //RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典，使用场景：1.字典转模型
    
    // 遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
    NSDictionary *dict = @{@"name":@"xmg",@"age":@18};
    [dict.rac_sequence.signal subscribeNext:^(id x) {
       
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key, NSString *value) = x;
        // 相当于NSString *key = x[0];NSString *value = x[1];
        NSLog(@"%@ %@",key, value);
    }];
    
    
    // 字典转模型
/*
    // 1 OC写法
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in dictArr) {
        FlagItem *item = [FlagItem flagWithDict:dict];
        [items addObject:item];
    }
    
    // 2 RAC写法
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *flags = [NSMutableArray array];
    _flags = flags;
    // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会。
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        // 运用RAC遍历字典，x：字典
        
        FlagItem *item = [FlagItem flagWithDict:x];
        [flags addObject:item];
        
    }];
    NSLog(@"%@",  NSStringFromCGRect([UIScreen mainScreen].bounds));
    
    // 3 RAC高级写法:
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
    // map:映射的意思，目的：把原始值value映射成一个新值
    // array: 把集合转换成数组
    // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
    NSArray *flags = [[dictArr.rac_sequence map:^id(id value) {
        
        return [FlagItem flagWithDict:value];
        
    }] array];
*/
    
}

@end
