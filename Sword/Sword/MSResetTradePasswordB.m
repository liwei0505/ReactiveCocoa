//
//  MSResetTradePasswordB.m
//  Sword
//
//  Created by lee on 16/12/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSResetTradePasswordB.h"
#import "MSItemView.h"
#import "UIButton+Custom.h"
#import "MSSetTradePassword.h"
#import "MSCommonButton.h"

typedef NS_ENUM(NSInteger, ResetTradePasswordTag) {
    
    ITEM_REALNAME = 0,
    ITEM_IDENTITY = 1,
    ITEM_CARD = 2,
};

@interface MSResetTradePasswordB ()<MSItemViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MSItemView *realName;
@property (nonatomic, strong) MSItemView *identity;
@property (nonatomic, strong) MSItemView *bindCard;
@property (nonatomic, strong) MSCommonButton *completeButton;

@end

@implementation MSResetTradePasswordB

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self setUpLeftItem];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - UI

- (void)prepareUI {
    
    self.title = NSLocalizedString(@"str_title_reset_trade_password", @"");
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownResignKeyboard)]];
    
    float margin = 16;
    float width = self.view.bounds.size.width;
    float lineWidth = width-margin;
    float itemHeight = 64;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, margin*0.5, width, 194)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    MSItemView *realName = [[MSItemView alloc] initWithFrame:CGRectMake(0, 0, width, itemHeight)];
    [realName itemViewIcon:nil placeholder:NSLocalizedString(@"str_input_real_name", @"")];
    realName.rightButton.hidden = YES;
    realName.delegate = self;
    realName.rightButton.tag = ITEM_REALNAME;
    realName.textField.tag = ITEM_REALNAME;
    realName.textField.delegate = self;
    self.realName = realName;
    [contentView addSubview:self.realName];
    
    UIView *lineA = [[UIView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.realName.frame), lineWidth, 1)];
    lineA.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
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
    
    UIView *lineB = [[UIView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.identity.frame), lineWidth, 1)];
    lineB.backgroundColor = [UIColor ms_colorWithHexString:@"#F0F0F0"];
    [contentView addSubview:lineB];
    
    self.bindCard = [[MSItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineB.frame), width, itemHeight)];
    [self.bindCard itemViewIcon:nil placeholder:NSLocalizedString(@"str_input_bank_card", @"")];
    self.bindCard.rightButton.hidden = YES;
    self.bindCard.delegate = self;
    self.bindCard.rightButton.tag = ITEM_CARD;
    self.bindCard.textField.tag = ITEM_CARD;
    self.bindCard.textField.keyboardType = UIKeyboardTypeNumberPad;
    [contentView addSubview:self.bindCard];
    
    self.completeButton = [MSCommonButton buttonWithType:UIButtonTypeCustom];
    [self.completeButton setTitle:@"提交" forState:UIControlStateNormal];
    [self.completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.completeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.completeButton.frame = CGRectMake(margin, CGRectGetMaxY(contentView.frame)+margin, self.view.bounds.size.width-2*margin, itemHeight);
    [self.completeButton addTarget:self action:@selector(completeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.completeButton setEnabled:NO];
    [self.view addSubview:self.completeButton];
    
}

- (void)setUpLeftItem {
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:(@selector(pop))];
    self.navigationItem.leftBarButtonItem = left;
}

- (void)pop {
    
    __weak typeof(self)weakSelf = self;
    [MSAlert showWithTitle:@"" message:NSLocalizedString(@"hint_alert_password_set_undone", @"") buttonClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (weakSelf.backBlock) {
                weakSelf.backBlock();
            }
        }
    } cancelButtonTitle:NSLocalizedString(@"str_cancel", @"") otherButtonTitles:NSLocalizedString(@"str_confirm", @""), nil];
}

#pragma mark - action

- (void)completeButtonClick {

    if ([self.realName.textField realNameFormateError]) {
        return;
    }
    
    if ([self.identity.textField idCardNumberFormateError]) {
        return;
    }
    if ([self.bindCard.textField bankCardNumberFormateError]) {
        return;
    }
    [self.completeButton setEnabled:NO];
    [self resetTradePasswordRealName:self.realName.textField.text idCard:self.identity.textField.text bankCard:self.bindCard.textField.text];
}

- (void)touchDownResignKeyboard {
    
    [self.view endEditing:YES];
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
        default:
            [MSLog error:@""];
            break;
    }
    self.completeButton.enabled = NO;
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

#pragma mark - private
- (void)resetTradePasswordRealName:(NSString *)name idCard:(NSString *)idCard bankCard:(NSString *)card {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] verifyPayBoundUserName:name idCardNumber:idCard bankCardNumber:card] subscribeNext:^(id x) {
        @strongify(self);
        [self.completeButton setEnabled:YES];
        RACError *result = (RACError *)x;
        if (result.result == ERR_NONE) {
            MSSetTradePassword *set = [[MSSetTradePassword alloc] init];
            set.type = TRADE_PASSWORD_RESET;
            set.backBlock = ^{
                @strongify(self);
                if (self.backBlock) {
                    self.backBlock();
                }
            };
            [self.navigationController pushViewController:set animated:YES];
        } else {
            [MSToast show:result.message];
        }
    } completed:^{
        
    }];
}

- (BOOL)textFieldEmptyCheckout {
    return [self.realName.textField.text isEqualToString:@""] || [self.identity.textField.text isEqualToString:@""] || [self.bindCard.textField.text isEqualToString:@""];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 152;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
    
}

@end
