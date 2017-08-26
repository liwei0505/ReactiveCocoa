//
//  MSFundsFlowCell.m
//  Sword
//
//  Created by lee on 16/6/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSFundsFlowCell.h"
#import "UIView+FrameUtil.h"

@interface MSFundsFlowCell()
@property (strong, nonatomic)  UILabel *lbTitle;
@property (strong, nonatomic)  UILabel *lbMoney;
@property (strong, nonatomic)  UILabel *lbTime;
@property (strong, nonatomic)  UIView  *bottomLine;

@end

@implementation MSFundsFlowCell

+ (MSFundsFlowCell *)cellWithTableView:(UITableView *)tableView
{
    MSFundsFlowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSFundsFlowCell"];
    if (!cell) {
        cell = [[MSFundsFlowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSFundsFlowCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.lbTitle = [[UILabel alloc] init];
        self.lbTitle.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbTitle];
        
        self.lbTime = [[UILabel alloc] init];
        self.lbTime.font = [UIFont systemFontOfSize:10];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbTime.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.lbTime];
        
        self.lbMoney = [[UILabel alloc] init];
        self.lbMoney.font = [UIFont systemFontOfSize:14];
        self.lbMoney.textColor = [UIColor ms_colorWithHexString:@"#151515"];
        self.lbMoney.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.lbMoney];
        
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self.contentView addSubview:self.bottomLine];
        
    }
    return self;
}

- (void)setFundsFlow:(FundsFlow *)fundsFlow
{
    _fundsFlow = fundsFlow;
    self.lbTime.text =self.fundsFlow.tradeDate;
    if (self.fundsFlow.tradeAmount > 0) {
        self.lbMoney.text = [NSString stringWithFormat:@"+%.2f",self.fundsFlow.tradeAmount];
    }else{
        self.lbMoney.text = [NSString stringWithFormat:@"%.2f",self.fundsFlow.tradeAmount];
    }
    
    
    NSString *title;
    NSMutableAttributedString *attTitle;
    if (self.fundsFlow.type == TYPE_CHARGE || self.fundsFlow.type == TYPE_WITHDRAW) {
        
        title = self.fundsFlow.typeName;
        attTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#2A2A2A"] , NSFontAttributeName : [UIFont boldSystemFontOfSize:12]}];
        
    }else{
        
        NSMutableAttributedString *attTitle1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ",self.fundsFlow.typeName] attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#2A2A2A"] , NSFontAttributeName : [UIFont boldSystemFontOfSize:12]}];
        NSMutableAttributedString *attTitle2 = [[NSMutableAttributedString alloc] initWithString:self.fundsFlow.target attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#666666"] , NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        [attTitle1 appendAttributedString:attTitle2];
        attTitle = attTitle1;
    }
    self.lbTitle.attributedText = attTitle;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lbTitle.frame = CGRectMake(15, 16, self.width - 30 - 100, 16);
    self.lbTime.frame = CGRectMake(15, self.height - 12 - 15, self.width - 30, 12);
    self.lbMoney.frame = CGRectMake(15, 0, self.width - 30, self.height);
    self.bottomLine.frame = CGRectMake(15, self.height - 1, self.width - 15, 1);
}

@end
