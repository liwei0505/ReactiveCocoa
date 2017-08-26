//
//  CurrentRedeemConfig.h
//  Sword
//
//  Created by haorenjie on 2017/3/29.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentRedeemConfig : NSObject

@property (assign, nonatomic) long redeemApplyDate; // 赎回申请日期
@property (assign, nonatomic) long earningsReceiveDate; // 预计到账日期
@property (assign, nonatomic) NSInteger leftCanRedeemCount; // 今日可赎回次数
@property (strong, nonatomic) NSDecimalNumber *leftCanRedeemAmount; // 今日可赎回金额
@property (copy, nonatomic) NSString *redeemRulesURL; // 赎回规则链接

@end

@interface CurrentRedeemNotice : NSObject

@property (assign, nonatomic) long redeemApplyDate; // 赎回申请日期
@property (assign, nonatomic) long earningsToBeReceiveDate; // 预计到账日期

@end
