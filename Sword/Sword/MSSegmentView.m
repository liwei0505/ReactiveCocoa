//
//  MSSegmentView.m
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSSegmentView.h"
#include "UIView+FrameUtil.h"

@interface MSSegmentView ()
@property (strong, nonatomic) UIButton *btnInvest;
@property (strong, nonatomic) UIButton *btnSecure;
@property (strong, nonatomic) UIView  *line;
@end

@implementation MSSegmentView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = self.width / 2.0;
        
        self.btnInvest = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, self.height)];
        [self.btnInvest setTitle:@"理财" forState:UIControlStateNormal];
        self.btnInvest.backgroundColor = [UIColor clearColor];
        [self.btnInvest setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.btnInvest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnInvest addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnInvest.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnInvest.tag = Segment_Invest;
        [self addSubview:self.btnInvest];
        
        self.btnSecure = [[UIButton alloc] initWithFrame:CGRectMake(width, 0, width, self.height)];
        [self.btnSecure setTitle:@"保险" forState:UIControlStateNormal];
        self.btnSecure.backgroundColor = [UIColor clearColor];
        [self.btnSecure setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.btnSecure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnSecure addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnSecure.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnSecure.tag = Segment_Secure;
        [self addSubview:self.btnSecure];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake((self.width/2.0 - 40)/2.0, self.height - 4, 40, 2)];
        self.line.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.line];
        
        self.type = Segment_Invest;
    }
    return self;
}

- (void)tap:(UIButton *)btn {
    self.type = (SegmentType)btn.tag;
}

- (void)setType:(SegmentType)type {
    _type = type;
    if (self.block) {
        self.block(type);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (type == Segment_Invest) {
            self.btnInvest.selected = YES;
            self.btnSecure.selected = NO;
            self.line.x = (self.width/2.0 - 40) / 2.0;
        } else {
            self.btnInvest.selected = NO;
            self.btnSecure.selected = YES;
            self.line.x = (self.width/2.0 - 40) / 2.0 + self.width/2.0;
        }
    }];
}

@end
