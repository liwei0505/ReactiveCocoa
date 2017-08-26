//
//  MSInsuranceDetailController.h
//  Sword
//
//  Created by lee on 2017/8/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, MSInsuranceDetailFromType) {
    MSInsuranceDetailFromType_home,
    MSInsuranceDetailFromType_invest,
    MSInsuranceDetailFromType_policyDetail
};

@interface MSInsuranceDetailController : MSBaseViewController
@property (copy, nonatomic) NSString *insuranceId;
@property (assign, nonatomic) MSInsuranceDetailFromType type;
@end
