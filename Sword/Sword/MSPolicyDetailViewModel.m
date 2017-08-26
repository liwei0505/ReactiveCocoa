//
//  MSPolicyDetailViewModel.m
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPolicyDetailViewModel.h"
#import "MSPolicyDetailModel.h"
#import "NSDate+Add.h"
#import "NSString+Ext.h"

@interface MSPolicyDetailViewModel ()
@property (strong, nonatomic, readwrite) NSMutableArray *datas;
@end

@implementation MSPolicyDetailViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.datas = [NSMutableArray array];
    }
    return self;
}

- (void)setPolicy:(InsurancePolicy *)policy {
    
    _policy = policy;
    
    if (self.datas.count > 0) {
        [self.datas removeAllObjects];
    }

    switch (policy.status) {
        case POLICY_STATUS_TOBE_PAID:
        case POLICY_STATUS_TOBE_PUBLISH:
        case POLICY_STATUS_FAILED:
        case POLICY_STATUS_CANCELLED:
        {
            MSPolicyDetailModel *insurer = [MSPolicyDetailModel new];
            insurer.title = @"投保人";
            insurer.subTitle = policy.insurerName;
            insurer.isHideLine = NO;
            insurer.type = MSPolicyDetailModel_insurer;
            
            MSPolicyDetailModel *insurant = [MSPolicyDetailModel new];
            insurant.title = @"被保人";
            insurant.isHideLine = YES;
            insurant.subTitle = policy.insurantName;
            insurant.type = MSPolicyDetailModel_insurant;
            
            [self.datas addObject:@[insurer, insurant]];
            
            MSPolicyDetailModel *productDetail = [MSPolicyDetailModel new];
            productDetail.title = @"产品详情";
            productDetail.isHideLine = NO;
            productDetail.type = MSPolicyDetailModel_productDetail;
            
            MSPolicyDetailModel *serviceTel = [MSPolicyDetailModel new];
            serviceTel.title = @"服务电话";
            serviceTel.isHideLine = YES;
            serviceTel.subTitle = policy.serviceTel;
            serviceTel.type = MSPolicyDetailModel_serviceTel;
            
            [self.datas addObject:@[productDetail, serviceTel]];
            
            MSPolicyDetailModel *premium = [MSPolicyDetailModel new];
            premium.title = @"保费金额";
            premium.isHideLine = YES;
            premium.subTitle = [NSString stringWithFormat:@"%@元",[NSString convertMoneyFormate:policy.premium accuracyStyle:MSAccuracyStyle_Two]];
            premium.type = MSPolicyDetailModel_premium;
            
            [self.datas addObject:@[premium]];
            
            break;
        }
        case POLICY_STATUS_TOBE_ACTIVE:
        case POLICY_STATUS_ACTIVE:
        case POLICY_STATUS_INACTIVE:
        {
            MSPolicyDetailModel *insurer = [MSPolicyDetailModel new];
            insurer.title = @"投保人";
            insurer.isHideLine = NO;
            insurer.subTitle = policy.insurerName;
            insurer.type = MSPolicyDetailModel_insurer;
            
            MSPolicyDetailModel *insurant = [MSPolicyDetailModel new];
            insurant.title = @"被保人";
            insurant.isHideLine = NO;
            insurant.subTitle = policy.insurantName;
            insurant.type = MSPolicyDetailModel_insurant;
            
            MSPolicyDetailModel *starDate = [MSPolicyDetailModel new];
            starDate.title = @"保单生效日期";
            starDate.isHideLine = NO;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:policy.startDate/1000];
            starDate.subTitle = [NSString stringWithFormat:@"%02ld.%02ld.%02ld %02ld:%02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)(long)date.minute,(long)date.second];
            starDate.type = MSPolicyDetailModel_startDate;
            
            MSPolicyDetailModel *endDate = [MSPolicyDetailModel new];
            endDate.title = @"保单失效日期";
            endDate.isHideLine = YES;
            date = [NSDate dateWithTimeIntervalSince1970:policy.endDate/1000];
            endDate.subTitle = [NSString stringWithFormat:@"%02ld.%02ld.%02ld %02ld:%02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)(long)date.minute,(long)date.second];
            endDate.type = MSPolicyDetailModel_endDate;
            
            [self.datas addObject:@[insurer, insurant, starDate, endDate]];
            
            MSPolicyDetailModel *productDetail = [MSPolicyDetailModel new];
            productDetail.title = @"产品详情";
            productDetail.isHideLine = NO;
            productDetail.type = MSPolicyDetailModel_productDetail;
            
            MSPolicyDetailModel *electronicPolicy = [MSPolicyDetailModel new];
            electronicPolicy.title = @"电子保单";
            electronicPolicy.isHideLine = NO;
            electronicPolicy.type = MSPolicyDetailModel_electronicPolicy;
            
            MSPolicyDetailModel *serviceTel = [MSPolicyDetailModel new];
            serviceTel.title = @"服务电话";
            serviceTel.isHideLine = YES;
            serviceTel.subTitle = policy.serviceTel;
            serviceTel.type = MSPolicyDetailModel_serviceTel;
            
            [self.datas addObject:@[productDetail, electronicPolicy, serviceTel]];
            
            MSPolicyDetailModel *premium = [MSPolicyDetailModel new];
            premium.title = @"保费金额";
            premium.isHideLine = YES;
            premium.subTitle = [NSString stringWithFormat:@"%@元",[NSString convertMoneyFormate:policy.premium accuracyStyle:MSAccuracyStyle_Two]];
            premium.type = MSPolicyDetailModel_premium;
            
            [self.datas addObject:@[premium]];
            
            break;
        }
        default:
            break;
    }
}

@end
