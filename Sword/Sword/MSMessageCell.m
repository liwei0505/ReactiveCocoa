//
//  MSMessageCell.m
//  Sword
//
//  Created by lee on 16/7/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMessageCell.h"
#import "MSUtils.h"

@interface MSMessageCell()

@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UIImageView *imgIcon;

@end

@implementation MSMessageCell

+ (MSMessageCell *)cellWithTableView:(UITableView *)tableView {
    
    NSString *reuseId = @"message";
    MSMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
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
        
        self.imgIcon = [UIImageView newAutoLayoutView];
        [self.contentView addSubview:self.imgIcon];
        [self.imgIcon autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.imgIcon autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#F6F6F6"];
        [self addSubview:line];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    }
    return self;
}

- (void)setMessage:(MessageInfo *)message {

    if (_message != message) {
        _message = message;
        self.lbTime.text = message.sendDate;
        self.lbTitle.text = message.type;
    }
    
    if (message.status) {
        
        self.imgIcon.image = [UIImage imageNamed:@"massage_sel"];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#D2D2D2"];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#D2D2D2"];
    } else {
        
        self.imgIcon.image = [UIImage imageNamed:@"massage_nor"];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#D2D2D2"];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    }
}

@end
