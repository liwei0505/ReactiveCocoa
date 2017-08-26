//
//  MSCurrentInvestController.m
//  Sword
//
//  Created by msj on 2017/4/6.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentInvestController.h"
#import "MSWebViewController.h"
#import "UIView+FrameUtil.h"
#import "MSCurrentTextField.h"
#import "MSInputAccessoryView.h"
#import "MSCheckInfoUtils.h"
#import "MSPayView.h"
#import "MSResetTradePasswordA.h"
#import "NSString+Ext.h"
#import "MSCurrentResultController.h"
#import "UINavigationController+removeAtIndex.h"
#import "UIImage+color.h"
#import "MSBalanceViewController.h"
#import "MSStoryboardLoader.h"
#import "MSBindCardController.h"
#import "MSLoginController.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height

@interface MSCurrentInvestController ()<MSPayViewDelegate>
@property (strong, nonatomic) MSCurrentTextField *textField;
@property (strong, nonatomic) UILabel *lbConfigue;
@property (strong, nonatomic) UIButton *btnSure;
@property (strong, nonatomic) MSPayView *payView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnAgreement;


@property (strong, nonatomic) AssetInfo *assetInfo;
@property (strong, nonatomic) AccountInfo *accountInfo;

@property (strong, nonatomic) CurrentPurchaseConfig *purchaseConfig;

@property (strong, nonatomic) RACDisposable *assetInfoSubscription;
@property (strong, nonatomic) RACDisposable *accountInfoSubscription;

@end

@implementation MSCurrentInvestController

#pragma mark - Lazy
- (MSPayView *)payView{
    
    if (!_payView) {
        _payView = [[MSPayView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        _payView.delegate = self;
    }
    return _payView;
}

#pragma mark - LifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configueElement];
    [self addSubViews];
    [self subscribe];
    [self queryCurrentPurchaseConfig];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    if (self.assetInfoSubscription) {
        [self.assetInfoSubscription dispose];
        self.assetInfoSubscription = nil;
    }
    if (self.accountInfoSubscription) {
        [self.accountInfoSubscription dispose];
        self.accountInfoSubscription = nil;
    }
}

#pragma mark - MSPayViewDelegate
- (void)ms_payViewDidCancel{
    [self.payView removeFromSuperview];
    self.payView = nil;
}

- (void)ms_payViewDidInputTradePassword:(NSString *)tradePassword{
    [self purchaseCurrentWithTradePassword:tradePassword];
}

- (void)ms_payViewDidForgetTradePassword{
    [self ms_payViewDidCancel];
    [self resetTradePassword];
}

- (void)resetTradePassword {
    MSResetTradePasswordA *resetTradePassword = [[MSResetTradePasswordA alloc] init];
    [self.navigationController pushViewController:resetTradePassword animated:YES];
}

#pragma mark - Private
- (void)configueElement {
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    self.navigationItem.title = self.currentDetail.baseInfo.title;
}

- (void)addSubViews {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    [self.view addSubview:scrollView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, 125)];
    topView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:topView];
    
    self.textField = [[MSCurrentTextField alloc] initWithFrame:CGRectMake(20, 32, self.view.width - 40, 40)];
    NSString *placeHolder = [NSString stringWithFormat:@"起投%.2f元,递增%.2f元",self.currentDetail.baseInfo.startAmount.doubleValue,self.currentDetail.baseInfo.inceaseAmount.doubleValue];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:placeHolder attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#C9D0D5"]}];
    self.textField.attributedPlaceholder = attStr;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    UILabel *leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    leftView.text = @"元";
    leftView.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    leftView.textAlignment = NSTextAlignmentCenter;
    leftView.font = [UIFont systemFontOfSize:14];
    self.textField.rightView = leftView;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    self.textField.inputAccessoryView = [[MSInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    @weakify(self);
    [self.textField.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        self.btnSure.enabled = (text.length > 0 && self.btnAgreement.selected);
    }];
    [topView addSubview:self.textField];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textField.frame) + 10, 16, 16)];
    self.imageView.image = [UIImage imageNamed:@"can_purchase"];
    [topView addSubview:self.imageView];
    
    self.lbConfigue = [[UILabel alloc] init];
    self.lbConfigue.textAlignment = NSTextAlignmentLeft;
    self.lbConfigue.font = [UIFont systemFontOfSize:11];
    self.lbConfigue.numberOfLines = 0;
    self.lbConfigue.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    self.lbConfigue.text = @"可用余额：--元";
    [topView addSubview:self.lbConfigue];
    
    self.btnSure = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame)+20, self.view.width, 44)];
    [self.btnSure setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#FC646A"] withSize:CGSizeMake(self.view.width, 44)] forState:UIControlStateNormal];
    [self.btnSure setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#F0F0F0"] withSize:CGSizeMake(self.view.width, 44)] forState:UIControlStateDisabled];
    [self.btnSure setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"#E5494F"] withSize:CGSizeMake(self.view.width, 44)] forState:UIControlStateHighlighted];
    [self.btnSure setTitle:@"立即买入" forState:UIControlStateNormal];
    [self.btnSure setTitleColor:[UIColor ms_colorWithHexString:@"#ADADAD"] forState:UIControlStateDisabled];
    [self.btnSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnSure.enabled = NO;
    [scrollView addSubview:self.btnSure];
    [[self.btnSure rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self purchase];
    }];
    
    self.btnAgreement = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.btnSure.frame) + 14.5, 12, 12)];
    [self.btnAgreement setImage:[UIImage imageNamed:@"agreeSelected"] forState:UIControlStateSelected];
    [self.btnAgreement setImage:[UIImage imageNamed:@"agreeNormal"] forState:UIControlStateNormal];
    self.btnAgreement.selected = YES;
    self.btnAgreement.showsTouchWhenHighlighted = YES;
    [scrollView addSubview:self.btnAgreement];
    [[self.btnAgreement rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.btnAgreement.selected = !self.btnAgreement.selected;
        self.btnSure.enabled = (self.textField.text.length > 0 && self.btnAgreement.selected);
    }];
    
    NSMutableString *string = [NSMutableString stringWithString:@"已经阅读并认可"];
    for (int i = 0; i < self.currentDetail.productInfo.items.count; i++) {
        CurrentProductItem *item = self.currentDetail.productInfo.items[i];
        if (i == self.currentDetail.productInfo.items.count - 1) {
            [string appendString:[NSString stringWithFormat:@"《%@》。投资有风险，理财需谨慎。",item.name]];
        }else {
            [string appendString:[NSString stringWithFormat:@"《%@》、",item.name]];
        }
    }
    NSString *pattern = @"《[\u4e00-\u9fa5]+》";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *arrR = [regex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:string];
    attribute.yy_color = [UIColor ms_colorWithHexString:@"#999999"];
    attribute.yy_lineSpacing = 5;
    attribute.yy_font = [UIFont systemFontOfSize:12];
    attribute.yy_alignment = NSTextAlignmentLeft;
    
    for (NSTextCheckingResult *match in arrR) {
        @weakify(self);
        [attribute yy_setTextHighlightRange:match.range color:[UIColor ms_colorWithHexString:@"#FC646A"] backgroundColor:[UIColor ms_colorWithHexString:@"C9D0D5"] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            @strongify(self);
            for (CurrentProductItem *item in self.currentDetail.productInfo.items) {
                if ([[text attributedSubstringFromRange:range].string containsString:item.name]) {
                    
                    if (![[MSAppDelegate getServiceManager] isLogin]) {
                        [self login];
                        return;
                    }
                    if (self.accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
                        [self bindCard];
                        return;
                    }
                    
                    if (![[MSAppDelegate getServiceManager] setSessionForURL:item.url]) {
                        [MSToast show:@"网络繁忙，请稍后再试!"];
                    }else {
                        MSWebViewController *webVC = [MSWebViewController load];
                        webVC.url = [[MSAppDelegate getServiceManager] setSessionForURL:item.url];
                        webVC.navigationItem.title = item.name;
                        [self.navigationController pushViewController:webVC animated:YES];
                    }
                    return;
                }
            }
        }];
    }
    
    YYLabel *lbAgreement = [YYLabel new];
    lbAgreement.numberOfLines = 0;
    lbAgreement.attributedText = attribute;
    YYTextContainer  *titleContarer = [YYTextContainer containerWithSize:CGSizeMake(self.view.width - 60, MAXFLOAT) insets:UIEdgeInsetsMake(2, 0, 2, 0)];
    YYTextLayout *titleLayout = [YYTextLayout layoutWithContainer:titleContarer text:attribute];
    lbAgreement.frame = CGRectMake(40, self.btnAgreement.y, titleLayout.textBoundingSize.width, titleLayout.textBoundingSize.height);
    [scrollView addSubview:lbAgreement];
    
}

- (void)subscribe {
    @weakify(self);
    self.assetInfoSubscription = [[RACEventHandler subscribe:[AssetInfo class]] subscribeNext:^(AssetInfo *assetInfo) {
        @strongify(self);
        self.assetInfo = assetInfo;
        [self updateConfigueMoney];
    }];
    
    self.accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
    }];
}

- (void)purchase {
    
    [self.view endEditing:YES];
    
    if (![MSCheckInfoUtils amountOfChargeAndCashCheckou:self.textField.text]) {
        [MSToast show:@"输入金额不正确"];
        return;
    }
    
    if (self.textField.text.doubleValue < self.currentDetail.baseInfo.startAmount.doubleValue) {
        [MSToast show:@"小于起投金额，请重新输入"];
        return;
    }
    
    NSInteger inputMoney = (NSInteger)(self.textField.text.doubleValue * 100);
    NSInteger startMoney = (NSInteger)(self.currentDetail.baseInfo.startAmount.doubleValue * 100);
    NSInteger inceaseMoney = (NSInteger)(self.currentDetail.baseInfo.inceaseAmount.doubleValue * 100);
    NSInteger remainder = (inputMoney - startMoney) % inceaseMoney;
    
    if (remainder != 0) {
        [MSToast show:@"输入金额不正确"];
        return;
    }
    
    if (self.textField.text.doubleValue > self.assetInfo.balance.doubleValue) {
        MSAlertController *alertVc = [MSAlertController alertControllerWithTitle:nil message:@"可用余额不足，请重新输入" preferredStyle:UIAlertControllerStyleAlert];
        [alertVc msSetMssageColor:[UIColor ms_colorWithHexString:@"#555555"] mssageFont:[UIFont systemFontOfSize:16.0]];
        @weakify(self);
        MSAlertAction *cancel = [MSAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            [self.textField becomeFirstResponder];
        }];
        cancel.mstextColor = [UIColor ms_colorWithHexString:@"#333092"];
        MSAlertAction *sure = [MSAlertAction actionWithTitle:@"去充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            [self.view endEditing:YES];
            MSBalanceViewController *vc = [[MSBalanceViewController alloc] init];
            vc.getIntoType = MSBalanceGetIntoType_deterCurrentPage;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        sure.mstextColor = [UIColor ms_colorWithHexString:@"#333092"];
        [alertVc addAction:cancel];
        [alertVc addAction:sure];
        [self presentViewController:alertVc animated:YES completion:nil];
        return;
    }
    
    if (self.purchaseConfig.canPurchaseLimit.doubleValue >= 0
        && self.textField.text.doubleValue > self.purchaseConfig.canPurchaseLimit.doubleValue) {
        [MSToast show:@"超过当前可投资限额"];
        return;
    }
    
    self.payView.payMode = MSPayModeCurrentInvest;
    [self.payView updateMoney:[NSString stringWithFormat:@"支付%@元",self.textField.text] protocolName:nil phoneNumber:nil];
    [self.navigationController.view addSubview:self.payView];
    
}

- (void)purchaseCurrentWithTradePassword:(NSString *)tradePassword {
    @weakify(self);
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.textField.text];
    [[[MSAppDelegate getServiceManager] purchaseCurrentWithID:self.currentDetail.baseInfo.currentID amount:amount password:[NSString desWithKey:tradePassword key:nil]] subscribeNext:^(CurrentPurchaseNotice *notice) {
        @strongify(self);
        [self ms_payViewDidCancel];
        MSCurrentResultController *vc = [[MSCurrentResultController alloc] init];
        [vc updateWithTimes:@[@(notice.purchaseDate), @(notice.beginInterestDate), @(notice.earningsReceiveDate)] mode:MSCurrentResultModePurchase];
        [self.navigationController pushViewController:vc animated:YES];
        [self.navigationController removeViewcontrollerAtIndex:self.navigationController.viewControllers.count - 2];
    } error:^(NSError *error) {
        @strongify(self);
        [self ms_payViewDidCancel];
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
    } completed:^{
        
    }];
}

- (void)queryCurrentPurchaseConfig {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryCurrentPurchaseConfig:self.currentDetail.baseInfo.currentID] subscribeNext:^(CurrentPurchaseConfig *purchaseConfig) {
        @strongify(self);
        self.purchaseConfig = purchaseConfig;
        [self updateConfigueMoney];
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
    } completed:^{
        
    }];
}

- (void)updateConfigueMoney {
    NSString *configueMoney = nil;
    if (self.purchaseConfig.canPurchaseLimit.doubleValue < 0) {
        configueMoney = [NSString stringWithFormat:@"可用余额：%.2f元",self.assetInfo.balance.doubleValue];
    } else {
        configueMoney = [NSString stringWithFormat:@"可用余额：%.2f元，可投金额：%.2f元",self.assetInfo.balance.doubleValue,self.purchaseConfig.canPurchaseLimit.doubleValue];
    }
    CGSize size = [configueMoney boundingRectWithSize:CGSizeMake(self.view.width - CGRectGetMaxX(self.imageView.frame) - 8 - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.lbConfigue.font} context:nil].size;
    self.lbConfigue.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 8, CGRectGetMaxY(self.textField.frame) + 11, size.width, size.height);
    self.lbConfigue.text = configueMoney;
}

- (void)login {
    MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
    MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)bindCard {
    MSBindCardController *vc = [[MSBindCardController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
