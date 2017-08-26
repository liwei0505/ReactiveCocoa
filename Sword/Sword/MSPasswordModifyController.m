//
//  MSPasswordModifyController.m
//  Sword
//
//  Created by lee on 16/7/5.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPasswordModifyController.h"
#import "MSAppDelegate.h"
#import "MSMainController.h"
#import "MSToast.h"
#import "MSTextUtils.h"
#import "UIView+FrameUtil.h"
#import "MSTextField.h"
#import "MSTextField.h"
#import "NSString+Ext.h"
#import "UIColor+StringColor.h"
#import "MSCommonButton.h"

@interface MSPasswordModifyController ()<UITextFieldDelegate>

@property (strong, nonatomic)  MSTextField *oldPasswordTextField;
@property (strong, nonatomic)  MSTextField *freshPasswordTextField;
@property (strong, nonatomic)  MSTextField *freshDupPasswordTextField;
@property (strong, nonatomic)  UIButton *clearPassWord;
@property (strong, nonatomic)  UIButton *clearNewPassWord;
@property (strong, nonatomic)  UIButton *clearConfirm;
@property (strong, nonatomic)  MSCommonButton *commitButton;

@end

@implementation MSPasswordModifyController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, self.view.width - 30, 50)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    UIImageView *topLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
    topLeftImageView.image = [UIImage imageNamed:@"lock"];
    self.clearPassWord = [[UIButton alloc] initWithFrame:CGRectMake(topView.width - 35, 15, 20, 20)];
    [self.clearPassWord setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
    [self.clearPassWord setImage:[UIImage imageNamed:@"show"] forState:UIControlStateSelected];
    self.clearPassWord.tag = 0;
    [self.clearPassWord addTarget:self action:@selector(showPassWord:) forControlEvents:UIControlEventTouchUpInside];
    self.oldPasswordTextField = [[MSTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(topLeftImageView.frame)+10, 0, topView.width - 90, 50)];
    self.oldPasswordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.oldPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(15, topView.height - 0.5, topView.width - 30, 0.5)];
    topLine.backgroundColor = [UIColor colorWithRed:220.0/256.0 green:220.0/256.0 blue:220.0/256.0 alpha:1];
    [topView addSubview:topLeftImageView];
    [topView addSubview:self.clearPassWord];
    [topView addSubview:self.oldPasswordTextField];
    [topView addSubview:topLine];
    
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(topView.frame), self.view.width - 30, 50)];
    centerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:centerView];
    UIImageView *centerLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
    centerLeftImageView.image = [UIImage imageNamed:@"lock"];
    self.clearNewPassWord = [[UIButton alloc] initWithFrame:CGRectMake(centerView.width - 35, 15, 20, 20)];
    [self.clearNewPassWord setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
    [self.clearNewPassWord setImage:[UIImage imageNamed:@"show"] forState:UIControlStateSelected];
    self.clearNewPassWord.tag = 1;
    [self.clearNewPassWord addTarget:self action:@selector(showPassWord:) forControlEvents:UIControlEventTouchUpInside];
    self.freshPasswordTextField = [[MSTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(centerLeftImageView.frame)+10, 0, centerView.width - 90, 50)];
    self.freshPasswordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.freshPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(15, centerView.height - 0.5, centerView.width - 30, 0.5)];
    centerLine.backgroundColor = [UIColor colorWithRed:220.0/256.0 green:220.0/256.0 blue:220.0/256.0 alpha:1];
    [centerView addSubview:centerLeftImageView];
    [centerView addSubview:self.clearNewPassWord];
    [centerView addSubview:self.freshPasswordTextField];
    [centerView addSubview:centerLine];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(centerView.frame), self.view.width - 30, 50)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    UIImageView *bottomLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
    bottomLeftImageView.image = [UIImage imageNamed:@"lock"];
    self.clearConfirm = [[UIButton alloc] initWithFrame:CGRectMake(bottomView.width - 35, 15, 20, 20)];
    [self.clearConfirm setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
    [self.clearConfirm setImage:[UIImage imageNamed:@"show"] forState:UIControlStateSelected];
    self.clearConfirm.tag = 2;
    [self.clearConfirm addTarget:self action:@selector(showPassWord:) forControlEvents:UIControlEventTouchUpInside];
    self.freshDupPasswordTextField = [[MSTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bottomLeftImageView.frame)+10, 0, bottomView.width - 90, 50)];
    self.freshDupPasswordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.freshDupPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [bottomView addSubview:bottomLeftImageView];
    [bottomView addSubview:self.clearConfirm];
    [bottomView addSubview:self.freshDupPasswordTextField];
    
    self.commitButton =  [[MSCommonButton alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(bottomView.frame) + 30, self.view.width - 16*2, 64)];
    [self.commitButton addTarget:self action:@selector(modifyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commitButton];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    
    [self prepareUI];
}

- (void)tap
{
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    [MSNotificationHelper removeObserver:self];
    NSLog(@"%s",__func__);
}

#pragma mark - UI
- (void)prepareUI {
    
    self.title = NSLocalizedString(@"str_title_modify_password", @"");
    self.oldPasswordTextField.placeholder = NSLocalizedString(@"hint_input_origin_password", @"");
    self.freshPasswordTextField.placeholder = NSLocalizedString(@"hint_input_new_password", @"");
    self.freshDupPasswordTextField.placeholder = NSLocalizedString(@"hint_input_confirm_password", @"");
    [self.commitButton setTitle:NSLocalizedString(@"str_complete", @"") forState:UIControlStateNormal];
    self.commitButton.enabled = NO;
    self.oldPasswordTextField.delegate = self;
    self.freshPasswordTextField.delegate = self;
    self.freshDupPasswordTextField.delegate = self;
    [self.oldPasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.freshPasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.freshDupPasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.oldPasswordTextField.secureTextEntry = YES;
    self.freshPasswordTextField.secureTextEntry = YES;
    self.freshDupPasswordTextField.secureTextEntry = YES;
    
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    switch (textField.tag) {
        case 0: {
            if (textField.text.length) {
                self.commitButton.enabled = ![self textFieldEmptyCheckout];
            } else {
                self.commitButton.enabled = NO;
            }
            break;
        }
        case 1: {
            if (textField.text.length) {
                self.commitButton.enabled = ![self textFieldEmptyCheckout];
            } else {
                self.commitButton.enabled = NO;
            }
            break;
        }
        case 2: {
            if (textField.text.length) {
                self.commitButton.enabled = ![self textFieldEmptyCheckout];
            } else {
                self.commitButton.enabled = NO;
            }
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - IBAction

- (void)modifyButtonPressed:(UIButton *)sender {

    if ([self.oldPasswordTextField passwordLengthError]) {
        return;
    }
    
    if ([self.freshPasswordTextField spacingCheckout]) {
        return;
    }
    
    if ([self.freshPasswordTextField passwordFormateError]) {
        return;
    }
    
    if (![self.freshPasswordTextField.text isEqualToString:self.freshDupPasswordTextField.text]) {
        [MSToast show:NSLocalizedString(@"hint_alert_password_diff", @"")];
        return;
    }
    
    if ([self.oldPasswordTextField.text isEqualToString:self.freshPasswordTextField.text]) {
        [MSToast show:NSLocalizedString(@"hint_alert_password_same", @"")];
        return;
    }
    
    [self modifyPassword:self.oldPasswordTextField.text newPassword:self.freshPasswordTextField.text];
    
}

- (void)showPassWord:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0: {
            self.oldPasswordTextField.enabled = NO;
            self.oldPasswordTextField.secureTextEntry = !self.oldPasswordTextField.secureTextEntry;
            self.oldPasswordTextField.enabled = YES;
            break;
        }
        case 1: {
            self.freshPasswordTextField.enabled = NO;
            self.freshPasswordTextField.secureTextEntry = !self.freshPasswordTextField.secureTextEntry;
            self.freshPasswordTextField.enabled = YES;
            break;
        }
        case 2: {
            self.freshDupPasswordTextField.enabled = NO;
            self.freshDupPasswordTextField.secureTextEntry = !self.freshDupPasswordTextField.secureTextEntry;
            self.freshDupPasswordTextField.enabled = YES;
            break;
        }
        default:
            break;
    }
    sender.selected = !sender.selected;
    
}

- (IBAction)touchDownResignKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - private
- (void)modifyPassword:(NSString *)password newPassword:(NSString *)newPassword {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] changeOrignalPassword:[NSString desWithKey:password key:nil] toPassword:[NSString desWithKey:newPassword key:nil]] subscribeError:^(NSError *error) {
        RACError *result = (RACError *)error;
        if ([MSTextUtils isEmpty:result.message]) {
            [MSToast show:NSLocalizedString(@"hint_modifypassword_error", @"")];
        } else {
            [MSToast show:result.message];
        }
    } completed:^{
        @strongify(self);
        NSArray *controllers = [[MSAppDelegate getInstance] getNavigationController].childViewControllers;
        MSMainController *main = controllers[0];
        main.selectedIndex = 0;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (BOOL)textFieldEmptyCheckout {
    
    return [self.oldPasswordTextField.text isEqualToString:@""] || [self.freshPasswordTextField.text isEqualToString:@""] || [self.freshDupPasswordTextField.text isEqualToString:@""];
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 124;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
}

@end
