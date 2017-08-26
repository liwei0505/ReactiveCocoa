//
//  MSInvestConfirmController.m
//  Sword
//
//  Created by haorenjie on 16/6/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInvestConfirmController.h"
#import "MSLog.h"
#import "MSAppDelegate.h"
#import "MSStoryboardLoader.h"
#import "MSNotificationHelper.h"
#import "RedEnvelope.h"
#import "MSToast.h"
#import "MSUrlManager.h"
#import "MSWebViewController.h"
#import "MSStoryboardLoader.h"
#import "MJSStatistics.h"
#import "MSBalanceViewController.h"
#import "MSNavigationController.h"
#import "MSConfig.h"
#import "MSPayView.h"
#import "NSString+Ext.h"
#import "MSResetTradePasswordA.h"
#import "MSAlertController.h"
#import "MSSubmitInvest.h"
#import "MSInvestConfirmDetailView.h"
#import "UIView+FrameUtil.h"
#import "MSBalanceTextField.h"
#import "MSInputAccessoryView.h"
#import "MSInvestDetailRedEnvelopeController.h"
#import "MSToast.h"
#import "MSTextUtils.h"
#import "MSLoginController.h"
#import "MSBindCardController.h"
#import "MSSetTradePassword.h"
#import "MSNotificationHelper.h"
#import "MSInvestStatusController.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height
#define RGB(r,g,b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface MSInvestConfirmController() <MSPayViewDelegate>
{
    RACDisposable *_accountInfoSubscription;
    RACDisposable *_assetInfoSubscription;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MSInvestConfirmDetailView *investConfirmDetailView;
@property (strong, nonatomic) UILabel *lbUnit;
@property (strong, nonatomic) MSBalanceTextField *tfMoney;
@property (strong, nonatomic) UILabel *lbAccountBalance;
@property (strong, nonatomic) UILabel *lbExpectedMoney;
@property (strong, nonatomic) UILabel *lbCardCoupons;
@property (strong, nonatomic) UIButton *btnCommit;
@property (strong, nonatomic) YYLabel *lbProtocol;
@property (strong, nonatomic) UIButton *btnProtocol;

@property (strong, nonatomic) MSPayView *payView;

@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) AssetInfo *assertInfo;
@property (strong, nonatomic) RedEnvelope *redEnvelope;

@property (strong, nonatomic) NSNumber *loanId;
@property (strong, nonatomic) NSDecimalNumber *myInvestedAmount;
@end

@implementation MSInvestConfirmController
#pragma mark - lazy
- (MSPayView *)payView {
    if (!_payView) {
        _payView = [[MSPayView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        _payView.delegate = self;
    }
    return _payView;
}

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self subscribe];
    [self addSubViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
    [self.tfMoney becomeFirstResponder];
}

- (void)dealloc {
    
    [MSNotificationHelper removeObserver:self];
    
    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
    if (_assetInfoSubscription) {
        [_assetInfoSubscription dispose];
        _assetInfoSubscription = nil;
    }
    NSLog(@"%s",__func__);
}

#pragma mark - Public
- (void)updateWithLoanId:(NSNumber *)loanId myInvestedAmount:(NSDecimalNumber *)myInvestedAmount {
    self.loanId = loanId;
    self.myInvestedAmount = myInvestedAmount;
}

#pragma mark - Private
- (void)addSubViews {
    self.navigationItem.title = @"投资";
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"f8f8f8"];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 64)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];
    
    LoanDetail *loanDetail = [[MSAppDelegate getServiceManager] getLoanInfo:self.loanId];
    self.investConfirmDetailView = [[MSInvestConfirmDetailView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    [self.scrollView addSubview:self.investConfirmDetailView];
    self.investConfirmDetailView.loanDetail = loanDetail;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.investConfirmDetailView.frame), self.view.width, 100)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:contentView];
    
    self.lbUnit = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 18, 56)];
    self.lbUnit.font = [UIFont systemFontOfSize:24];
    self.lbUnit.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbUnit.textAlignment = NSTextAlignmentCenter;
    self.lbUnit.text = @"￥";
    [contentView addSubview:self.lbUnit];
    
    @weakify(self);
    self.tfMoney = [[MSBalanceTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lbUnit.frame)+8, 0, self.view.width - CGRectGetMaxX(self.lbUnit.frame) - 32, 56)];
    NSString *planceHolder = [NSString stringWithFormat:@"%d元起投，%ld元递增", loanDetail.baseInfo.startAmount, loanDetail.increaseAmount];
    if (self.myInvestedAmount && self.myInvestedAmount.doubleValue > 0) {
        planceHolder = [NSString stringWithFormat:@"%ld元递增，还可投%.f元",
                        loanDetail.increaseAmount, loanDetail.baseInfo.maxInvestLimit - self.myInvestedAmount.doubleValue];
    }

    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:planceHolder attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
    self.tfMoney.attributedPlaceholder = attStr;
    self.tfMoney.keyboardType = UIKeyboardTypeDecimalPad;
    self.tfMoney.clearButtonMode = UITextFieldViewModeAlways;
    [self.tfMoney.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        if (self.btnProtocol.selected && text.length > 0) {
            self.btnCommit.enabled = YES;
        }else {
            self.btnCommit.enabled = NO;
        }
        
        if (text && text.length > 0) {
            if (loanDetail.baseInfo.termInfo.unitType == TERM_UNIT_DAY) {
                CGFloat money = [loanDetail.baseInfo.termInfo getTermCount] * text.doubleValue * (loanDetail.baseInfo.interest/100) / loanDetail.baseInfo.termInfo.yearRadix;
                [self calculationExpectMoneyWithMoney:money];
            } else {
                CGFloat money = [loanDetail.baseInfo.termInfo getTermCount] * text.doubleValue * (loanDetail.baseInfo.interest/100) / 12;
                [self calculationExpectMoneyWithMoney:money];
            }
        } else {
            [self calculationExpectMoneyWithMoney:0];
        }
    }];
    [contentView addSubview:self.tfMoney];
    self.tfMoney.inputAccessoryView = [[MSInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30)];

    self.lbAccountBalance = [[UILabel alloc] initWithFrame:CGRectMake(16, contentView.height - 44, screenWidth - 32, 44)];
    self.lbAccountBalance.textColor = [UIColor ms_colorWithHexString:@"#333333"];
    self.lbAccountBalance.textAlignment = NSTextAlignmentLeft;
    self.lbAccountBalance.font = [UIFont systemFontOfSize:12];
    self.lbAccountBalance.text = [NSString stringWithFormat:@"账户余额 %@ 元",[NSString convertMoneyFormate:self.assertInfo.balance.doubleValue]];
    [contentView addSubview:self.lbAccountBalance];
    
    UIButton *btnCharge = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 46, contentView.height - 44, 30, 44)];
    [btnCharge setTitle:@"充值" forState:UIControlStateNormal];
    [btnCharge setTitleColor:[UIColor ms_colorWithHexString:@"#4229B3"] forState:UIControlStateNormal];
    btnCharge.titleLabel.font = [UIFont systemFontOfSize:12];
    [contentView addSubview:btnCharge];
    [[btnCharge rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.tfMoney resignFirstResponder];
        [self eventWithName:@"充值" elementId:56 selectedId:nil];
        [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:108 control:3 params:nil];
        MSBalanceViewController *vc = [[MSBalanceViewController alloc] init];
        vc.getIntoType = MSBalanceGetIntoType_deterInvestPage;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 56, screenWidth - 16, 0.5)];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [contentView addSubview:line];
    
    self.lbExpectedMoney = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(contentView.frame), screenWidth - 32, 45)];
    self.lbExpectedMoney.textColor = [UIColor ms_colorWithHexString:@"#666666"];
    self.lbExpectedMoney.font = [UIFont systemFontOfSize:12];
    self.lbExpectedMoney.textAlignment = NSTextAlignmentLeft;
    [self.scrollView addSubview:self.lbExpectedMoney];
    [self calculationExpectMoneyWithMoney:0];
    
    UIView *cardCouponsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lbExpectedMoney.frame), screenWidth, 44)];
    cardCouponsView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:cardCouponsView];
    
    UILabel *lbCardCouponsTips = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 50, 44)];
    lbCardCouponsTips.textAlignment = NSTextAlignmentCenter;
    lbCardCouponsTips.font = [UIFont systemFontOfSize:12];
    lbCardCouponsTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    lbCardCouponsTips.text = @"选择卡券";
    [cardCouponsView addSubview:lbCardCouponsTips];

    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - 30, (cardCouponsView.height - 12)/2.0, 12, 12)];
    arrow.image = [UIImage imageNamed:@"right_arrow"];
    [cardCouponsView addSubview:arrow];
    
    self.lbCardCoupons = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lbCardCouponsTips.frame)+8, 0, arrow.x - CGRectGetMaxX(lbCardCouponsTips.frame) - 32, 44)];
    self.lbCardCoupons.textAlignment = NSTextAlignmentRight;
    self.lbCardCoupons.font = [UIFont systemFontOfSize:12];
    self.lbCardCoupons.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    [cardCouponsView addSubview:self.lbCardCoupons];
    
    if (loanDetail.baseInfo.redEnvelopeTypes == TYPE_NONE) {
        self.lbCardCoupons.text = @"无可用红包";
        arrow.hidden = YES;
    } else {
        if (self.accountInfo.canUseRedEnvelopeNumber > 0) {
            
            arrow.hidden = NO;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
            [[tap rac_gestureSignal] subscribeNext:^(id x) {
                @strongify(self);
                
                [self.tfMoney resignFirstResponder];
                
                if (self.tfMoney.text.length == 0) {
                    [MSToast show:@"请输入投资金额"];
                    return ;
                }
                
                MSInvestDetailRedEnvelopeController *vc = [[MSInvestDetailRedEnvelopeController alloc] init];
                vc.loanId = self.loanId;
                vc.investAmount = self.tfMoney.text.doubleValue;
                vc.blcok = ^(RedEnvelope *redEnvelope) {
                    if (redEnvelope) {
                        self.redEnvelope = redEnvelope;
                        self.lbCardCoupons.text = redEnvelope.usageRange;
                    }else {
                        self.redEnvelope = nil;
                        self.lbCardCoupons.text = @"";
                    }
                    
                };
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [cardCouponsView addGestureRecognizer:tap];
        }else {
            self.lbCardCoupons.text = @"无可用红包";
            arrow.hidden = YES;
        }
    }
    
    self.btnCommit = [[UIButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(cardCouponsView.frame)+16, self.view.width-32, 40)];
    self.btnCommit.layer.masksToBounds = YES;
    self.btnCommit.layer.cornerRadius = 20;
    [self.btnCommit setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.btnCommit setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.btnCommit setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    self.btnCommit.enabled = NO;
    [self.btnCommit setTitle:@"确认投资" forState:UIControlStateNormal];
    [self.btnCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.scrollView addSubview:self.btnCommit];
    [[self.btnCommit rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
   
        NSInteger checkResult = ERR_NONE;
        NSString *inputText = self.tfMoney.text;
        
        if ([MSTextUtils isEmpty:inputText]) {
            checkResult = ERR_INPUT_EMPTY;
        } else if (![MSTextUtils isPureInt:inputText]) {
            checkResult = ERR_INPUT_INVALID;
        } else {
            NSInteger investAmount = [inputText integerValue];
            LoanDetail *loanDetail = [[MSAppDelegate getServiceManager] getLoanInfo:self.loanId];
            if (self.myInvestedAmount) {
                double canInvestAmount = loanDetail.baseInfo.maxInvestLimit - self.myInvestedAmount.doubleValue;
                if (canInvestAmount < investAmount) {
                    [MSToast show:[NSString stringWithFormat:@"您最多还可投入%.f元，请重新输入！", canInvestAmount]];
                    return;
                }
            }

            checkResult = [[MSAppDelegate getServiceManager] investCheck:loanDetail investAmount:investAmount];
        }
        
        if (checkResult == ERR_NONE) {
            
            if (self.assertInfo.balance.doubleValue < self.tfMoney.text.doubleValue) {
                NSString *message = @"账户余额不足，请充值";
                [self eventWithName:@"投资确认" elementId:58 title:self.navigationItem.title pageId:108 params:@{@"loan_id":self.loanId,@"error_msg":message}];
                MSAlertController *alertVc = [MSAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertVc msSetMssageColor:[UIColor ms_colorWithHexString:@"#333333"] mssageFont:[UIFont systemFontOfSize:16.0]];
                MSAlertAction *cancel = [MSAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                cancel.mstextColor = [UIColor ms_colorWithHexString:@"#333333"];
                MSAlertAction *sure = [MSAlertAction actionWithTitle:@"充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    MSBalanceViewController *vc = [[MSBalanceViewController alloc] init];
                    vc.getIntoType = MSBalanceGetIntoType_deterInvestPage;
                    vc.chargeMoney = self.tfMoney.text.doubleValue - self.assertInfo.balance.doubleValue;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
                sure.mstextColor = [UIColor ms_colorWithHexString:@"#F30A1C"];
                [alertVc addAction:cancel];
                [alertVc addAction:sure];
                [self presentViewController:alertVc animated:YES completion:nil];
                return;
            }
            
            [self eventWithName:@"投资确认" elementId:58 title:self.navigationItem.title pageId:108 params:@{@"loan_id":self.loanId}];
            self.payView.payMode = MSPayModeInvest;
            [self.payView updateMoney:[NSString stringWithFormat:@"支付%@元",[NSString stringWithFormat:@"%.2f",self.tfMoney.text.doubleValue]] protocolName:nil phoneNumber:nil];
            [self.navigationController.view addSubview:self.payView];
            [self.payView pageEvent:153 title:nil];
        } else {
            [self handleErrorMessage:checkResult];
        }
    }];
    
    
    self.lbProtocol = [[YYLabel alloc] init];
    [self.scrollView addSubview:self.lbProtocol];
    self.lbProtocol.font = [UIFont systemFontOfSize:13];
    self.lbProtocol.textAlignment = NSTextAlignmentCenter;
    NSString *str = @"已阅读并同意";
    NSString *contractName = NSLocalizedString(@"str_default_contract_name", nil);
    if (loanDetail.contractName && loanDetail.contractName.length > 0) {
        contractName = loanDetail.contractName;
    }
    NSString *name = [NSString stringWithFormat:@"%@《%@》",str,contractName];
    
    NSString *pattern = @"《[A-Za-z0-9\u4e00-\u9fa5_]+》";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:name options:NSMatchingReportCompletion range:NSMakeRange(0, name.length)];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:name];
    [attribute addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"646464"]} range:NSMakeRange(0, str.length)];
    [attribute yy_setTextHighlightRange:match.range
                                  color:[UIColor ms_colorWithHexString:@"5C4E9C"]
                        backgroundColor:RGB(220,220,220)
                              tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                                  @strongify(self);
                                  [self eventWithName:@"协议按钮" elementId:57 selectedId:nil];
                                  [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:108 control:5 params:nil];
                                  MSWebViewController *vc = [MSWebViewController load];
                                  vc.title = contractName;
                                  vc.pageId = 137;
                                  vc.loanId = self.loanId;
                                  [self.navigationController pushViewController:vc animated:YES];
                              }];
    self.lbProtocol.attributedText = attribute;
    YYTextContainer  *protocolContarer = [YYTextContainer containerWithSize:CGSizeMake(self.view.width, MAXFLOAT) insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    YYTextLayout *protocolLayout = [YYTextLayout layoutWithContainer:protocolContarer text:attribute];
    self.lbProtocol.frame = CGRectMake((self.view.width - protocolLayout.textBoundingSize.width)/2.0, CGRectGetMaxY(self.btnCommit.frame)+16, protocolLayout.textBoundingSize.width, 20);
    
    self.btnProtocol = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [self.btnProtocol setBackgroundImage:[UIImage imageNamed:@"agreeSelected"] forState:UIControlStateSelected];
    [self.btnProtocol setBackgroundImage:[UIImage imageNamed:@"agreeNormal"] forState:UIControlStateNormal];
    self.btnProtocol.centerY = self.lbProtocol.centerY - 3;
    self.btnProtocol.x = self.lbProtocol.x - 20;
    self.btnProtocol.selected = YES;
    [[self.btnProtocol rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.btnProtocol.selected = !self.btnProtocol.selected;
        if (self.btnProtocol.selected && self.tfMoney.text.length > 0) {
            self.btnCommit.enabled = YES;
        }else {
            self.btnCommit.enabled = NO;
        }
    }];
    [self.scrollView addSubview:self.btnProtocol];
    
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.lbProtocol.frame));
}

- (void)handleErrorMessage:(NSInteger)error {
    NSString *errorHint = @"";
    LoanDetail *loanDetail = [[MSAppDelegate getServiceManager] getLoanInfo:self.loanId];
    if(error == ERR_AMOUNT_NOT_EQUAL) {
        errorHint = NSLocalizedString(@"hint_input_equal_availible_amount", @"");
        [MSToast show:errorHint];
    }else if (error == ERR_INPUT_EMPTY) {
        errorHint = NSLocalizedString(@"hint_input_invest_amount", nil);
        [MSToast show:errorHint];
    } else if (error == ERR_INPUT_INVALID) {
        errorHint = NSLocalizedString(@"hint_input_invalid_amount", nil);
        [MSToast show:errorHint];
    } else if (error == ERR_NOT_LOGIN) {
        [self login];
    } else if (error == ERR_BUY_FROM_SELF) {
        errorHint = NSLocalizedString(@"hint_cannot_buy_self_loan", nil);
        [MSToast show:errorHint];
    } else if (error == ERR_NOT_TIRO) {
        errorHint = NSLocalizedString(@"hint_cannot_buy_tiro_loan", nil);
        [MSToast show:errorHint];
    } else if (error == ERR_ZERO_AMOUNT) {
        errorHint = NSLocalizedString(@"hint_invest_amount_cannot_be_zero", nil);
        [MSToast show:errorHint];
    } else if (error == ERR_EXCEED_SUBJECT_AMOUNT) {
        errorHint = NSLocalizedString(@"hint_invest_amount_large_than_subject_amount", nil);
        [MSToast show:errorHint];
    } else if (error == ERR_EXCEED_MAX_LIMIT) {
        errorHint = [NSString stringWithFormat:NSLocalizedString(@"hint_exceed_invest_max_limit", nil),loanDetail.baseInfo.maxInvestLimit];
        [MSToast show:errorHint];
    } else if (error == ERR_MISMATCHED_AMOUNT) {
        NSString *format = NSLocalizedString(@"fmt_start_amount_increase_amount", nil);
        errorHint = [NSString stringWithFormat:format, loanDetail.baseInfo.startAmount, loanDetail.increaseAmount];
        [MSToast show:errorHint];
    } else if (error == ERR_NOT_AUTHENTICATED) {
        [self bindCard];
    } else if (error == ERR_NO_PAY_PASSWORD) {
        [self setTradePassword];
    }else {
        [MSLog warning:@"Unprocessed invest confirm error: %d.", error];
    }
    [self eventWithName:@"投资确认" elementId:58 title:self.navigationItem.title pageId:108 params:@{@"loan_id":self.loanId,@"error_msg":errorHint}];
}

- (void)calculationExpectMoneyWithMoney:(CGFloat)money {
    
    NSLog(@"money======%lf",money);
    NSLog(@"floormoney======%lf",floor(money*100)/100);
    NSString *expectedMoneyStr = [NSString stringWithFormat:@"%.2f",floor(money*100)/100];
    NSString *expectedMoneyTips = [NSString stringWithFormat:@"预期收益 %@ 元",expectedMoneyStr];
    NSMutableAttributedString *expectedMoneyAttStr = [[NSMutableAttributedString alloc] initWithString:expectedMoneyTips];
    [expectedMoneyAttStr addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#666666"]} range:NSMakeRange(0, expectedMoneyTips.length)];
    [expectedMoneyAttStr addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#4229B3"]} range:[expectedMoneyTips rangeOfString:expectedMoneyStr]];
    self.lbExpectedMoney.attributedText = expectedMoneyAttStr;
}

- (void)subscribe {
    
    [MSNotificationHelper addObserver:self selector:@selector(tfTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.tfMoney];
    
    @weakify(self);
    _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
    }];
    
    _assetInfoSubscription = [[RACEventHandler subscribe:[AssetInfo class]] subscribeNext:^(AssetInfo *assertInfo) {
        @strongify(self);
        self.assertInfo = assertInfo;
        self.lbAccountBalance.text = [NSString stringWithFormat:@"账户余额%@元",[NSString convertMoneyFormate:self.assertInfo.balance.doubleValue]];
    }];
}

- (void)tfTextDidChange:(NSNotification *)noti {
    if (self.accountInfo.canUseRedEnvelopeNumber > 0 && noti.object == self.tfMoney) {
        self.redEnvelope = nil;
        self.lbCardCoupons.text = @"";
    }
}

- (void)bindCard {
    MSBindCardController *vc = [[MSBindCardController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)login {
    MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
    MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)resetTradePassword {
    MSResetTradePasswordA *resetTradePassword = [[MSResetTradePasswordA alloc] init];
    [self.navigationController pushViewController:resetTradePassword animated:YES];
}

- (void)setTradePassword {
    MSSetTradePassword *vc = [[MSSetTradePassword alloc] init];
    vc.type = TRADE_PASSWORD_SET;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - query
- (void)queryNewInvestLoadId:(NSString *)loanId redBagId:(NSString *)redBagId password:(NSString *)password money:(NSString *)money{
    
    @weakify(self);
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    NSNumber *investLoadId = [format numberFromString:loanId];
    NSDecimalNumber *amount = [[NSDecimalNumber alloc] initWithString:money];
    [[[MSAppDelegate getServiceManager] investWithLoanId:investLoadId redEnvelopeId:redBagId amount:amount payPassword:password] subscribeNext:^(NSString *message) {
        @strongify(self);
        [self ms_payViewDidCancel];
        [MSNotificationHelper notify:NOTIFY_INVEST_LIST_RELOAD result:nil];
        
        NSString *moneyStr = [NSString convertMoneyFormate:self.tfMoney.text.doubleValue];
        NSString *moneyTips = [NSString stringWithFormat:@"成功投资 %@ 元",moneyStr];
        MSInvestStatusController *vc = [[MSInvestStatusController alloc] init];
        [vc updateWithType:MSInvestStatusType_success money:moneyTips message:message];
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        @strongify(self)
        MSSubmitInvest *submitInvest = (MSSubmitInvest *)error;
        if (submitInvest.result > ERR_NONE) {
            switch (submitInvest.result) {
                case MSSubmitInvestModeError:
                case MSSubmitInvestModeNoEnoughBalance:
                case MSSubmitInvestModeNoParams:
                {
                    [self ms_payViewDidCancel];
                    MSInvestStatusController *vc = [[MSInvestStatusController alloc] init];
                    [vc updateWithType:MSInvestStatusType_error money:nil message:submitInvest.message];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case MSSubmitInvestModePassWordMoreThanMax:
                {
                    [self ms_payViewDidCancel];
                    MSAlertController *alertVc = [MSAlertController alertControllerWithTitle:nil message:@"因交易密码错误多次，账号已锁定，请找回交易密码解锁" preferredStyle:UIAlertControllerStyleAlert];
                    [alertVc msSetMssageColor:[UIColor ms_colorWithHexString:@"#555555"] mssageFont:[UIFont systemFontOfSize:16.0]];
                    MSAlertAction *cancel = [MSAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                    cancel.mstextColor = [UIColor ms_colorWithHexString:@"#666666"];
                    MSAlertAction *sure = [MSAlertAction actionWithTitle:@"立即找回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self resetTradePassword];
                    }];
                    sure.mstextColor = [UIColor ms_colorWithHexString:@"#333092"];
                    [alertVc addAction:sure];
                    [alertVc addAction:cancel];
                    [self presentViewController:alertVc animated:YES completion:nil];
                    break;
                }
                case MSSubmitInvestModePassWordError:
                {
                    [MSNotificationHelper notify:NOTIFY_CHECK_TRADEPASSWORDVIEW result:nil];
                    break;
                }
                default:
                    break;
            }
        } else if (submitInvest.result < ERR_NONE) {
            [self ms_payViewDidCancel];
            [MSLog error:@"网络错误  投资失败 result: %d", submitInvest.result];
            if (submitInvest.message && submitInvest.message.length > 0) {
                [MSToast show:submitInvest.message];
            }else{
                [MSToast show:@"哎呦，网络错误！"];
            }
        }
    }];
}

#pragma mark - MSPayViewDelegate
- (void)ms_payViewDidCancel {
    [self.payView removeFromSuperview];
    self.payView = nil;
}
- (void)ms_payViewDidInputTradePassword:(NSString *)tradePassword {
    NSString *couponsId = nil;
    if (self.redEnvelope.redId && self.redEnvelope.redId.length > 0) {
        couponsId = self.redEnvelope.redId;
    }
    [self queryNewInvestLoadId:self.loanId.stringValue redBagId:couponsId password:[NSString desWithKey:tradePassword key:nil] money:[NSString stringWithFormat:@"%.2f",self.tfMoney.text.doubleValue]];
}

- (void)ms_payViewDidForgetTradePassword {
    [self ms_payViewDidCancel];
    [self resetTradePassword];
}

#pragma mark - 统计
- (void)pageEvent {
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 108;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId selectedId:(NSString *)selectedId {
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 108;
    params.title = self.navigationItem.title;
    params.elementId = eId;
    params.elementText = name;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.loanId) {
        [dic setObject:self.loanId forKey:@"loan_id"];
    }
    if (selectedId) {
        [dic setObject:selectedId forKey:@"red_money_id"];
    }
    params.params = dic;
    [MJSStatistics sendEventParams:params];
}

@end
