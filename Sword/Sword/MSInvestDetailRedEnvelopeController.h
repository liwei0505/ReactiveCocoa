//
//  MSInvestDetailRedEnvelopeController.h
//  Sword
//
//  Created by msj on 2017/6/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
#import "RedEnvelope.h"

@interface MSInvestDetailRedEnvelopeController : MSBaseViewController
@property (strong, nonatomic) NSNumber *loanId;
@property (assign, nonatomic) double investAmount;
@property (copy, nonatomic) void (^blcok)(RedEnvelope *redEnvelope);
@end
