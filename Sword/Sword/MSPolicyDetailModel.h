//
//  MSPolicyDetailModel.h
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSPolicyDetailModelType) {
    MSPolicyDetailModel_insurer,
    MSPolicyDetailModel_insurant,
    MSPolicyDetailModel_startDate,
    MSPolicyDetailModel_endDate,
    MSPolicyDetailModel_productDetail,
    MSPolicyDetailModel_electronicPolicy,
    MSPolicyDetailModel_serviceTel,
    MSPolicyDetailModel_premium
};

@interface MSPolicyDetailModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subTitle;
@property (assign, nonatomic) MSPolicyDetailModelType type;
@property (assign, nonatomic) BOOL isHideLine;
@end
