//
//  HotelTitleCell.m
//  RAClearn
//
//  Created by lw on 2018/4/17.
//  Copyright © 2018年 mjsfax. All rights reserved.
//

#import "HotelTitleCell.h"
@interface HotelTitleCell()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *textField;
@end

@implementation HotelTitleCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        float height = 60;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        self.titleLabel.text = @"title";
        [self addSubview:self.titleLabel];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, height+1, frame.size.width, height)];
        [self addSubview:self.textField];
        
    }
    return self;
}

//数据绑定  (在view中)
- (void)bindViewModel:(HotelTitleViewModel *)viewModel {
    //单向绑定
    RAC(self.titleLabel, text) = RACObserve(viewModel, title);
    
    //双向绑定
    RACChannelTerminal *terminal1 = self.textField.rac_newTextChannel;
    RACChannelTerminal *terminal2 = RACChannelTo(viewModel, inputText);
    [terminal1 subscribe:terminal2];
    [terminal2 subscribe:terminal1];
}


@end
