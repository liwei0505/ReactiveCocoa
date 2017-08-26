//
//  MSProjectInstructionCell.m
//  Sword
//
//  Created by haorenjie on 16/6/13.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSProjectInstructionCell.h"
#import "MSLog.h"
#import "MSConsts.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"

@implementation MSProjectInstructionModel
- (void)setType:(ProjectInstructionType)type
{
    _type = type;
    if (_type == INSTRUCTION_TYPE_RISK_WARNING) {
        _title = @"风险揭示";
    } else if (_type == INSTRUCTION_TYPE_DISCLAIMER) {
        _title = @"免责声明";
    } else if (_type == INSTRUCTION_TYPE_TRADING_MANUAL) {
        _title = @"产品说明";
    } else if (_type == INSTRUCTION_TYPE_INVESTMENT_RECORD) {
        _title = @"投资记录";
    }
}
@end

@interface MSProjectInstructionCell()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UIView *line;
@property (strong, nonatomic) UIImageView *arrow;
@end

@implementation MSProjectInstructionCell

+ (MSProjectInstructionCell *)cellWithTableView:(UITableView *)tableView
{
    MSProjectInstructionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSProjectInstructionCell"];
    if (!cell) {
        cell = [[MSProjectInstructionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSProjectInstructionCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lbTitle = [[UILabel alloc] init];
        self.lbTitle.font = [UIFont boldSystemFontOfSize:14];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbTitle];
        
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
        [self.contentView addSubview:self.line];
        
        self.arrow = [[UIImageView alloc] init];
        self.arrow.image = [UIImage imageNamed:@"right_arrow"];
        [self.contentView addSubview:self.arrow];
    }
    return self;
}

- (void)setModel:(MSProjectInstructionModel *)model {
    _model = model;
    self.lbTitle.text = model.title;
    self.line.hidden = (model.type == INSTRUCTION_TYPE_INVESTMENT_RECORD);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.lbTitle.frame = CGRectMake(16, 0, 150, self.contentView.height);
    self.line.frame = CGRectMake(16, self.contentView.height - 0.5, self.contentView.width - 16, 0.5);
    self.arrow.frame = CGRectMake(self.contentView.width - 24, (self.contentView.height - 12)/2.0, 12, 12);
    
}
@end
