//
//  MSRiskCollectionViewCell.h
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RiskInfo.h"


@interface MSRiskCollectionViewCell : UICollectionViewCell
- (void)update:(RiskInfo *)riskInfo index:(NSInteger)index riskInfoArr:(NSMutableArray *)riskInfoArr;
@property (copy, nonatomic) void (^selectedCallBlcok)(NSInteger index);
@property (copy, nonatomic) void (^compeleted)(void);
@end
