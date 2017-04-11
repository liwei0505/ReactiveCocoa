//
//  RACDelegateController2.m
//  RAClearn
//
//  Created by lee on 17/4/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RACDelegateController2.h"

@interface RACDelegateController2 ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation RACDelegateController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"点击vc2" forState:UIControlStateNormal];
    self.button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
       
        // 通知第一个控制器，告诉它，按钮被点了
        if (self.delegateSignal) {
            [self.delegateSignal sendNext:nil];
        }
        
        return [RACSignal empty];
    }];
    
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 100));
    }];
    
    
}



@end
