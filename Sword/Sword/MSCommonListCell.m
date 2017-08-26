//
//  MSCommonListCell.m
//  Sword
//
//  Created by haorenjie on 2017/1/3.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCommonListCell.h"
#import "MSTemporaryCache.h"

@interface MSCommonListCell()

@property (weak, nonatomic) IBOutlet UILabel *lbLogout;


@end

@implementation MSCommonListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatar.hidden = YES;
    self.detail.hidden = YES;
    self.lbLogout.hidden = YES;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, self.frame.size.height-1, self.frame.size.width, 1)];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"EBEBF2"];
    [self addSubview:line];
}

- (void)setModel:(MSMyInfoModel *)model {
    _model = model;
    self.text.text = model.title;
    if (model.icon) {
        self.avatar.hidden = NO;
        NSString *normal = [MSTemporaryCache getTemporaryUserIcon] ?: @"user_icon_normal_1";
        [self.avatar setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    } else {
        self.avatar.hidden = YES;
    }
    if (model.detail) {
        self.detail.hidden = NO;
        self.detail.text = model.detail;
    } else {
        self.detail.hidden = YES;
    }
    if (model.logout) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.lbLogout.hidden = NO;
    } else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.lbLogout.hidden = YES;
    }
}

@end
