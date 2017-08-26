//
//  InsuranceDetail.h
//  Sword
//
//  Created by haorenjie on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceDetail : NSObject

// 保险信息
@property (strong, nonatomic) InsuranceInfo *baseInfo;
// 保险简介
@property (copy, nonatomic) NSString *introduction;
// 图片链接
@property (copy, nonatomic) NSString *bannerUrl;
// 产品列表
@property (strong, nonatomic) NSArray<InsuranceProduct *> *productList;
// 保障期限选项列表
@property (strong, nonatomic) NSArray<TermInfo *> *termOptions;
// 单次购买份数限制
@property (assign, nonatomic) NSUInteger copiesLimit;
// 被保人关系限制
@property (strong, nonatomic) NSArray<NSNumber *> *insurantLimit;
// 被保人最大年龄限制
@property (assign, nonatomic) NSUInteger maxAge;
// 被保人最小年龄限制
@property (assign, nonatomic) NSUInteger minAge;
// 被保人性别限制
@property (assign, nonatomic) NSUInteger genderLimit;
// 承保单位
@property (copy, nonatomic) NSString *underwritingBusiness;
// 代销公司
@property (copy, nonatomic) NSString *consignmentCompany;
// 生效日期（自定义日期生效时为空）
@property (assign, nonatomic) NSTimeInterval effectiveDate;
// 特别约定
@property (copy, nonatomic) NSString *specialAgreement;
// 服务电话
@property (copy, nonatomic) NSString *serviceTel;
// 协议列表
@property (strong, nonatomic) NSArray<ContractInfo *> *contractList;
// 是否需要输入投保邮箱
@property (assign, nonatomic) BOOL needMail;

+ (instancetype)parserFromJson:(NSDictionary *)jsonObj;

@end
