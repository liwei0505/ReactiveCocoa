//
//  MSHelpFooterView.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSHelpFooterView.h"
#import "UIView+FrameUtil.h"

@interface MSHelpFooterView ()
@property (strong, nonatomic) UIButton *btnFeedBack;
@property (strong, nonatomic) UIButton *btnCall;
@property (strong, nonatomic) UIView  *line;
@end

@implementation MSHelpFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.btnFeedBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width/2.0, self.height)];
        [self.btnFeedBack setTitle:@"意见反馈" forState:UIControlStateNormal];
        [self.btnFeedBack setTitleColor:[UIColor ms_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [self.btnFeedBack setImage:[UIImage imageNamed:@"ms_help_feedback"] forState:UIControlStateNormal];
        [self.btnFeedBack addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnFeedBack.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        self.btnFeedBack.titleLabel.font = [UIFont systemFontOfSize:14];
        self.btnFeedBack.tag = HELP_FEEDBACK;
        [self addSubview:self.btnFeedBack];
        
        self.btnCall = [[UIButton alloc] initWithFrame:CGRectMake(self.width/2.0, 0, self.width/2.0, self.height)];
        [self.btnCall setTitle:@"客服电话" forState:UIControlStateNormal];
        [self.btnCall setTitleColor:[UIColor ms_colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [self.btnCall setImage:[UIImage imageNamed:@"ms_help_call"] forState:UIControlStateNormal];
        [self.btnCall addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnCall.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        self.btnCall.titleLabel.font = [UIFont systemFontOfSize:14];
        self.btnCall.tag = HELP_CALL;
        [self addSubview:self.btnCall];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake((self.width - 1)/2.0, (self.height - 24)/2.0, 1, 24)];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#D8D8D8"];
        [self addSubview:self.line];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
        topLine.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
        [self addSubview:topLine];
    }
    return self;
}

- (void)tap:(UIButton *)btn {
    
    if (self.block) {
        self.block((HELP_TYPE)btn.tag);
    }
}

@end
