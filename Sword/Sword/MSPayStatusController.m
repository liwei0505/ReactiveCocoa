//
//  MSPayStatusController.m
//  Sword
//
//  Created by msj on 2016/12/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPayStatusController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"

@interface MSPayStatusController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbMessage;
@property (strong, nonatomic) UIButton *btnBack;

@property (copy, nonatomic) NSString *titleStr;
@property (copy, nonatomic) NSString *messageStr;
@property (copy, nonatomic) NSString *iconStr;
@end

@implementation MSPayStatusController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.title = @"提示";
    [self addBackItem];
    [self addsubviews];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (void)addBackItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"risk_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)addsubviews
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - 100)/2.0, 111, 100, 100)];
    [self.view addSubview:self.imageView];
    
    self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame)+30, self.view.width, 18)];
    self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#323232"];
    self.lbTitle.textAlignment = NSTextAlignmentCenter;
    self.lbTitle.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.lbTitle];
    
    self.lbMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.lbTitle.frame)+9, self.view.width - 30, 0)];
    self.lbMessage.textColor = [UIColor ms_colorWithHexString:@"#5A5A5A"];
    self.lbMessage.textAlignment = NSTextAlignmentCenter;
    self.lbMessage.font = [UIFont systemFontOfSize:14];
    self.lbMessage.numberOfLines = 0;
    [self.view addSubview:self.lbMessage];
    
    self.btnBack = [[UIButton alloc] initWithFrame:CGRectMake(13, 0, self.view.width - 26, 42)];
    [self.btnBack setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.btnBack setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.btnBack setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    self.btnBack.layer.masksToBounds = YES;
    self.btnBack.layer.cornerRadius = 21;
    [self.btnBack setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:self.btnBack];
    [self.btnBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageView.image = [UIImage imageNamed:self.iconStr];
    self.lbTitle.text = self.titleStr;
    self.lbMessage.text = self.messageStr;
    
    CGSize size = [self.messageStr boundingRectWithSize:CGSizeMake(self.view.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    self.lbMessage.height = size.height + 5;
    self.btnBack.y = CGRectGetMaxY(self.lbMessage.frame) + 75;
}

- (void)back
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.backActionBlock) {
        self.backActionBlock();
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updatePayStatusSubMode:(MSPayStatusSubMode)payStatusSubMode payStatusMode:(MSPayStatusMode)payStatusMode withMessage:(NSString *)message
{
    if (payStatusMode == MSPayStatusModeSuccess) {
        self.iconStr = @"pay_success";
        switch (payStatusSubMode) {
            case MSPayStatusSubModeCash:
            {
                self.titleStr = @"申请成功";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeCharge:
            {
                self.titleStr = @"充值成功";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeInvest:
            {
                self.titleStr = @"投资成功";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeLoan:
            {
                self.titleStr = @"认购成功";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeSetTradePassword:
            {
                self.titleStr = @"设置成功";
                self.messageStr = (message&&message.length>0) ? message : @"交易密码设置成功";
                break;
            }
            case MSPayStatusSubModeResetTradePassword:
            {
                self.titleStr = @"设置成功";
                self.messageStr = (message&&message.length>0) ? message : @"交易密码设置成功";
                break;
            }
            case MSPayStatusSubModeBindBank:
            {
                self.titleStr = @"绑卡成功";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            default:
                break;
        }
    }else if (payStatusMode == MSPayStatusModeFail){
        self.iconStr = @"pay_failure";
        switch (payStatusSubMode) {
            case MSPayStatusSubModeCash:
            {
                self.titleStr = @"申请失败";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeCharge:
            {
                self.titleStr = @"充值失败";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeInvest:
            {
                self.titleStr = @"投资失败";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeLoan:
            {
                self.titleStr = @"认购失败";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeSetTradePassword:
            {
                self.titleStr = @"设置失败";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeResetTradePassword:
            {
                self.titleStr = @"设置失败";
                self.messageStr = (message&&message.length>0) ? message : @"";
                break;
            }
            case MSPayStatusSubModeBindBank:
            {
                self.titleStr = @"绑卡失败";
                self.messageStr = (message&&message.length>0) ? message : @"系统异常";
                break;
            }
            default:
                break;
        }
    }
    [self pageEventWithTitle:self.titleStr pageId:[self getPageId:payStatusSubMode] params:nil];
}

- (int)getPageId:(MSPayStatusSubMode)status {

    switch (status) {
        case MSPayStatusSubModeInvest:
            return 201;
        case MSPayStatusSubModeSetTradePassword:
            return 202;
        case MSPayStatusSubModeCharge:
            return 203;
        case MSPayStatusSubModeCash:
            return 204;
        case MSPayStatusSubModeResetTradePassword:
            return 205;
        default:
            return 0;
    }
}

@end
