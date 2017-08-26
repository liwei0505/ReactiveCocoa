//
//  MSMyInfoModel.h
//  Sword
//
//  Created by lee on 2017/6/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSMyInfoModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL icon;
@property (copy, nonatomic) NSString *detail;
@property (assign, nonatomic) BOOL logout;
@property (copy, nonatomic) void(^selectedBlock)(void);
@end
