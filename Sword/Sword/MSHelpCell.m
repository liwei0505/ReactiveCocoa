//
//  MSHelpCell.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSHelpCell.h"

@interface MSHelpCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@end

@implementation MSHelpCell
+ (MSHelpCell *)cellWithTableView:(UITableView *)tableView{
    
    MSHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSHelpCell"];
    if (!cell) {
        cell = [[MSHelpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSHelpCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"666666"];
        self.lbTitle.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.lbTitle autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"F6F6F6"];
        [self addSubview:line];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    }
    return self;
}

- (void)setInfo:(NoticeInfo *)info {
    _info = info;
    self.lbTitle.text = info.title;
}
@end
