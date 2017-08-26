//
//  MSDrawLine.h
//  showTime
//
//  Created by msj on 2017/3/22.
//  Copyright © 2017年 msj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MSDrawLine : NSObject
+ (CALayer *)drawDotLineWidth:(CGFloat)lineWidth lineSpace:(CGFloat)lineSpace lineColor:(UIColor *)lineColor points:(NSArray<NSString *> *)points;
+ (CALayer *)drawSolidLineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor points:(NSArray<NSString *> *)points;
@end
