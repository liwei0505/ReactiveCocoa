//
//  MSMyAttornSectionFooterView.m
//  Sword
//
//  Created by msj on 16/8/11.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyAttornSectionFooterView.h"
#import "UIView+FrameUtil.h"

@interface MSMyAttornSectionFooterView()
@property (strong, nonatomic) UILabel *lbTitle;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation MSMyAttornSectionFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.lbTitle = [[UILabel alloc] init];
        self.lbTitle.text = @"正在加载...";
        self.lbTitle.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.lbTitle];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.indicatorView startAnimating];
        [self addSubview:self.indicatorView];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = [self.lbTitle.text sizeWithAttributes:@{NSFontAttributeName : self.lbTitle.font}];
    self.lbTitle.frame = CGRectMake((self.width - size.width)/2.0, (self.height - size.height)/2.0,size.width , size.height);
    self.indicatorView.frame = CGRectMake(self.lbTitle.x - 20, (self.height - 15)/2.0, 15, 15);
}

@end
