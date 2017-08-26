//
//  MSInviteDetailView.m
//  Sword
//
//  Created by msj on 2017/3/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInviteDetailView.h"

@interface MSInviteDetailView ()
@property (strong, nonatomic) UILabel *lbInvitePersonCount;
@property (strong, nonatomic) UILabel *lbInviteAccount;
@end

@implementation MSInviteDetailView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 2.0;
        
        self.lbInviteAccount = [UILabel newAutoLayoutView];
        self.lbInviteAccount.text = @"--";
        self.lbInviteAccount.font = [UIFont systemFontOfSize:32];
        self.lbInviteAccount.textAlignment = NSTextAlignmentCenter;
        self.lbInviteAccount.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
        [self addSubview:self.lbInviteAccount];
        [self.lbInviteAccount autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbInviteAccount autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:26.5];
        [self.lbInviteAccount autoSetDimensionsToSize:CGSizeMake(width, 32)];
        
        self.lbInvitePersonCount = [UILabel newAutoLayoutView];
        self.lbInvitePersonCount.text = @"--";
        self.lbInvitePersonCount.font = [UIFont systemFontOfSize:32];
        self.lbInvitePersonCount.textAlignment = NSTextAlignmentCenter;
        self.lbInvitePersonCount.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
        [self addSubview:self.lbInvitePersonCount];
        [self.lbInvitePersonCount autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbInvitePersonCount autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbInviteAccount];
        [self.lbInvitePersonCount autoSetDimensionsToSize:CGSizeMake(width, 32)];
        
        
        UILabel *lbInviteAccountTips = [UILabel newAutoLayoutView];
        lbInviteAccountTips.font = [UIFont systemFontOfSize:12];
        lbInviteAccountTips.text = @"累计邀请奖励(元)";
        lbInviteAccountTips.textAlignment = NSTextAlignmentCenter;
        lbInviteAccountTips.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [self addSubview:lbInviteAccountTips];
        [lbInviteAccountTips autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [lbInviteAccountTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbInviteAccount withOffset:9.5];
        [lbInviteAccountTips autoSetDimensionsToSize:CGSizeMake(width, 12)];
        
        UILabel *lbInvitePersonCountTips = [UILabel newAutoLayoutView];
        lbInvitePersonCountTips.font = [UIFont systemFontOfSize:12];
        lbInvitePersonCountTips.text = @"成功邀请人数(人)";
        lbInvitePersonCountTips.textAlignment = NSTextAlignmentCenter;
        lbInvitePersonCountTips.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [self addSubview:lbInvitePersonCountTips];
        [lbInvitePersonCountTips autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [lbInvitePersonCountTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbInvitePersonCount withOffset:9.5];
        [lbInvitePersonCountTips autoSetDimensionsToSize:CGSizeMake(width, 12)];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self addSubview:line];
        [line autoSetDimension:ALDimensionWidth toSize:1];
        [line autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:25];
        [line autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:25];

    }
    return self;
}

- (void)setInviteInfo:(InviteInfo *)inviteInfo {
    _inviteInfo = inviteInfo;
    self.lbInvitePersonCount.text = [NSString stringWithFormat:@"%d",inviteInfo.inviteCount];
    self.lbInviteAccount.text = [NSString stringWithFormat:@"%.2f",inviteInfo.inviteReward];
}
@end
