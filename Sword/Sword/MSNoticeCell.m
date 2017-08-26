//
//  MSNoticeCell.m
//  Sword
//
//  Created by lee on 16/6/30.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSNoticeCell.h"

@interface MSNoticeCell()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbTime;
@end

@implementation MSNoticeCell

+ (MSNoticeCell *)cellWithTableView:(UITableView *)tableView {
    
    MSNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSNoticeCell"];
    if (!cell) {
        cell = [[MSNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSNoticeCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.font = [UIFont systemFontOfSize:14];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
        [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        
        self.lbTime = [UILabel newAutoLayoutView];
        self.lbTime.font = [UIFont systemFontOfSize:12];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#D2D2D2"];
        [self.contentView addSubview:self.lbTime];
        [self.lbTime autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:10];
        [self.lbTime autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.lbTitle];
        
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"F6F6F6"];
        [self addSubview:line];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    }
    return self;
}

- (void)setInfo:(NoticeInfo *)info {
    _info = info;
    self.lbTime.text = info.datetime;
    self.lbTitle.text = info.title;
}

@end
