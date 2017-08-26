//
//  MSInvestDetailRedEnvelopeCell.h
//  Sword
//
//  Created by msj on 2017/6/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedEnvelope.h"

@interface MSInvestDetailRedEnvelopeCell : UITableViewCell
+ (MSInvestDetailRedEnvelopeCell *)cellWithTableView:(UITableView *)tableView;
@property (strong, nonatomic) RedEnvelope *redEnvelope;
@end
