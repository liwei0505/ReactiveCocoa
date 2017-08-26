//
//  InsurancePolicy.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsurancePolicy : NSObject

// 订单编号
@property (copy, nonatomic) NSString *orderId;
// 保单编号
@property (copy, nonatomic) NSString *policyId;
// 保险编号
@property (copy, nonatomic) NSString *insuranceId;
// 保险标题
@property (copy, nonatomic) NSString *insuranceTitle;
// 承保单位
@property (copy, nonatomic) NSString *underwritingBusiness;
// 代销公司
@property (copy, nonatomic) NSString *consignmentCompany;
// 投保日期
@property (assign, nonatomic) NSTimeInterval insuredDate;
// 保单状态
@property (assign, nonatomic) NSUInteger status;
// 投保人姓名
@property (copy, nonatomic) NSString *insurerName;
// 被保人姓名
@property (copy, nonatomic) NSString *insurantName;
// 保费金额
@property (strong, nonatomic) NSDecimalNumber *premium;
// 电子保单链接
@property (copy, nonatomic) NSString *electronicPolicyUrl;
// 服务电话
@property (copy, nonatomic) NSString *serviceTel;
// 起保日期
@property (assign, nonatomic) NSTimeInterval startDate;
// 止保日期
@property (assign, nonatomic) NSTimeInterval endDate;
// 取消日期
@property (assign, nonatomic) NSTimeInterval cancelledDate;
// 投保失败原因
@property (copy, nonatomic) NSString *failedReason;

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj;

@end
