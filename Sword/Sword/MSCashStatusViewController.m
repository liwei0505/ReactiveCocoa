//
//  MSCashStatusViewController.m
//  Sword
//
//  Created by msj on 2017/7/4.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCashStatusViewController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "MSMainController.h"
#import "MSConfig.h"
#import "MSFundsFlowController.h"
#import "MSStoryboardLoader.h"
#import "NSDate+Add.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height

@interface MSCashStatusViewController ()
@property (assign, nonatomic) MSCashStatusType type;
@property (copy, nonatomic) NSString *money;
@property (copy, nonatomic) NSString *message;

@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation MSCashStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureElement];
    [self addSubViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:@"提现成功" pageId:204 params:nil];
}

#pragma mark - Public
- (void)updateWithType:(MSCashStatusType)type money:(NSString *)money message:(NSString *)message {
    self.type = type;
    self.money = money;
    self.message = message;
}

#pragma mark - Private
- (void)configureElement {
    self.navigationItem.title = @"提现";
}

- (void)addSubViews {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 64)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - 109*scaleX)/2.0, 49*scaleY, 109*scaleX, 109*scaleX)];
    [self.scrollView addSubview:imageView];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+27*scaleY, self.view.width, 25)];
    lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    lbTitle.textAlignment = NSTextAlignmentCenter;
    lbTitle.font = [UIFont systemFontOfSize:18];
    [self.scrollView addSubview:lbTitle];
    
    CGFloat btnBackY = 0;
    if (self.type == MSCashStatusType_success) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbTitle.frame)+20*scaleY, self.view.width, 81*scaleY)];
        contentView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:contentView];
        
        UILabel *lbMoney = [UILabel newAutoLayoutView];
        lbMoney.font = [UIFont systemFontOfSize:12];
        lbMoney.textAlignment = NSTextAlignmentCenter;
        lbMoney.text = self.money;
        lbMoney.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [contentView addSubview:lbMoney];
        [lbMoney autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [lbMoney autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        UILabel *lbDate = [UILabel newAutoLayoutView];
        lbDate.font = [UIFont systemFontOfSize:10];
        lbDate.textAlignment = NSTextAlignmentCenter;
        lbDate.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        [contentView addSubview:lbDate];
        [lbDate autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbMoney withOffset:4];
        [lbDate autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:lbMoney];
        NSDate *date = [NSDate date];
        lbDate.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld",(long)date.year,(long)date.month,(long)date.day,(long)date.hour,(long)date.minute];
        
        UILabel *lbComplete = [UILabel newAutoLayoutView];
        lbComplete.font = [UIFont systemFontOfSize:12];
        lbComplete.textAlignment = NSTextAlignmentCenter;
        lbComplete.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        [contentView addSubview:lbComplete];
        [lbComplete autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [lbComplete autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:lbMoney];
        lbComplete.text = self.message;
        
        UIView *point1 = [UIView newAutoLayoutView];
        point1.layer.cornerRadius = 6;
        point1.layer.masksToBounds = YES;
        point1.layer.borderWidth = 1;
        point1.backgroundColor = [UIColor ms_colorWithHexString:@"#BBB9FF"];
        point1.layer.borderColor = [UIColor ms_colorWithHexString:@"#4945B7"].CGColor;
        [contentView addSubview:point1];
        [point1 autoSetDimensionsToSize:CGSizeMake(12, 12)];
        [point1 autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:lbMoney withOffset:-8];
        [point1 autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbMoney];
        
        UIView *point2 = [UIView newAutoLayoutView];
        point2.layer.cornerRadius = 6;
        point2.layer.masksToBounds = YES;
        point2.layer.borderWidth = 1;
        point2.backgroundColor = [UIColor whiteColor];
        point2.layer.borderColor = [UIColor ms_colorWithHexString:@"#4945B7"].CGColor;
        [contentView addSubview:point2];
        [point2 autoSetDimensionsToSize:CGSizeMake(12, 12)];
        [point2 autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:lbComplete withOffset:-8];
        [point2 autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbComplete];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#4945B7"];
        [contentView addSubview:line];
        [line autoSetDimension:ALDimensionWidth toSize:1];
        [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:point1 withOffset:8];
        [line autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:point2 withOffset:-8];
        [line autoAlignAxis:ALAxisVertical toSameAxisOfView:point1];
        
        btnBackY = CGRectGetMaxY(contentView.frame) + 41*scaleY;
        
    } else {
        
        UILabel *lbMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbTitle.frame)+20*scaleY, self.view.width, 14)];
        lbMessage.font = [UIFont systemFontOfSize:12];
        lbMessage.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        lbMessage.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:lbMessage];
        lbMessage.text = self.message;
        btnBackY = CGRectGetMaxY(lbMessage.frame) + 41*scaleY;
    }
    
    @weakify(self);
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(16, btnBackY, self.view.width - 32, 41*scaleY)];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    btnBack.layer.masksToBounds = YES;
    btnBack.layer.cornerRadius = 41*scaleY / 2.0;
    btnBack.titleLabel.font = [UIFont systemFontOfSize:16];
    [[btnBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self.scrollView addSubview:btnBack];
    
    UIButton *btnRecord = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBack.frame)+27*scaleY, self.view.width, 20)];
    [btnRecord setTitle:@"交易记录" forState:UIControlStateNormal];
    [btnRecord setTitleColor:[UIColor ms_colorWithHexString:@"#4229B3"] forState:UIControlStateNormal];
    btnRecord.titleLabel.font = [UIFont systemFontOfSize:14];
    [[btnRecord rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self popToIndex:2];
    }];
    [self.scrollView addSubview:btnRecord];

    
    if (self.type == MSCashStatusType_success) {
        imageView.image = [UIImage imageNamed:@"pay_success"];
        lbTitle.text = @"提现成功";
        [btnBack setTitle:@"完成" forState:UIControlStateNormal];
        btnRecord.hidden = NO;
    } else {
        imageView.image = [UIImage imageNamed:@"pay_failure"];
        lbTitle.text = @"提现失败";
        [btnBack setTitle:@"返回" forState:UIControlStateNormal];
        btnRecord.hidden = YES;
    }
    
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(btnRecord.frame));
    
}

- (void)popToIndex:(NSUInteger)index {
    MSMainController *tab = [MSAppDelegate getInstance].getNavigationController.viewControllers[0];
    tab.selectedIndex = index;
    [self.navigationController popToRootViewControllerAnimated:NO];
    MSFundsFlowController *controller = [MSStoryboardLoader loadViewController:@"account" withIdentifier:@"sid_funds_flow"];
    [[MSAppDelegate getInstance].getNavigationController pushViewController:controller animated:NO];
}

@end
