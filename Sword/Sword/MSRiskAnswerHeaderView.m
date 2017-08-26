//
//  MSRiskAnswerHeaderView.m
//  Sword
//
//  Created by msj on 2016/12/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRiskAnswerHeaderView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "UIImageView+WebCache.h"

@interface MSRiskAnswerHeaderView ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) RiskInfo *riskInfo;

@end

@implementation MSRiskAnswerHeaderView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 90)/2.0, 25, 90, 90)];
        self.imageView.image = [UIImage imageNamed:@"risk_answer_placeholder"];
        [self addSubview:self.imageView];
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.imageView.frame)+25, self.width - 32, 48)];
        self.lbTitle.numberOfLines = 2;
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        self.lbTitle.font = [UIFont systemFontOfSize:18];
        [self addSubview:self.lbTitle];
    }
    return self;
}

- (CGFloat)updateRiskInfo:(RiskInfo *)riskInfo
{
    _riskInfo = riskInfo;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:riskInfo.icon] placeholderImage:[UIImage imageNamed:@"risk_answer_placeholder"] options:SDWebImageRetryFailed];
    self.lbTitle.text = riskInfo.title;
    return CGRectGetMaxY(self.lbTitle.frame) + 25;
}
@end
