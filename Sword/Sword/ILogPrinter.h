//
//  ILogPrinter.h
//  SocialO2ODemo
//
//  Created by haorenjie on 15/11/25.
//  Copyright © 2015年 haorenjie. All rights reserved.
//

#ifndef ILogPrinter_h
#define ILogPrinter_h

@protocol ILogPrinter <NSObject>

- (void)print:(NSString *)log;

@end

#endif /* ILogPrinter_h */
