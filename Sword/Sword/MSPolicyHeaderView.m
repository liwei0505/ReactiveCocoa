//
//  MSPolicyHeaderView.m
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPolicyHeaderView.h"
#import "NSDate+Add.h"

@interface MSPolicyHeaderView ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbStatus;
@property (strong, nonatomic) UILabel *lbPolicyId;
@property (strong, nonatomic) UILabel *lbInsuredDate;
@property (strong, nonatomic) UILabel *lbUnderwritingBusiness;
@end

@implementation MSPolicyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.lbStatus = [UILabel newAutoLayoutView];
    [self addSubview:self.lbStatus];
    [self.lbStatus autoSetDimensionsToSize:CGSizeMake(72, 24)];
    [self.lbStatus autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    [self.lbStatus autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    self.lbStatus.font = [UIFont systemFontOfSize:12];
    self.lbStatus.textAlignment = NSTextAlignmentCenter;
    self.lbStatus.layer.cornerRadius = 12;
    self.lbStatus.layer.borderWidth = 1;
    
    self.lbTitle = [UILabel newAutoLayoutView];
    [self addSubview:self.lbTitle];
    [self.lbTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.lbTitle autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.lbStatus withOffset:-16];
    [self.lbTitle autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbStatus];
    [self.lbTitle autoSetDimension:ALDimensionHeight toSize:22];
    self.lbTitle.font = [UIFont boldSystemFontOfSize:16];
    self.lbTitle.textAlignment = NSTextAlignmentLeft;
    
    self.lbPolicyId = [UILabel newAutoLayoutView];
    [self addSubview:self.lbPolicyId];
    [self.lbPolicyId autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.lbPolicyId autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbPolicyId autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:8];
    [self.lbPolicyId autoSetDimension:ALDimensionHeight toSize:17];
    self.lbPolicyId.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbPolicyId.font = [UIFont systemFontOfSize:12];
    self.lbPolicyId.textAlignment = NSTextAlignmentLeft;
    
    self.lbInsuredDate = [UILabel newAutoLayoutView];
    [self addSubview:self.lbInsuredDate];
    [self.lbInsuredDate autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.lbInsuredDate autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbInsuredDate autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbPolicyId];
    [self.lbInsuredDate autoSetDimension:ALDimensionHeight toSize:17];
    self.lbInsuredDate.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbInsuredDate.font = [UIFont systemFontOfSize:12];
    self.lbInsuredDate.textAlignment = NSTextAlignmentLeft;
    
    self.lbUnderwritingBusiness = [UILabel newAutoLayoutView];
    [self addSubview:self.lbUnderwritingBusiness];
    [self.lbUnderwritingBusiness autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
    [self.lbUnderwritingBusiness autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
    [self.lbUnderwritingBusiness autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbInsuredDate];
    [self.lbUnderwritingBusiness autoSetDimension:ALDimensionHeight toSize:17];
    self.lbUnderwritingBusiness.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbUnderwritingBusiness.font = [UIFont systemFontOfSize:12];
    self.lbUnderwritingBusiness.textAlignment = NSTextAlignmentLeft;
}

- (void)setPolicy:(InsurancePolicy *)policy {
    _policy = policy;
    
    self.lbTitle.text = policy.insuranceTitle;

    switch (policy.status) {
        case POLICY_STATUS_TOBE_PAID:
        {
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#F3091C"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#F3091C"];
            self.lbStatus.text = @"待支付";
            break;
        }
        case POLICY_STATUS_TOBE_PUBLISH:
        {
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#999999"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.text = @"待出单";
            self.lbPolicyId.text = [NSString stringWithFormat:@"保单编号: %@",policy.policyId];
            break;
        }
        case POLICY_STATUS_TOBE_ACTIVE:
        {
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#999999"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.text = @"待生效";
            self.lbPolicyId.text = [NSString stringWithFormat:@"保单编号: %@",policy.policyId];
            break;
        }
        case POLICY_STATUS_ACTIVE:
        {
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#4945B7"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#4945B7"];
            self.lbStatus.text = @"保障中";
            self.lbPolicyId.text = [NSString stringWithFormat:@"保单编号: %@",policy.policyId];
            break;
        }
        case POLICY_STATUS_INACTIVE:
        {
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#999999"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.text = @"已失效";
            self.lbPolicyId.text = [NSString stringWithFormat:@"保单编号: %@",policy.policyId];
            break;
        }
        case POLICY_STATUS_FAILED:
        {
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#999999"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.text = @"投保失败";
            break;
        }
        case POLICY_STATUS_CANCELLED:
        {
            self.lbStatus.layer.borderColor = [UIColor ms_colorWithHexString:@"#999999"].CGColor;
            self.lbStatus.textColor = [UIColor ms_colorWithHexString:@"#999999"];
            self.lbStatus.text = @"订单取消";
            break;
        }
        default:
            break;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:policy.insuredDate/1000];
    self.lbInsuredDate.text = [NSString stringWithFormat:@"投保时间: %02ld.%02ld.%02ld %02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)(long)date.minute];
    self.lbUnderwritingBusiness.text = [NSString stringWithFormat:@"本产品由%@代销 | %@承保",policy.consignmentCompany, policy.underwritingBusiness];
    
}

@end
