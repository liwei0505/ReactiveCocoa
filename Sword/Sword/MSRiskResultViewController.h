//
//  MSRiskResultViewController.h
//  Sword
//
//  Created by msj on 2016/12/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBaseViewController.h"
#import "RiskInfo.h"

@interface MSRiskResultViewController : MSBaseViewController
@property (strong, nonatomic) RiskResultInfo *resultInfo;
@end



@interface MSRiskContainView : UIView
@property (copy, nonatomic) NSString *content;
@end
