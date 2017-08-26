
//
//  MSMessageHeaderView.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSMessageHeaderView.h"
#include "UIView+FrameUtil.h"

@interface MSMessageHeaderView ()
@property (strong, nonatomic) UIButton *btnMessage;
@property (strong, nonatomic) UIButton *btnNotice;
@property (strong, nonatomic) UIView  *line;
@property (assign, nonatomic, readwrite) MESSAGE_TYPE type;
@end

@implementation MSMessageHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = (self.width - 0.5)/2.0;
        
        self.btnMessage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, self.height)];
        [self.btnMessage setTitle:@"我的消息" forState:UIControlStateNormal];
        self.btnMessage.backgroundColor = [UIColor whiteColor];
        [self.btnMessage setTitleColor:[UIColor ms_colorWithHexString:@"#F3091C"] forState:UIControlStateSelected];
        [self.btnMessage setTitleColor:[UIColor ms_colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        [self.btnMessage addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnMessage.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnMessage.tag = MESSAGE;
        [self addSubview:self.btnMessage];
        
        self.btnNotice = [[UIButton alloc] initWithFrame:CGRectMake(width + 0.5, 0, width, self.height)];
        [self.btnNotice setTitle:@"平台公告" forState:UIControlStateNormal];
        self.btnNotice.backgroundColor = [UIColor whiteColor];
        [self.btnNotice setTitleColor:[UIColor ms_colorWithHexString:@"#F3091C"] forState:UIControlStateSelected];
        [self.btnNotice setTitleColor:[UIColor ms_colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        [self.btnNotice addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnNotice.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnNotice.tag = NOTICE;
        [self addSubview:self.btnNotice];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake((self.width/2.0 - 72)/2.0, self.height - 2, 72, 2)];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        [self addSubview:self.line];
        
        self.type = MESSAGE;
    }
    return self;
}

- (void)tap:(UIButton *)btn {
    self.type = (MESSAGE_TYPE)btn.tag;
}

- (void)setType:(MESSAGE_TYPE)type {
    _type = type;
    if (self.block) {
        self.block(type);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (type == MESSAGE) {
            self.btnMessage.selected = YES;
            self.btnNotice.selected = NO;
            self.line.x = (self.width/2.0 - 72) / 2.0;
        } else {
            self.btnMessage.selected = NO;
            self.btnNotice.selected = YES;
            self.line.x = (self.width/2.0 - 72) / 2.0 + self.width/2.0;
        }
    }];
}
@end
