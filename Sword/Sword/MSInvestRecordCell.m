//
//  MSInvestRecordCell.m
//  Sword
//
//  Created by haorenjie on 16/6/14.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInvestRecordCell.h"
#import "NSString+Ext.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "NSDate+Add.h"

@interface MSInvestRecordCell()

@property (strong, nonatomic) UILabel *lbName;
@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) UILabel *lbAmount;
@property (strong, nonatomic) UIView *line;

@end

@implementation MSInvestRecordCell

+ (MSInvestRecordCell *)cellWithTableView:(UITableView *)tableView
{
    MSInvestRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSInvestRecordCell"];
    if (!cell) {
        cell = [[MSInvestRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSInvestRecordCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lbName = [[UILabel alloc] init];
        self.lbName.font = [UIFont systemFontOfSize:12];
        self.lbName.textAlignment = NSTextAlignmentLeft;
        self.lbName.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self.contentView addSubview:self.lbName];
        
        self.lbTime = [[UILabel alloc] init];
        self.lbTime.font = [UIFont systemFontOfSize:12];
        self.lbTime.textAlignment = NSTextAlignmentCenter;
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [self.contentView addSubview:self.lbTime];
        
        self.lbAmount = [[UILabel alloc] init];
        self.lbAmount.font = [UIFont boldSystemFontOfSize:12];
        self.lbAmount.textAlignment = NSTextAlignmentRight;
        self.lbAmount.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [self.contentView addSubview:self.lbAmount];
        
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
        [self.contentView addSubview:self.line];
    }
    return self;
}

- (void)setRecordInfo:(InvestRecord *)recordInfo {
    _recordInfo = recordInfo;
    self.lbName.text = _recordInfo.investor;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [format dateFromString:_recordInfo.createDateTime];
    self.lbTime.text = [NSString stringWithFormat:@"%02ld-%02ld %02ld:%02ld:%02ld",(long)date.month,(long)date.day,(long)date.hour,(long)date.minute,(long)date.second];
    
    self.lbAmount.text = [NSString stringWithFormat:@"%@元",[NSString convertMoneyFormate:_recordInfo.amount.doubleValue]];
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = (self.width - 32) / 3.0;
    
    self.lbName.frame = CGRectMake(16, 16, width, 20);
    self.lbTime.frame = CGRectMake(16 + width, 16, width, 20);
    self.lbAmount.frame = CGRectMake(16 + width * 2, 16, width, 20);
    self.line.frame = CGRectMake(16, self.contentView.height = 0.5, self.contentView.width - 16, 0.5);
}
@end
