//
//  MSPolicyDetailViewController.h
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, MSPolicyDetailViewFromType) {
    MSPolicyDetailViewFromType_policyList,
    MSPolicyDetailViewFromType_insuranceDetail
};

@interface MSPolicyDetailViewController : MSBaseViewController
- (void)updateWithOrderId:(NSString *)orderId type:(MSPolicyDetailViewFromType)type;
@end
