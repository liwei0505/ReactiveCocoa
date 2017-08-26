//
//  MSQRCodeGenerator.h
//  showTime
//
//  Created by msj on 2017/3/17.
//  Copyright © 2017年 msj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MSQRCodeGenerator : NSObject
+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message;
+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message  size:(CGFloat)size;
+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message  logo:(UIImage *)logo;
+ (UIImage *)ms_creatQRCodeWithMessage:(NSString *)message  size:(CGFloat)size logo:(UIImage *)logo;
@end
