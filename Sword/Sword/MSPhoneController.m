//
//  MSPhoneController.m
//  Sword
//
//  Created by lee on 2017/6/21.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPhoneController.h"
#import "UILabel+Custom.h"

@interface MSPhoneController ()
@property (strong, nonatomic) UILabel *lbPhone;
@end

@implementation MSPhoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepare];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.title pageId:180 params:nil];
}

- (void)prepare {

    self.title = @"绑定手机";
    float width = self.view.bounds.size.width;
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 290)];
    content.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:content];
    
    float margin = 43;
    
    UIImageView *imageView = [UIImageView newAutoLayoutView];
    imageView.image = [UIImage imageNamed:@"ms_blindiphone"];
    [self.view addSubview:imageView];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:margin];
    [imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [imageView autoSetDimensionsToSize:CGSizeMake(72, 72)];
    
    UILabel *lbPhone = [UILabel newAutoLayoutView];
    lbPhone.textAlignment = NSTextAlignmentCenter;
    lbPhone.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1/1.0];
    lbPhone.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    lbPhone.text = self.phonenumber;
    self.lbPhone = lbPhone;
    [content addSubview:self.lbPhone];
    [self.lbPhone autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:imageView withOffset:40];
    [self.lbPhone autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    
    UIView *notice = [self noticeView];
    [content addSubview:notice];
    [notice autoSetDimensionsToSize:CGSizeMake(120, 100)];
    [notice autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:content];
    [notice autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    
}

- (void)setPhonenumber:(NSString *)phonenumber {
    phonenumber = [phonenumber stringByReplacingCharactersInRange:NSMakeRange(3, 6) withString:@"******"];
    NSString *string = [NSString stringWithFormat:@"已绑定手机号%@",phonenumber];
    _phonenumber = string;
}

- (UIView *)noticeView {

    UIView *content = [[UIView alloc] init];
    content.backgroundColor = [UIColor whiteColor];
    NSArray *array = @[@"资金变动短信通知",@"敏感操作短信通知",@"手机号直接登录"];
    for (int i=0; i<3; i++) {
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ms_bank_arrow"]];
        icon.frame = CGRectMake(0, i*30, 14, 14);
        [content addSubview:icon];
        
        UILabel *lb = [UILabel labelWithText:array[i] textSize:12 textColor:@"666666"];
        lb.frame = CGRectMake(23, i*30, lb.bounds.size.width, 14);
        [content addSubview:lb];

    }
    return content;
}


@end
