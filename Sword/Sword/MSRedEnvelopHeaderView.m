//
//  MSRedEnvelopHeaderView.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSRedEnvelopHeaderView.h"
#import "UIView+FrameUtil.h"

@interface MSRedEnvelopHeaderView ()
@property (strong, nonatomic) UIButton *btnAvailable;
@property (strong, nonatomic) UIButton *btnHistory;
@property (strong, nonatomic) UIView  *line;
@property (assign, nonatomic, readwrite) RedEnvelopeStatus status;
@end

@implementation MSRedEnvelopHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = (self.width - 0.5)/2.0;
        
        self.btnAvailable = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, self.height)];
        [self.btnAvailable setTitle:@"可用" forState:UIControlStateNormal];
        self.btnAvailable.backgroundColor = [UIColor whiteColor];
        [self.btnAvailable setTitleColor:[UIColor ms_colorWithHexString:@"#F3091C"] forState:UIControlStateSelected];
        [self.btnAvailable setTitleColor:[UIColor ms_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [self.btnAvailable addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnAvailable.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnAvailable.tag = STATUS_AVAILABLE;
        [self addSubview:self.btnAvailable];
        
        self.btnHistory = [[UIButton alloc] initWithFrame:CGRectMake(width + 0.5, 0, width, self.height)];
        [self.btnHistory setTitle:@"历史" forState:UIControlStateNormal];
        self.btnHistory.backgroundColor = [UIColor whiteColor];
        [self.btnHistory setTitleColor:[UIColor ms_colorWithHexString:@"#F3091C"] forState:UIControlStateSelected];
        [self.btnHistory setTitleColor:[UIColor ms_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [self.btnHistory addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        self.btnHistory.titleLabel.font = [UIFont systemFontOfSize:16];
        self.btnHistory.tag = STATUS_EXPIRED;
        [self addSubview:self.btnHistory];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake((self.width/2.0 - 72)/2.0, self.height - 2, 72, 2)];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        [self addSubview:self.line];
        
        self.status = STATUS_AVAILABLE;
        
    }
    return self;
}

- (void)tap:(UIButton *)btn {
    self.status = (RedEnvelopeStatus)btn.tag;
}

- (void)setStatus:(RedEnvelopeStatus)status {
    _status = status;
    if (self.block) {
        self.block(status);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (status == STATUS_AVAILABLE) {
            self.btnAvailable.selected = YES;
            self.btnHistory.selected = NO;
            self.line.x = (self.width/2.0 - 72) / 2.0;
        } else {
            self.btnAvailable.selected = NO;
            self.btnHistory.selected = YES;
            self.line.x = (self.width/2.0 - 72) / 2.0 + self.width/2.0;
        }
    }];
}

@end
