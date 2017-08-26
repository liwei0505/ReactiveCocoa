//
//  MSRedEnvelopeCell.h
//  Sword
//
//  Created by lee on 16/6/24.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedEnvelope.h"

@interface MSRedEnvelopeCell : UITableViewCell
+ (MSRedEnvelopeCell *)cellWithTableView:(UITableView *)tableView;
- (void)updateWithRedEnvelope:(RedEnvelope *)redEnvelope status:(RedEnvelopeStatus)status;
@end
