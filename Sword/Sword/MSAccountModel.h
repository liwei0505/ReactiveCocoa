//
//  MSAccountModel.h
//  Sword
//
//  Created by msj on 2017/5/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSAccountModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *iconStr;
@property (copy, nonatomic) NSString *detail;
@property (copy, nonatomic) void (^actionBlock)(void);
@end
