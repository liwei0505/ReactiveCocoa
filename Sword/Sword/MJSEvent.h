//
//  MJSEvent.h
//  Sword
//
//  Created by haorenjie on 2017/3/24.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJSEvent : NSObject

@end

// 用户进入后台超过 300秒 事件
@interface MJSUserBackOvertimeEvent : MJSEvent
@end

@interface MJSMyInvestListChangedEvent : MJSEvent

@property (assign, nonatomic) NSInteger status;

@end

@interface MJSMyDebtListChangedEvent : MJSEvent

@property (assign, nonatomic) NSInteger status;

@end
