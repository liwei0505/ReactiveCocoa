//
//  UINavigationController+removeAtIndex.m
//  showTime
//
//  Created by msj on 2017/3/21.
//  Copyright © 2017年 msj. All rights reserved.
//

#import "UINavigationController+removeAtIndex.h"

@implementation UINavigationController (removeAtIndex)
- (void)removeViewcontrollerAtIndex:(NSInteger)index {
    
    if (index < 0 || index > self.viewControllers.count - 1) {
        NSLog(@"%s===下标越界",__func__);
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.viewControllers];
    [arr removeObjectAtIndex:index];
    self.viewControllers = [NSArray arrayWithArray:arr];
    
}
@end
