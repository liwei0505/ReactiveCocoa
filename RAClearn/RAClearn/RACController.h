//
//  RACSignalController.h
//  RAClearn
//
//  Created by lee on 17/4/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
/*demo:
    RAC中最核心的类RACSiganl
    RACSubject
    RACReplaySubject
    RACTuple，RACSequence
    RACCommand
    RACMulticastConnection
*/

/*
    RACScheduler:RAC中的队列，用GCD封装的
    RACUnit :表⽰stream不包含有意义的值,也就是看到这个，可以直接理解为nil
    RACEvent: 把数据包装成信号事件(signal event)。它主要通过RACSignal的-materialize来使用，然并卵
 
*/

#import <UIKit/UIKit.h>

@interface RACController : UIViewController

@end
