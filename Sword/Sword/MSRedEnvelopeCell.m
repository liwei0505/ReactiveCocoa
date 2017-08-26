//
//  MSRedEnvelopeCell.m
//  Sword
//
//  Created by lee on 16/6/24.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRedEnvelopeCell.h"
#import "MSUtils.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "MSDrawLine.h"

@interface MSRedEnvelopeCell()
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *lbMoney;
@property (strong, nonatomic) UILabel *lbType;
@property (strong, nonatomic) UILabel *lbRule;
@property (strong, nonatomic) UILabel *lbName;
@property (strong, nonatomic) UILabel *lbTime;
@property (strong, nonatomic) UIImageView *bgCoupon;

@property (strong, nonatomic) RedEnvelope *redEnvelope;
@end

@implementation MSRedEnvelopeCell
+ (MSRedEnvelopeCell *)cellWithTableView:(UITableView *)tableView {
    MSRedEnvelopeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSRedEnvelopeCell"];
    if (!cell) {
        cell = [[MSRedEnvelopeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSRedEnvelopeCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        
        self.bgView = [[UIView alloc] init];
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.cornerRadius = 4;
        self.bgView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self.contentView addSubview:self.bgView];
        
        self.bgCoupon = [[UIImageView alloc] init];
        self.bgCoupon.image = [UIImage imageNamed:@"ms_coupon_bg"];
        [self.bgView addSubview:self.bgCoupon];
        
        self.lbMoney = [[UILabel alloc] init];
        self.lbMoney.textColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        self.lbMoney.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.lbMoney];
        
        
        self.lbType = [[UILabel alloc] init];
        self.lbType.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbType.textAlignment = NSTextAlignmentCenter;
        self.lbType.font = [UIFont systemFontOfSize:12];
        [self.bgView addSubview:self.lbType];
        
        self.lbRule = [[UILabel alloc] init];
        self.lbRule.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbRule.textAlignment = NSTextAlignmentRight;
        self.lbRule.font = [UIFont systemFontOfSize:12];
        [self.bgView addSubview:self.lbRule];
        
        self.lbName = [[UILabel alloc] init];
        self.lbName.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbName.textAlignment = NSTextAlignmentRight;
        self.lbName.font = [UIFont systemFontOfSize:12];
        [self.bgView addSubview:self.lbName];
        self.lbName.numberOfLines = 0;
        
        self.lbTime = [[UILabel alloc] init];
        self.lbTime.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbTime.textAlignment = NSTextAlignmentRight;
        self.lbTime.font = [UIFont systemFontOfSize:12];
        [self.bgView addSubview:self.lbTime];
  
    }
    return self;
}

- (void)updateWithRedEnvelope:(RedEnvelope *)redEnvelope status:(RedEnvelopeStatus)status {
    
    _redEnvelope = redEnvelope;
    
    if (status == STATUS_AVAILABLE) {
        self.lbMoney.textColor = [UIColor ms_colorWithHexString:@"#F3091C"];
    } else if (status == STATUS_EXPIRED) {
        self.lbMoney.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    }
    
    NSString *moneyStr = nil;
    double amount = redEnvelope.amount;
    if (redEnvelope.type == TYPE_PLUS_COUPONS) {
        moneyStr = [NSString stringWithFormat:@"%.1f%%",amount] ;
    }else {
        moneyStr = [NSString stringWithFormat:@"%.f元",amount] ;
    }
    NSMutableAttributedString *moneyAtt = [[NSMutableAttributedString alloc] initWithString:moneyStr];
    [moneyAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:32]} range:NSMakeRange(0, moneyStr.length)];
    [moneyAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} range:NSMakeRange(moneyStr.length - 1,1)];
    self.lbMoney.attributedText = moneyAtt;
    
    if (redEnvelope.type == TYPE_VOUCHERS) {
        self.lbType.text = @"代金劵";
    } else if (redEnvelope.type == TYPE_EXPERIENS_GOLD) {
        self.lbType.text = @"体验金";
    } else if (redEnvelope.type == TYPE_PLUS_COUPONS) {
        self.lbType.text = @"加息券";
    } else {
        self.lbType.text = @"";
    }
    
    self.lbRule.text = redEnvelope.usageRange;
    self.lbName.text = redEnvelope.name;
    NSString *end = redEnvelope.endDate;
    self.lbTime.text =  [NSString stringWithFormat:@"有效期至:%@",end];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgView.frame = CGRectMake(16, 10, self.width - 32, self.height - 10);
    self.bgCoupon.frame = self.bgView.bounds;
    
    self.lbMoney.frame = CGRectMake(0, 16, 97*scaleX, 50);
    self.lbType.frame = CGRectMake(0, CGRectGetMaxY(self.lbMoney.frame), 97*scaleX, 17);

    CGFloat distanceY = 0;
    CGSize size = [self.redEnvelope.name boundingRectWithSize:CGSizeMake(self.bgView.width - self.lbMoney.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size;
    distanceY = (self.bgView.height - 34 - size.height - 6) / 2.0;
    self.lbRule.frame = CGRectMake(CGRectGetMaxX(self.lbMoney.frame), distanceY, self.bgView.width - self.lbMoney.width - 16, 17);
    self.lbName.frame = CGRectMake(CGRectGetMaxX(self.lbMoney.frame), CGRectGetMaxY(self.lbRule.frame)+3, self.bgView.width - self.lbMoney.width - 16, size.height);
    self.lbTime.frame = CGRectMake(CGRectGetMaxX(self.lbMoney.frame), CGRectGetMaxY(self.lbName.frame)+3, self.bgView.width - self.lbMoney.width - 16, 17);
    
}
@end
