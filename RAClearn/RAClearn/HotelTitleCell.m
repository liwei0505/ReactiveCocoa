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
@property (strong, nonatomic) UITextField *phone;
@property (strong, nonatomic) UILabel *lbText;
@property (strong, nonatomic) UIButton *btnClear;
@property (strong, nonatomic) HotelTitleViewModel *viewModel;
@property (strong, nonatomic) RACSignal *textSignal;
@end

@implementation HotelTitleCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        float height = 60;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        self.titleLabel.text = @"title";
        self.titleLabel.layer.borderWidth = 1;
        self.titleLabel.textColor = [UIColor orangeColor];
        [self addSubview:self.titleLabel];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, height, frame.size.width, height)];
        self.textField.layer.borderWidth = 1;
        [self addSubview:self.textField];
        
        self.phone = [[UITextField alloc] initWithFrame:CGRectMake(0, 2*height, frame.size.width, height)];
        self.phone.layer.borderWidth = 1;
        [self addSubview:self.phone];
        
        self.lbText = [[UILabel alloc] initWithFrame:CGRectMake(0, 3*height, frame.size.width, height)];
        self.lbText.layer.borderWidth = 1;
        [self addSubview:self.lbText];
        
    }
    return self;
}

//数据绑定  (在view中)
- (void)bindViewModel:(HotelTitleViewModel *)viewModel {
    self.viewModel = viewModel;
    //单向绑定
    RAC(self.titleLabel, text) = RACObserve(self.viewModel, title);
    
    //双向绑定
    RACChannelTerminal *terminal1 = self.textField.rac_newTextChannel;
    RACChannelTerminal *terminal2 = RACChannelTo(self.viewModel, title);
    [terminal1 subscribe:terminal2];
    [terminal2 subscribe:terminal1];
}

//信号组合
- (void)combineHotelTitleViewModel:(HotelTitleViewModel *)hotelTitleVM nameInputViewModel:(NameInputViewModel *)nameVM phoneInputViewModel:(PhoneInputViewModel *)phoneVM {
    NSArray *signals = @[hotelTitleVM.titleSignal,nameVM.inputChannel,phoneVM];
    _textSignal = [RACSignal combineLatest:signals reduce:^id (NSString *title, NSString *name, NSString *phone){
        return [NSString stringWithFormat:@"%@入住%@电话%@",title,name,phone];
    }];
}


@end
