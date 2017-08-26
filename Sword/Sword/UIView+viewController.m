//
//  UIView+viewController.m
//  showTime
//
//  Created by msj on 16/8/26.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "UIView+viewController.h"

@implementation UIView (viewController)
- (UIViewController *)ms_viewController
{
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}
@end
