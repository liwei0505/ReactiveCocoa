//
//  MSNavigationView.m
//  circle
//
//  Created by msj on 2017/6/7.
//  Copyright © 2017年 msj. All rights reserved.
//

#import "MSNavigationView.h"
#import "UIView+FrameUtil.h"

@interface MSNavigationView ()
@property (strong, nonatomic) UIButton *btnMine;
@property (strong, nonatomic) UIButton *btnMessage;
@property (strong, nonatomic) UILabel *lbUnread;
@property (strong, nonatomic) UIImageView *bgImageView;

@end

@implementation MSNavigationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.bgImageView.image = [UIImage imageNamed:@"ms_bg_image"];
        [self addSubview:self.bgImageView];
        
        self.btnMine = [[UIButton alloc] initWithFrame:CGRectMake(20, 27, 24, 24)];
        self.btnMine.tag = NavigationType_Mine;
        [self.btnMine setImage:[UIImage imageNamed:@"ms_user_icon_normal"] forState:UIControlStateNormal];
        [self.btnMine setImage:[UIImage imageNamed:@"ms_user_icon_highlight"] forState:UIControlStateHighlighted];
        [self addSubview:self.btnMine];
        [self.btnMine addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.btnMessage = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 27, 24, 24)];
        [self.btnMessage setImage:[UIImage imageNamed:@"ms_message_icon_normal"] forState:UIControlStateNormal];
        [self.btnMessage setImage:[UIImage imageNamed:@"ms_message_icon_highlight"] forState:UIControlStateHighlighted];
        self.btnMessage.tag = NavigationType_Message;
        [self addSubview:self.btnMessage];
        [self.btnMessage addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.lbUnread = [[UILabel alloc] init];
        self.lbUnread.font = [UIFont systemFontOfSize:11];
        self.lbUnread.backgroundColor = [UIColor redColor];
        self.lbUnread.textColor = [UIColor whiteColor];
        self.lbUnread.layer.masksToBounds = YES;
        self.lbUnread.textAlignment = NSTextAlignmentCenter;
        [self.btnMessage addSubview:self.lbUnread];
        self.lbUnread.hidden = YES;
        
        self.backgroundColorAlpha = 0;
    }
    return self;
}

- (void)setBackgroundColorAlpha:(CGFloat)backgroundColorAlpha {
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:backgroundColorAlpha];
    self.bgImageView.alpha = backgroundColorAlpha;
}

- (void)setUnReadCount:(NSInteger)unReadCount {
    _unReadCount = unReadCount;
    if (unReadCount == 0) {
        self.lbUnread.hidden = YES;
        return;
    }
    self.lbUnread.hidden = NO;
    NSString *count = [NSString stringWithFormat:@"%ld",(long)unReadCount];
    CGSize size = [count sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11]}];
    
    if (unReadCount >= 100) {
        self.lbUnread.frame = CGRectMake(0, 0, 28, size.height);
        self.lbUnread.text = @"99+";
        self.lbUnread.layer.cornerRadius = size.height/2.0;
    }else {
        if (unReadCount < 10) {
            self.lbUnread.frame = CGRectMake(0, 0, 15, 15);
            self.lbUnread.layer.cornerRadius = 15/2.0;
        }else {
            self.lbUnread.frame = CGRectMake(0, 0, 25, size.height);
            self.lbUnread.layer.cornerRadius = size.height/2.0;
        }
        self.lbUnread.text = count;
    }
    self.lbUnread.centerX = self.btnMessage.width;
    self.lbUnread.centerY = 0;
}

- (void)tapAction:(UIButton *)btn{
    if (self.actionBlock) {
        self.actionBlock((NavigationType)btn.tag);
    }
}

@end
