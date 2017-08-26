//
//  MSMyCardController.m
//  Sword
//
//  Created by lee on 2017/6/16.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSMyCardController.h"
#import "MSTextUtils.h"
#import "BankInfo.h"
#import "UIImageView+WebCache.h"
#import "MSBindCardController.h"

@interface MSMyCardController ()

@property (strong, nonatomic) BankInfo *bankInfo;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lbName;
@property (strong, nonatomic) UILabel *lbCardNumber;
@end

@implementation MSMyCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的银行卡";
    [self prepare];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.title pageId:176 params:nil];
}

- (void)prepare {

    if (self.accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
        [self setupNotBindView];
    } else {
        [self setupRegistView];
        [self queryData];
    }
    
}

- (void)setupNotBindView {
    float margin = 16;
    float width = self.view.bounds.size.width;
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, width-2*margin, 180)];
    cardView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bindCard)];
    [cardView addGestureRecognizer:tap];
//    cardView.layer.cornerRadius = 8;
//    cardView.layer.masksToBounds = YES;
//    cardView.layer.borderWidth = 2;
//    cardView.layer.borderColor = [UIColor clearColor].CGColor;
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor ms_colorWithHexString:@"979797"].CGColor;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRect:cardView.bounds].CGPath;
    border.lineWidth = 2.f;
    border.lineCap = kCALineCapRound;
    border.lineDashPattern = @[@4,@4];
    [cardView.layer addSublayer:border];
    [self.view addSubview:cardView];
    
    UILabel *lbtitle = [UILabel newAutoLayoutView];
    lbtitle.text = @"点击添加银行卡";
    lbtitle.textAlignment = NSTextAlignmentCenter;
    lbtitle.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    lbtitle.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    lbtitle.center = CGPointMake(cardView.center.x, cardView.center.y-30);
    [cardView addSubview:lbtitle];
    [lbtitle autoCenterInSuperview];
    
    UIImageView *add = [UIImageView newAutoLayoutView];
    [add setImage:[UIImage imageNamed:@"ms_card_add"]];
    [cardView addSubview:add];
    [add autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbtitle];
    [add autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:lbtitle withOffset:-10];
    [add autoSetDimensionsToSize:CGSizeMake(16, 16)];
    
}

- (void)bindCard {

    MSBindCardController *bind = [[MSBindCardController alloc] init];
    __weak typeof(self)weakSelf = self;
    bind.bindCardComplete = ^{
        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
    };
    [self.navigationController pushViewController:bind animated:YES];
    
}

- (void)setupRegistView {

    float margin = 16;
    float width = self.view.bounds.size.width;
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ms_bg_image"]];
    backImage.layer.cornerRadius = 8;
    backImage.layer.masksToBounds = YES;
    backImage.frame = CGRectMake(margin, margin, width-2*margin, 180);
    [self.view addSubview:backImage];
    
    self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(margin, 24, 40, 40)];
    [backImage addSubview:self.icon];
    
    UILabel *lbName = [UILabel newAutoLayoutView];
    lbName.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    lbName.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    self.lbName = lbName;
    [backImage addSubview:self.lbName];
    [self.lbName autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.icon withOffset:8];
    [self.lbName autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.icon];
    
    UILabel *lbType = [[UILabel alloc] initWithFrame:CGRectMake(backImage.bounds.size.width-52, 38, 36, 12)];
    lbType.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    lbType.textAlignment = NSTextAlignmentRight;
    lbType.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    lbType.text = @"储蓄卡";
    [backImage addSubview:lbType];
    
    UILabel *cardNum = [UILabel newAutoLayoutView];
    cardNum.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:24];
    cardNum.textAlignment = NSTextAlignmentCenter;
    cardNum.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    self.lbCardNumber = cardNum;
    [backImage addSubview:self.lbCardNumber];
    [self.lbCardNumber autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.lbCardNumber autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:49];
    
    UILabel *lbHint = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-64-32, width, margin)];
    lbHint.textAlignment = NSTextAlignmentCenter;
    lbHint.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    lbHint.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1/1.0];
    lbHint.text = @"账户保障中";
    [self.view addSubview:lbHint];
    
}

- (void)queryData {
    
    NSString *cardId = [self.accountInfo.cardId substringFromIndex:self.accountInfo.cardId.length-4];
    self.lbCardNumber.text = [NSString stringWithFormat:@"**** **** **** %@",cardId];
    
    __weak typeof(self)weakSelf = self;
    [[[MSAppDelegate getServiceManager] querySupportBankListByIds:@[self.accountInfo.bankId]] subscribeNext:^(NSArray *bankList) {
        weakSelf.bankInfo = (BankInfo *)bankList.firstObject;
        [weakSelf setData];
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        if (![MSTextUtils isEmpty:result.message]) {
            [MSToast show:result.message];
        } else {
            [MSToast show:@"获取银行卡信息失败"];
        }
    }];
    
}

- (void)setData {
    
    [self.icon sd_setImageWithURL:[NSURL URLWithString:_bankInfo.bankUrl] placeholderImage:[UIImage imageNamed:@"bank_icon_placeholder"] options:SDWebImageAllowInvalidSSLCertificates];//SDWebImageAllowInvalidSSLCertificates
    self.lbName.text = _bankInfo.bankName;
    
}

@end
