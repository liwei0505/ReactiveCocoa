//
//  MSBindCardController.m
//  Sword
//
//  Created by lee on 16/12/21.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSBindCardController.h"
#import "MSItemView.h"
#import "MSSupportBankController.h"
#import "MSSetTradePassword.h"
#import "MSPayStatusController.h"
#import "MSCheckInfoUtils.h"
#import "MSCountDownView.h"
#import "MSTextUtils.h"
#import "MSTemporaryCache.h"
#import "NSMutableDictionary+nilObject.h"
#import "MSCommonButton.h"
#import "UILabel+Custom.h"

typedef NS_ENUM(NSInteger, BindCardItemTag) {

    ITEM_REALNAME = 0,
    ITEM_IDENTITY = 1,
    ITEM_BANKID = 2,
    ITEM_CARD = 3,
    ITEM_PHONENUM = 4,
    ITEM_VERIFYCODE = 5
};

@interface MSBindCardController ()<MSItemViewDelegate,UITextFieldDelegate>
{
    RACDisposable *_accountInfoSubscription;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (strong, nonatomic) MSItemView *realName;
@property (strong, nonatomic) MSItemView *identity;
@property (strong, nonatomic) MSItemView *selectBank;
@property (strong, nonatomic) MSItemView *bindCard;
@property (strong, nonatomic) MSItemView *phoneNum;
@property (strong, nonatomic) MSItemView *verifyCode;
@property (strong, nonatomic) MSCountDownView *countDownView;
@property (strong, nonatomic) MSCommonButton *completeButton;
@property (copy, nonatomic) NSString *bankId;
@property (strong, nonatomic) AccountInfo *accountInfo;
@property (nonatomic, strong) UILabel *tipB;
@property (nonatomic, assign) float scrollHeight;

@end

@implementation MSBindCardController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self getTemporaryBindBandCardInfo];

    @weakify(self);
    _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
        [self handleOldUserInfo];
    }];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.title pageId:142 params:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self saveTemporaryBindBandCardInfo];
}

- (void)dealloc{
    [MSNotificationHelper removeObserver:self];
    [self.countDownView invalidate];
    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
    NSLog(@"%s",__func__);
}

#pragma mark - UI
- (void)getTemporaryBindBandCardInfo {
    
    NSMutableDictionary *dict = [MSTemporaryCache getTemporaryBindBandCardInfo];
    if (dict) {
    
        int count = [dict[@"count"] intValue];
        NSDate *date = dict[@"date"];
        int interval = (int)ceil([[NSDate date] timeIntervalSinceDate:date]);
        int val = count - interval;
        MSCountDownViewMode mode = val > 0 ? MSCountDownViewModeCountDown : MSCountDownViewModeNormal;
        [self.countDownView startCountdownWithMode:mode temporaryCount:val];
        if (val > 0) {
            self.realName.textField.text = dict[@"realName"];
            self.identity.textField.text = dict[@"idCard"];
            NSString *bankName = dict[@"bankName"];
            if (bankName) {
                self.selectBank.textField.text = bankName;
            }
            NSString *bankId = dict[@"bankId"];
            if (bankId) {
                self.bankId = bankId;
            }
            self.bindCard.textField.text = dict[@"bindCard"];
            self.phoneNum.textField.text = dict[@"phone"];
            self.verifyCode.textField.text = dict[@"code"];
        } else {
            [MSTemporaryCache clearTemporaryBindBandCardInfo];
        }
        self.completeButton.enabled = ![self textFieldEmptyCheckout];
    }
}

- (void)saveTemporaryBindBandCardInfo {
    
    if (self.countDownView.currentMode == MSCountDownViewModeCountDown) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setNoNilObject:self.realName.textField.text forKey:@"realName"];
        [dict setNoNilObject:self.identity.textField.text forKey:@"idCard"];
        [dict setNoNilObject:self.selectBank.textField.text forKey:@"bankName"];
        [dict setNoNilObject:self.bankId forKey:@"bankId"];
        [dict setNoNilObject:self.bindCard.textField.text forKey:@"bindCard"];
        [dict setNoNilObject:self.phoneNum.textField.text forKey:@"phone"];
        [dict setNoNilObject:self.verifyCode.textField.text forKey:@"code"];
        [dict setNoNilObject:[NSDate date] forKey:@"date"];
        [dict setNoNilObject:@(self.countDownView.count) forKey:@"count"];
        [MSTemporaryCache saveTemporaryBindBandCardInfo:dict];
    }
}

- (void)prepareUI {

    self.title = NSLocalizedString(@"str_title_add_bank_card", @"");
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
    self.scrollView.alwaysBounceVertical = true;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];
    
    float space = 8;
    float width = self.view.bounds.size.width;
    float itemHeight = 6*space;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, space, width, 293)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:contentView];
    
    MSItemView *realName = [[MSItemView alloc] initWithFrame:CGRectMake(0, 0, width, itemHeight)];
    [realName itemViewIcon:nil placeholder:NSLocalizedString(@"str_input_real_name", @"")];
    realName.rightButton.hidden = YES;
    realName.delegate = self;
    realName.rightButton.tag = ITEM_REALNAME;
    realName.textField.tag = ITEM_REALNAME;
    realName.textField.delegate = self;
    self.realName = realName;
    [contentView addSubview:self.realName];
    
    UIView *lineA = [[UIView alloc] initWithFrame:CGRectMake(2*space, CGRectGetMaxY(self.realName.frame), width, 1)];
    lineA.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
    [contentView addSubview:lineA];
    
    self.identity = [[MSItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineA.frame), width, itemHeight)];
    [self.identity itemViewIcon:nil placeholder:NSLocalizedString(@"str_input_identity_card", @"")];
    self.identity.rightButton.hidden = YES;
    self.identity.delegate = self;
    self.identity.rightButton.tag = ITEM_IDENTITY;
    self.identity.textField.tag = ITEM_IDENTITY;
    self.identity.textField.keyboardType = UIKeyboardTypeASCIICapable;
    self.identity.textField.delegate = self;
    [contentView addSubview:self.identity];
    
    UIView *lineB = [[UIView alloc] initWithFrame:CGRectMake(2*space, CGRectGetMaxY(self.identity.frame), width, 1)];
    lineB.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
    [contentView addSubview:lineB];
    
    self.selectBank = [[MSItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineB.frame), width, itemHeight)];
    [self.selectBank itemViewIcon:nil placeholder:NSLocalizedString(@"hint_alert_select_bank", @"")];
    self.selectBank.delegate = self;
    self.selectBank.rightButton.hidden = YES;
    self.selectBank.textField.userInteractionEnabled = NO;
    self.selectBank.textField.tag = ITEM_BANKID;
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow"]];
    [self.selectBank addSubview:image];
    image.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectBank addConstraint:[NSLayoutConstraint constraintWithItem:image attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.selectBank attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.selectBank addConstraint:[NSLayoutConstraint constraintWithItem:image attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.selectBank attribute:NSLayoutAttributeRight multiplier:1.0 constant:-16]];
    [self.selectBank addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAvailableBank)]];
    [contentView addSubview:self.selectBank];
    
    UIView *lineE = [[UIView alloc] initWithFrame:CGRectMake(2*space, CGRectGetMaxY(self.selectBank.frame), width, 1)];
    lineE.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
    [contentView addSubview:lineE];
    
    self.bindCard = [[MSItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineE.frame), width, itemHeight)];
    [self.bindCard itemViewIcon:nil placeholder:NSLocalizedString(@"str_input_bank_card", @"")];
    self.bindCard.rightButton.hidden = YES;
    self.bindCard.delegate = self;
    self.bindCard.rightButton.tag = ITEM_CARD;
    self.bindCard.textField.tag = ITEM_CARD;
    self.bindCard.textField.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:self.bindCard];
    
    UIView *lineC = [[UIView alloc] initWithFrame:CGRectMake(2*space, CGRectGetMaxY(self.bindCard.frame), width, 1)];
    lineC.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
    [contentView addSubview:lineC];

    self.phoneNum = [[MSItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineC.frame), width, itemHeight)];
    [self.phoneNum itemViewIcon:nil placeholder:NSLocalizedString(@"str_input_reserved_phone", @"")];
    self.phoneNum.rightButton.hidden = YES;
    self.phoneNum.delegate = self;
    self.phoneNum.rightButton.tag = ITEM_PHONENUM;
    self.phoneNum.textField.tag = ITEM_PHONENUM;
    self.phoneNum.textField.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:self.phoneNum];
    
    UIView *lineD = [[UIView alloc] initWithFrame:CGRectMake(2*space, CGRectGetMaxY(self.phoneNum.frame), width, 1)];
    lineD.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
    [contentView addSubview:lineD];
    
    self.verifyCode = [[MSItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineD.frame), width, itemHeight)];
    [self.verifyCode itemViewIcon:nil placeholder:NSLocalizedString(@"hint_input_verifycode", @"")];
    self.verifyCode.rightButton.hidden = YES;
    self.verifyCode.delegate = self;
    self.verifyCode.textField.tag = ITEM_VERIFYCODE;
    self.verifyCode.textField.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:self.verifyCode];
    
    self.countDownView = [[MSCountDownView alloc] initWithFrame:CGRectMake(width-90,(48-36)*0.5, 90, 36)];
    @weakify(self);
    self.countDownView.willBeginCountdown = ^{
        @strongify(self);
        [self getVerifyCode];
    };
    [self.verifyCode addSubview:self.countDownView];
    
    float top = CGRectGetMaxY(contentView.frame)+16;
    self.completeButton = [MSCommonButton buttonWithType:UIButtonTypeCustom];
    [self.completeButton setTitle:NSLocalizedString(@"str_bind_card", @"") forState:UIControlStateNormal];
    self.completeButton.frame = CGRectMake(16, top, self.view.bounds.size.width-2*16, 64);
    [self.completeButton addTarget:self action:@selector(bindCardButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.completeButton setEnabled:NO];
    [self.scrollView addSubview:self.completeButton];
    
    float hintWidth = self.view.bounds.size.width - 32;
    
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = NSLocalizedString(@"str_prompt", @"");
    hintLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
    hintLabel.textColor = [UIColor ms_colorWithHexString:@"#999999"];
    hintLabel.frame = CGRectMake(16, CGRectGetMaxY(self.completeButton.frame)+10, hintWidth, 12);
    [self.scrollView addSubview:hintLabel];
    
    NSString *strA = @"1.为保证您的资金安全，仅支持绑定一张银行卡，且账户金额仅可提现至该银行卡";
    UILabel *tipA = [UILabel labelWithText:strA textSize:12 textColor:@"#999999"];
    CGSize tipAsize = [tipA sizeThatFits:CGSizeMake(hintWidth, MAXFLOAT)];
    tipA.frame = CGRectMake(16, CGRectGetMaxY(hintLabel.frame)+7, hintWidth, tipAsize.height);
    [self.scrollView addSubview:tipA];
    
    NSMutableAttributedString *textPart = [[NSMutableAttributedString alloc] initWithString:@"2.当账户总资产为零，且无支付中订单时支持银行卡解绑。如若有疑问，请联系客服"];
    NSDictionary *textAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor ms_colorWithHexString:@"#999999"]};
    [textPart setAttributes:textAttribute range:NSMakeRange(0, textPart.length)];
    
    NSMutableAttributedString *phonePart = [[NSMutableAttributedString alloc] initWithString:@"400-001-1111"];
    NSDictionary *phoneAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor ms_colorWithHexString:@"#333092"]};
    [phonePart setAttributes:phoneAttribute range:NSMakeRange(0, phonePart.length)];
    [textPart appendAttributedString:phonePart];
    
    UILabel *tipB = [[UILabel alloc] init];
    tipB.numberOfLines = 0;
    tipB.attributedText = textPart;
    CGSize tipBsize = [tipB sizeThatFits:CGSizeMake(hintWidth, MAXFLOAT)];
    tipB.frame = CGRectMake(16, CGRectGetMaxY(tipA.frame)+7, hintWidth, tipBsize.height);
    self.tipB = tipB;
    [self.scrollView addSubview:tipB];
    
    self.scrollHeight = CGRectGetMaxY(tipB.frame)+20;
    
    [self handleOldUserInfo];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.scrollHeight);
}

- (void)handleOldUserInfo {

    AccountInfo *accountInfo = self.accountInfo;
    if (accountInfo == nil) {
        return;
    }
    if (accountInfo.realName) {
        self.realName.textField.userInteractionEnabled = NO;
        switch (accountInfo.realName.length) {
            case 1:
                self.realName.textField.text = accountInfo.realName;
                break;
            case 2:
                self.realName.textField.text = [accountInfo.realName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"*"];
                break;
            case 3:
                self.realName.textField.text = [accountInfo.realName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"*"];
                break;
            default:
                self.realName.textField.text = [accountInfo.realName stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"**"];
                break;
        }
    }
    if (accountInfo.idcardNum) {
        self.identity.textField.userInteractionEnabled = NO;
        self.identity.textField.text = [accountInfo.idcardNum stringByReplacingCharactersInRange:NSMakeRange(4, accountInfo.idcardNum.length-7) withString:NSLocalizedString(@"str_idcard_hide", @"")];
    }
}

#pragma mark - action

- (void)showAvailableBank {
    
    [self eventWithName:@"支持的银行卡类型" elementId:108 title:self.title pageId:142 params:nil];
    MSSupportBankController *bankVC = [[MSSupportBankController alloc] init];
    __weak typeof(self)weakSelf = self;
    [bankVC seletedBankComplete:^(NSString *bank, NSString *bankId) {
        weakSelf.selectBank.textField.text = bank;
        weakSelf.bankId = bankId;
        weakSelf.completeButton.enabled = ![weakSelf textFieldEmptyCheckout];
    }];
    [self.scrollView endEditing:YES];
    [self.navigationController pushViewController:bankVC animated:YES];
}

- (void)bindCardButtonClick {
    
    NSString *realName = nil;
    NSString *idCardNum = nil;
    AccountInfo *accountInfo = self.accountInfo;
    if (accountInfo.realName) {
        
        if (![MSCheckInfoUtils realNameCheckout:accountInfo.realName]) {
            [MSToast show:NSLocalizedString(@"hint_alert_realname_error", @"")];
            [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_alert_realname_error", @"")}];
            return;
        }
        realName = accountInfo.realName;
    } else {
        if ([self.realName.textField realNameFormateError]) {
            [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_alert_realname_error", @"")}];
            return;
        }
        realName = self.realName.textField.text;
    }
    
    if (accountInfo.idcardNum) {
        if (![MSCheckInfoUtils identityCardCheckout:accountInfo.idcardNum]) {
            [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_input_identity_card_error", @"")}];
            [MSToast show:NSLocalizedString(@"hint_input_identity_card_error", @"")];
            return;
        }
        idCardNum = accountInfo.idcardNum;
    } else {
        if ([self.identity.textField idCardNumberFormateError]) {
            [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_input_identity_card_error", @"")}];
            return;
        }
        idCardNum = self.identity.textField.text;
    }
    
    if ([self.selectBank.textField.text isEqualToString:@""]) {
        [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_alert_select_bank", @"")}];
        [MSToast show:NSLocalizedString(@"hint_alert_select_bank", @"")];
    }
    
    if ([self.bankId isEqualToString:@""]) {
        [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_alert_reselect_bank", @"")}];
        [MSToast show:NSLocalizedString(@"hint_alert_reselect_bank", @"")];
    }
    
    if ([self.bindCard.textField bankCardNumberFormateError]) {
        [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_alert_bank_card_error", @"")}];
        return;
    }
    if ([self.phoneNum.textField phoneNumberFormateError]) {
        [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_alert_phonenumber_error", @"")}];
        return;
    }
    
    if ([MSCheckInfoUtils checkCode:self.verifyCode.textField.text]) {
        [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_input_correct_verifycode", @"")}];
        return;
    }
    [self.completeButton setEnabled:NO];
    
    [self bindCardRealName:realName idCard:idCardNum bankId:self.bankId bankCard:self.bindCard.textField.text phone:self.phoneNum.textField.text verifyCode:self.verifyCode.textField.text];
    
}

#pragma mark - delegate
- (void)itemViewRightButtonClick:(UIButton *)button {
    
    switch (button.tag) {
        case ITEM_REALNAME: {
            self.realName.textField.text = nil;
            self.realName.rightButton.hidden = YES;
        }
            break;
        case ITEM_IDENTITY: {
            self.identity.textField.text = nil;
            self.identity.rightButton.hidden = YES;
        }
            break;
        case ITEM_CARD: {
            self.bindCard.textField.text = nil;
            self.bindCard.rightButton.hidden = YES;
        }
            break;
        case ITEM_PHONENUM: {
            self.phoneNum.textField.text = nil;
            self.phoneNum.rightButton.hidden = YES;
        }
            break;
        case ITEM_VERIFYCODE: {
        }
            break;
        default:
            [MSLog error:@"add bink card item click error"];
            break;
    }
    self.completeButton.enabled = ![self textFieldEmptyCheckout];
    
}

- (void)itemViewTextFieldValueChanged:(MSTextField *)textField {

    switch (textField.tag) {
        case ITEM_REALNAME: {
            self.realName.rightButton.hidden = !textField.text.length;
        }
            break;
        case ITEM_IDENTITY: {
            self.identity.rightButton.hidden = !textField.text.length;
        }
            break;
        case ITEM_CARD: {
            self.bindCard.rightButton.hidden = !textField.text.length;
        }
            break;
        case ITEM_PHONENUM:
            self.phoneNum.rightButton.hidden = !textField.text.length;
            break;
        case ITEM_VERIFYCODE:
            
        default:
            break;
    }
    self.completeButton.enabled = ![self textFieldEmptyCheckout];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    if (textField.tag == ITEM_IDENTITY && range.location >= 18) {
        return NO;
    }
    
    return YES;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    return YES;
}

#pragma mark - private
- (void)bindCardRealName:(NSString *)name idCard:(NSString *)idCard bankId:(NSString *)bankId bankCard:(NSString *)card phone:(NSString *)phone verifyCode:(NSString *)code {
    @weakify(self);
    
    [[[MSAppDelegate getServiceManager] bindCardWithUserName:name idCardNumber:idCard phoneNumber:phone bankId:bankId bankCardNumber:card verifyCode:code] subscribeError:^(NSError *error) {
        @strongify(self);
        [self.completeButton setEnabled:YES];
        RACError *result = (RACError *)error;
        if (result.result == ERR_BIND_CARD_ERROR) {
            //跳到失败页 3 5跳其他不跳
            MSPayStatusController *status = [[MSPayStatusController alloc] init];
            [status updatePayStatusSubMode:MSPayStatusSubModeBindBank payStatusMode:MSPayStatusModeFail withMessage:result.message];
            status.backActionBlock = ^{
                @strongify(self);
                [self popSelf];
            };
            [self.navigationController pushViewController:status animated:YES];
            self.countDownView.currentMode = MSCountDownViewModeNormal;
            [MSTemporaryCache clearTemporaryBindBandCardInfo];
        } else {
            [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:@{@"error_msg": result.message}];
            [MSToast show:result.message];
        }
        
    } completed:^{
        @strongify(self);
        [self.completeButton setEnabled:YES];
        [self eventWithName:@"绑定银行卡" elementId:88 title:self.title pageId:142 params:nil];
        MSSetTradePassword *trade = [[MSSetTradePassword alloc] init];
        trade.type = TRADE_PASSWORD_SET;
        trade.backBlock = ^{
            @strongify(self);
            [self popSelf];
        };
        [self.navigationController pushViewController:trade animated:YES];
        self.countDownView.currentMode = MSCountDownViewModeNormal;
        [MSTemporaryCache clearTemporaryBindBandCardInfo];
    }];
    
}

- (void)getVerifyCode {
    
    if ([self.phoneNum.textField phoneNumberFormateError]) {
        self.countDownView.currentMode = MSCountDownViewModeNormal;
        [self eventWithName:@"获取验证码" elementId:87 title:self.title pageId:142 params:@{@"error_msg": NSLocalizedString(@"hint_alert_phonenumber_error", @"")}];
        
        return;
    }
    [self getVerifyCode:self.phoneNum.textField.text aim:AIM_BIND_BANK_CARD];
}

- (void)getVerifyCode:(NSString *)phoneNumber aim:(GetVerifyCodeAim)aim{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryVerifyCodeByPhoneNumber:phoneNumber aim:aim] subscribeError:^(NSError *error) {
        @strongify(self);
        self.countDownView.currentMode = MSCountDownViewModeNormal;
        RACError *result = (RACError *)error;
        NSString *errorMsg;
        if (result.message) {
            errorMsg = result.message;
        } else {
            errorMsg = NSLocalizedString(@"hint_alert_getverifycode_error", @"");
        }
        [MSToast show:errorMsg];
        [self eventWithName:@"获取验证码" elementId:87 title:self.title pageId:142 params:@{@"error_msg": errorMsg}];
    } completed:^{
        @strongify(self);
        [self eventWithName:@"获取验证码" elementId:87 title:self.title pageId:142 params:nil];
        self.countDownView.currentMode = MSCountDownViewModeCountDown;
        [MSToast show:NSLocalizedString(@"hint_verifycode_succeed", @"")];
    }];
}

- (void)popSelf {
    
    if (self.bindCardComplete) {
        self.bindCardComplete();
        return;
    }
    __block NSUInteger index;
    [self.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == self) {
            index = idx;
        }
    }];
    [self.navigationController popToViewController:self.navigationController.childViewControllers[index-1] animated:YES];
}

- (BOOL)textFieldEmptyCheckout {
    return [MSTextUtils isEmpty:self.realName.textField.text] || [MSTextUtils isEmpty:self.identity.textField.text] || [MSTextUtils isEmpty:self.bindCard.textField.text] || [MSTextUtils isEmpty:self.phoneNum.textField.text] || [MSTextUtils isEmpty:self.verifyCode.textField.text] || [MSTextUtils isEmpty:self.selectBank.textField.text];
}

@end
