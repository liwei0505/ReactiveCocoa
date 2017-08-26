//
//  MSBalanceViewController.h
//  Sword
//
//  Created by msj on 2017/6/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
typedef NS_ENUM(NSInteger, MSBalanceGetIntoType) {
    MSBalanceGetIntoType_accountPage,
    MSBalanceGetIntoType_deterInvestPage,
    MSBalanceGetIntoType_deterLoanPage,
    MSBalanceGetIntoType_deterCurrentPage
};

@interface MSBalanceViewController : MSBaseViewController
@property (assign, nonatomic) MSBalanceGetIntoType getIntoType;
@property (assign, nonatomic) double chargeMoney;
@end
