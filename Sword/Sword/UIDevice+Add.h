//
//  UIDevice+Add.h
//  showTime
//
//  Created by msj on 16/10/31.
//  Copyright © 2016年 msj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Add)
/// The device's machine model.  e.g. "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nonatomic, readonly) NSString *machineModel;

/// The device's machine model name. e.g. "iPhone 5s" "iPad mini 2"
/// @see http://theiphonewiki.com/wiki/Models
@property (nonatomic, readonly) NSString *machineModelName;
@end
