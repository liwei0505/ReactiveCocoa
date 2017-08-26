//
//  MSMyAttornTitleCell.m
//  Sword
//
//  Created by haorenjie on 16/6/29.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyAttornTitleCell.h"
#import "MSConsts.h"

@interface MSMyAttornTitleCell()

@property (weak, nonatomic) IBOutlet UILabel *lbLeft;
@property (weak, nonatomic) IBOutlet UILabel *lbRight;

@end

@implementation MSMyAttornTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setCategory:(NSInteger)category
{
    _category = category;
    if (_category == STATUS_HAS_BOUGHT) {
        self.lbLeft.text = NSLocalizedString(@"str_title_and_bought_time", nil);
        self.lbRight.text = NSLocalizedString(@"str_attron_price", nil);
    } else {
        self.lbLeft.text = NSLocalizedString(@"str_title_and_apply_time", nil);
        self.lbRight.text = NSLocalizedString(@"str_price_and_status", nil);
    }
}

@end
