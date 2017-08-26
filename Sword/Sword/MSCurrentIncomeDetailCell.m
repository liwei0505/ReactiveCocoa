//
//  MSCurrentIncomeDetailCell.m
//  Sword
//
//  Created by lee on 17/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentIncomeDetailCell.h"
#import "NSDate+Add.h"

@interface MSCurrentIncomeDetailCell()

@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) UILabel *lbMoney;

@end

@implementation MSCurrentIncomeDetailCell

+ (MSCurrentIncomeDetailCell *)cellWithTable:(UITableView *)tableView {

    NSString *reuseId = @"CurrentIncomeDetailCell";
    MSCurrentIncomeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSCurrentIncomeDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lbTime = [UILabel newAutoLayoutView];
        self.lbTime.font = [UIFont systemFontOfSize:13.f];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self.contentView addSubview:self.lbTime];
        [self.lbTime autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.lbTime autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        
        self.lbMoney = [UILabel newAutoLayoutView];
        self.lbMoney.font = [UIFont systemFontOfSize:13.f];
        self.lbMoney.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
    
        [self.contentView addSubview:self.lbMoney];
        [self.lbMoney autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.lbMoney autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#CBCADD"];
        [self.contentView addSubview:line];
        [line autoSetDimension:ALDimensionHeight toSize:0.5];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    }
    return self;
}

- (void)setEarnings:(CurrentEarnings *)earnings {

    _earnings = earnings;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:earnings.date];
    self.lbTime.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)date.year,(long)date.month,(long)date.day];
    
    double money = earnings.amount.doubleValue;
    NSString *moneyString = [NSString stringWithFormat:@"%.2f元",money];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:moneyString];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor ms_colorWithHexString:@"#2A2A2A"] range:NSMakeRange(moneyString.length-1, 1)];
    [self.lbMoney setAttributedText:attribute];
    
}

@end
