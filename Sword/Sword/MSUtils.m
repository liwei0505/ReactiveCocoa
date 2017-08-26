//
//  MSUtils.m
//  Sword
//
//  Created by haorenjie on 16/6/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSUtils.h"

UIColor *UIColorFromRGBValue(UInt32 rgbValue) {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0
                           alpha:1.0];
}

UIColor *UIColorFromRGBDecValue(UInt32 r, UInt32 g, UInt32 b) {
    return [UIColor colorWithRed:((float)r)/255.0f
                           green:((float)g)/255.0f
                            blue:((float)b)/255.0f
                           alpha:1.0];
}
