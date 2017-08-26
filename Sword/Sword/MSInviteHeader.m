//
//  MSInviteHeader.m
//  Sword
//
//  Created by msj on 2017/7/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInviteHeader.h"
#import "MSInviteDetailView.h"
#import "UIView+FrameUtil.h"
#import "MSConfig.h"
#import "UIColor+StringColor.h"

@interface MSInviteHeader ()
@property (strong, nonatomic) UIImageView *banner;
@property (strong, nonatomic) MSInviteDetailView *inviteDetailView;
@end

@implementation MSInviteHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        
        self.banner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        self.banner.userInteractionEnabled = YES;
        [self addSubview:self.banner];
        
        @weakify(self);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(id x) {
            @strongify(self);
            if (self.block) {
                self.block(self.inviteInfo.bannerLink);
            }
        }];
        [self.banner addGestureRecognizer:tap];
        
        
        self.inviteDetailView = [[MSInviteDetailView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.banner.frame), self.width, 106)];
        [self addSubview:self.inviteDetailView];
        
        self.height = CGRectGetMaxY(self.inviteDetailView.frame) + 8;
    }
    return self;
}

- (void)setInviteInfo:(InviteInfo *)inviteInfo {
    _inviteInfo = inviteInfo;
    self.inviteDetailView.inviteInfo = inviteInfo;
    
    if (inviteInfo.inviteBanner && inviteInfo.inviteBanner.length > 0) {
        self.banner.height = self.width * 140.0 / 375.0;
        self.inviteDetailView.y = CGRectGetMaxY(self.banner.frame) + 8;
        [self.banner sd_setImageWithURL:[NSURL URLWithString:inviteInfo.inviteBanner] placeholderImage:[UIImage imageNamed:@"default_banner"] options:SDWebImageAllowInvalidSSLCertificates];
    } else {
        self.banner.height = 0;
        self.inviteDetailView.y = CGRectGetMaxY(self.banner.frame);
    }
    self.height = CGRectGetMaxY(self.inviteDetailView.frame) + 8;
    
}

@end
