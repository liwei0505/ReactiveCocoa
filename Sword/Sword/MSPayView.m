//
//  MSPayView.m
//  Sword
//
//  Created by msj on 2016/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPayView.h"
#import "MSNotificationHelper.h"
#import "MSPinLoadingView.h"
#import "MSTradePasswordView.h"
#import "MSVerificationCodeView.h"
#import "UIView+FrameUtil.h"
#import "MJSNotifications.h"
#import "MSRechargeTwo.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height

@interface MSPayView ()
@property (strong, nonatomic) MSPinLoadingView *loadingView;
@property (strong, nonatomic) MSTradePasswordView *passwordView;
@property (strong, nonatomic) MSVerificationCodeView *codeView;

@property (copy, nonatomic) NSString *money;
@property (copy, nonatomic) NSString *protocolName;
@property (copy, nonatomic) NSString *phoneNumber;
@end

@implementation MSPayView

- (MSTradePasswordView *)passwordView
{
    if (!_passwordView) {
        _passwordView = [[MSTradePasswordView alloc] initWithFrame:CGRectMake(0, screenHeight - 234 - [self keyBoardHeight], screenWidth, 234)];
        __weak typeof(self)weakSelf = self;
        _passwordView.finishInputTradePasswordBlock = ^(NSString *tradePassword){
            
            weakSelf.loadingView.tips = @"验证交易密码中...";
            [weakSelf addSubview:weakSelf.loadingView];
            [weakSelf.loadingView toFirstResponder];
            [weakSelf.passwordView reset];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ms_payViewDidInputTradePassword:)]) {
                [weakSelf.delegate ms_payViewDidInputTradePassword:tradePassword];
            }
        };
        _passwordView.forgetPasswordBlock = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ms_payViewDidForgetTradePassword)]) {
                [weakSelf.delegate ms_payViewDidForgetTradePassword];
            }
        };
        _passwordView.lookProtocolBlock = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ms_payViewDidLookProtocol)]) {
                [weakSelf.delegate ms_payViewDidLookProtocol];
            }
        };
        _passwordView.cancelBlock = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ms_payViewDidCancel)]) {
                [weakSelf.delegate ms_payViewDidCancel];
            }
        };
    }
    return _passwordView;
}

- (MSPinLoadingView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[MSPinLoadingView alloc] initWithFrame:CGRectMake(0, screenHeight - 234 - [self keyBoardHeight], screenWidth, 234)];
        [_loadingView startRotation];
    }
    return _loadingView;
}

- (MSVerificationCodeView *)codeView
{
    if (!_codeView) {
        _codeView = [[MSVerificationCodeView alloc] initWithFrame:CGRectMake(0, screenHeight - 234 - [self keyBoardHeight], screenWidth, 234)];
        __weak typeof(self)weakSelf = self;
        _codeView.cancelBlock = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ms_payViewDidCancel)]) {
                [weakSelf.delegate ms_payViewDidCancel];
            }
        };
        
        _codeView.getVerificationCodeBlock = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ms_payViewNeedVerificationCode)]) {
                [weakSelf.delegate ms_payViewNeedVerificationCode];
            }
        };
        
        _codeView.makeSureBlock = ^(NSString *verificationCode){
            weakSelf.loadingView.tips = @"验证短信中...";
            [weakSelf addSubview:weakSelf.loadingView];
            [weakSelf.loadingView toFirstResponder];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ms_payViewDidClickConfirmButton:)]) {
                [weakSelf.delegate ms_payViewDidClickConfirmButton:verificationCode];
            }
        };
    }
    return _codeView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [MSNotificationHelper addObserver:self selector:@selector(getVerificationCode:) name:NOTIFY_GET_VERIFICATIONCODE];
        [MSNotificationHelper addObserver:self selector:@selector(checkVerificationCode:) name:NOTIFY_CHECK_VERIFICATIONCODE];
        [MSNotificationHelper addObserver:self selector:@selector(checkTradePassword:) name:NOTIFY_CHECK_TRADEPASSWORDVIEW];
        [self addSubview:self.passwordView];
        [self.passwordView toFirstResponder];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
        [pan.rac_gestureSignal subscribe:[RACEmptySubscriber empty]];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)willMoveToSuperview:(nullable UIView *)newSuperview
{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    [super willMoveToSuperview:newSuperview];
}

- (void)removeFromSuperview
{
    [self.codeView.countDownView invalidate];
    [super removeFromSuperview];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [MSNotificationHelper removeObserver:self];
}

- (void)updateMoney:(NSString *)money protocolName:(NSString *)protocolName phoneNumber:(NSString *)phoneNumber;
{
    self.money = money;
    self.protocolName = protocolName;
    self.phoneNumber = phoneNumber;
    [self.passwordView updateMoney:money protocolName:protocolName];
    
}

#pragma mark - 通知回调
- (void)getVerificationCode:(NSNotification *)noti
{
 
    [self addSubview:self.codeView];
    [self.codeView toFirstResponder];
    [self.loadingView removeFromSuperview];
    
    NSDictionary *dic = (NSDictionary *)noti.object;
    NSInteger result = [dic[@"result"] integerValue];
    NSString *message = dic[@"message"];
    
    switch (result) {
        case MSRechargeTwoModeSuccess:
        {
            NSString *tips = [NSString stringWithFormat:@"已向尾号%@的手机发送短信验证码",[self.phoneNumber substringFromIndex:self.phoneNumber.length - 4]];
            [self.codeView updateWithTips:tips isSuccess:YES];
            self.codeView.countDownView.currentMode = MSCountDownViewModeCountDown;
            break;
        }
//        case MSRechargeTwoModeGetVeriCodeError:
//        {
//            NSString *tips = nil;
//            if (message && message.length > 0) {
//                tips = message;
//            }else{
//                tips = @"获取短信验证码失败";
//            }
//            [self.codeView updateWithTips:tips isSuccess:NO];
//            [self.codeView reset];
//            self.codeView.countDownView.currentMode = MSCountDownViewModeNormal;
//            break;
//        }
        case MSRechargeTwoModeTooFrequent:
        {
            NSString *tips = nil;
            if (message && message.length > 0) {
                tips = message;
            }else{
                tips = @"获取短信验证码太频繁";
            }
            [self.codeView updateWithTips:tips isSuccess:NO];
            [self.codeView reset];
            self.codeView.countDownView.currentMode = MSCountDownViewModeNormal;
            break;
        }
        default:
            break;
    }
    
}

- (void)checkVerificationCode:(NSNotification *)noti
{
    [self bringSubviewToFront:self.codeView];
    [self.codeView toFirstResponder];
    [self.codeView reset];
    [self.loadingView removeFromSuperview];
    NSString *tips = @"短信验证码错误";
    [self.codeView updateWithTips:tips isSuccess:NO];
}

- (void)checkTradePassword:(NSNotification *)noti
{
    switch (self.payMode) {
        case MSPayModeCharge:
        {
            self.passwordView.isPasswordSuccess = NO;
            [self.passwordView toFirstResponder];
            [self.loadingView removeFromSuperview];
            break;
        }
        case MSPayModeCash:
        {
            self.passwordView.isPasswordSuccess = NO;
            [self.passwordView toFirstResponder];
            [self.loadingView removeFromSuperview];
            break;
        }
        case MSPayModeInvest:
        {
            self.passwordView.isPasswordSuccess = NO;
            [self.passwordView toFirstResponder];
            [self.loadingView removeFromSuperview];
            break;
        }
        case MSPayModeLoan:
        {
            self.passwordView.isPasswordSuccess = NO;
            [self.passwordView toFirstResponder];
            [self.loadingView removeFromSuperview];
            break;
        }
        case MSPayModeCurrentInvest:
        {
            self.passwordView.isPasswordSuccess = NO;
            [self.passwordView toFirstResponder];
            [self.loadingView removeFromSuperview];
            break;
        }
        case MSPayModeCurrentRedeem:
        {
            self.passwordView.isPasswordSuccess = NO;
            [self.passwordView toFirstResponder];
            [self.loadingView removeFromSuperview];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)keyBoardHeight
{
    if (screenHeight >= 736) {
        return 226 + 30;
    }else if (screenHeight >= 667){
        return 216 + 30;
    }else if (screenHeight >= 568){
        return 216 + 30;
    }
    return 216 + 30;
}

- (void)pageEvent:(int)pageId title:(NSString *)title {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = pageId;
    if (title) {
        params.title = title;
    } else {
        params.title =  (pageId == 154) ? @"请输入验证码" : @"请输入交易密码";
    }
    [MJSStatistics sendPageParams:params];
    
}

@end
