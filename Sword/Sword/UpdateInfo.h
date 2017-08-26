//
//  UpdateInfo.h
//  Sword
//
//  Created by lee on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateInfo : NSObject

@property (copy, nonatomic) NSString *desc;
@property (assign, nonatomic) NSInteger flag; // 1:不需要更新 2:建议更新 3:强制更新
@property (copy, nonatomic) NSString *url;

@end
