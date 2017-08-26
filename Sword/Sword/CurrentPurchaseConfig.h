//
//  CurrentPurchaseConfig.h
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentPurchaseConfig : NSObject

@property (assign, nonatomic) long beginInterestDate; // 开始计息日期
@property (strong, nonatomic) NSDecimalNumber *canPurchaseLimit; // 可申购金额

@end
