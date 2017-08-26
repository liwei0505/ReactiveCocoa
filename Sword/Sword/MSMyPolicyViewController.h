//
//  MSMyPolicyViewController.h
//  Sword
//
//  Created by msj on 2017/8/9.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"

typedef NS_ENUM(NSInteger, MSMyPolicyViewFromType) {
    MSMyPolicyViewFromType_account,
    MSMyPolicyViewFromType_insuranceDetail
};

@interface MSMyPolicyViewController : MSBaseViewController
@property (assign, nonatomic) MSMyPolicyViewFromType type;
@end
