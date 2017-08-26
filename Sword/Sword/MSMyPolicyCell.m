//
//  MSMyPolicyCell.m
//  Sword
//
//  Created by msj on 2017/8/9.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSMyPolicyCell.h"
#import "NSDate+Add.h"

@interface MSMyPolicyCell()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbStatus;
@property (strong, nonatomic) UILabel *lbReason;
@end

@implementation MSMyPolicyCell

+ (MSMyPolicyCell *)cellWithTableView:(UITableView *)tableView {
    MSMyPolicyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSMyPolicyCell"];
    if (!cell) {
        cell = [[MSMyPolicyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSMyPolicyCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.lbStatus = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbStatus];
    [self.lbStatus autoSetDimensionsToSize:CGSizeMake(72, 24)];
    [self.lbStatus autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:16];
    [self.lbStatus autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    self.lbStatus.font = [UIFont systemFontOfSize:12];
    self.lbStatus.textAlignment = NSTextAlignmentCenter;
    self.lbStatus.layer.cornerRadius = 12;
    self.lbStatus.layer.borderWidth = 1;
    
    self.lbTitle = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbTitle];
    [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.lbTitle autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.lbStatus withOffset:-16];
    [self.lbTitle autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbStatus];
    [self.lbTitle autoSetDimension:ALDimensionHeight toSize:20];
    self.lbTitle.font = [UIFont systemFontOfSize:14];
    self.lbTitle.textAlignment = NSTextAlignmentLeft;
    
    UIView *line = [UIView newAutoLayoutView];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [self.contentView addSubview:line];
    [line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [line autoSetDimension:ALDimensionHeight toSize:1];
    [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbStatus withOffset:16];
    
    self.lbReason = [UILabel newAutoLayoutView];
    [self.contentView addSubview:self.lbReason];
    [self.lbReason autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.lbReason autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbReason autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
    [self.lbReason autoSetDimension:ALDimensionHeight toSize:31];
    self.lbReason.font = [UIFont systemFontOfSize:12];
    self.lbReason.textAlignment = NSTextAlignmentLeft;
    self.lbReason.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    
    UIView *bgView = [UIView newAutoLayoutView];
    bgView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    [self.contentView addSubview:bgView];
    [bgView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [bgView autoSetDimension:ALDimensionHeight toSize:8];
}

- (void)setInsurancePolicy:(InsurancePolicy *)insurancePolicy {
    _insurancePolicy = insurancePolicy;
    
    self.lbTitle.text = insurancePolicy.insuranceTitle;
    
    switch (insurancePolicy.status) {
        case POLICY_STATUS_TOBE_PAID:
        {
            self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#F3091C"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#F3091C"];
            self.lbStatus.text = @"待支付";
            self.lbReason.text = @"请在2小时内完成付款，超时订单将自动关闭";
            break;
        }
        case POLICY_STATUS_TOBE_PUBLISH:
        {
            self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#999999"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.text = @"待出单";
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:insurancePolicy.insuredDate/1000];
            self.lbReason.text = [NSString stringWithFormat:@"投保时间 %02ld.%02ld.%02ld %02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)date.minute];
            break;
        }
        case POLICY_STATUS_TOBE_ACTIVE:
        {
            self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#999999"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.text = @"待生效";
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:insurancePolicy.startDate/1000];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:insurancePolicy.endDate/1000];
            self.lbReason.text = [NSString stringWithFormat:@"保障期限 %02ld.%02ld.%02ld-%02ld.%02ld.%02ld",(long)startDate.year,(long)startDate.month,(long)startDate.day,(long)endDate.year,(long)endDate.month,(long)endDate.day];
            break;
        }
        case POLICY_STATUS_ACTIVE:
        {
            self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#4945B7"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#4945B7"];
            self.lbStatus.text = @"保障中";
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:insurancePolicy.startDate/1000];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:insurancePolicy.endDate/1000];
            self.lbReason.text = [NSString stringWithFormat:@"保障期限 %02ld.%02ld.%02ld-%02ld.%02ld.%02ld",(long)startDate.year,(long)startDate.month,(long)startDate.day,(long)endDate.year,(long)endDate.month,(long)endDate.day];
            break;
        }
        case POLICY_STATUS_INACTIVE:
        {
            self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#CCCCCC"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
            self.lbStatus.text = @"已失效";
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:insurancePolicy.endDate/1000];
            self.lbReason.text = [NSString stringWithFormat:@"结束时间 %02ld.%02ld.%02ld %02ld:%02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)date.minute,(long)date.second];
            break;
        }
        case POLICY_STATUS_FAILED:
        {
            self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#CCCCCC"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
            self.lbStatus.text = @"投保失败";
            self.lbReason.text = insurancePolicy.failedReason;
            break;
        }
        case POLICY_STATUS_CANCELLED:
        {
            self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#CCCCCC"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#CCCCCC"];
            self.lbStatus.text = @"订单取消";
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:insurancePolicy.cancelledDate/1000];
            self.lbReason.text = [NSString stringWithFormat:@"取消时间 %02ld.%02ld.%02ld %02ld:%02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)date.minute,(long)date.second];
            break;
        }
        default:
            break;
    }
    
}
@end
