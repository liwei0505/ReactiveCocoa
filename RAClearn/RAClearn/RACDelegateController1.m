//
//  RACDelegateController1.m
//  RAClearn
//
//  Created by lee on 17/4/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "RACDelegateController1.h"
#import "RACDelegateController2.h"

@interface RACDelegateController1 ()
@property (strong, nonatomic) UIButton *button;
@end

@implementation RACDelegateController1

- (void)viewDidLoad {
    [super viewDidLoad];

    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.button setTitle:@"点击vc1" forState:UIControlStateNormal];
    self.button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACDelegateController2 *vc = [[RACDelegateController2 alloc] init];
        vc.delegateSignal = [RACSubject subject];
        [vc.delegateSignal subscribeNext:^(id x) {
            NSLog(@"vc1====>点击了vc2按钮");
            
        }];
        [self presentViewController:vc animated:YES completion:nil];
        
        return [RACSignal empty];
    }];
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 100));
    }];
}


@end
