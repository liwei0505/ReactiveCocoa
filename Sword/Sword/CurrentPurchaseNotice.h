//
//  CurrentPurchaseNotice.h
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentPurchaseNotice : NSObject

@property (assign, nonatomic) long purchaseDate; // 活期申购日期
@property (assign, nonatomic) long beginInterestDate; // 开始计息日期
@property (assign, nonatomic) long earningsReceiveDate; // 收益到账日期

@end
