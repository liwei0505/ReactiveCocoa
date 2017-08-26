//
//  PreferenceUtils.h
//  MJS
//
//  Created by lee on 16/2/16.
//  Copyright © 2016年 lw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferenceUtils : NSObject

+ (NSString *)loadUserPhone;
+ (void)saveUserPhone:(NSString *)phone;

@end
