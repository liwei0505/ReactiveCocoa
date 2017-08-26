//
//  MSInsurancePolicyDetailController.h
//  Sword
//
//  Created by lee on 2017/8/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
#import "MSInsuranceTypeView.h"

@interface MSInsurancePolicyDetailController : MSBaseViewController
@property (strong, nonatomic) NSArray<InsuranceProduct *> *dataArray;
@property (assign, nonatomic) InsuranceTypeSelected type;
@end
