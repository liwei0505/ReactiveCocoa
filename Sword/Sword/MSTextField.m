//
//  MSPasswordTextField.m
//  Sword
//
//  Created by lee on 16/9/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSTextField.h"
#import "MSCheckInfoUtils.h"
#import "MSToast.h"

@implementation MSTextField

+ (instancetype)ms_createWithPlaceholder:(NSString *)holder {
    
    MSTextField *textField = [[MSTextField alloc] init];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:holder];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, holder.length)];
    textField.attributedPlaceholder = attr;
    textField.borderStyle = UITextBorderStyleNone;
    textField.textColor = [UIColor ms_colorWithHexString:@"666666" withAlpha:1.0];
    return textField;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect rect = [super placeholderRectForBounds:bounds];
    rect.origin.y += 3;
    return rect;
}

#pragma mark - private

- (BOOL)spacingCheckout {

    if([MSCheckInfoUtils spacingCheckout:self.text]) {
        [MSToast show:NSLocalizedString(@"hint_password_has_spacing", @"")];
        [self resignFirstResponder];
        return true;
    }
    return false;
}

- (BOOL)passwordFormateError {

    if ([MSCheckInfoUtils passwordCheckout:self.text]) {
        return false;
    } else {
        [MSToast show:NSLocalizedString(@"hint_alert_password_error", @"")];
        return true;
    }
}

- (BOOL)phoneNumberFormateError {

    if ([MSCheckInfoUtils phoneNumCheckout:self.text]) {
        return false;
    } else {
        [MSToast show:NSLocalizedString(@"hint_alert_phonenumber_error", @"")];
        return true;
    }
}

- (BOOL)passwordLengthError {

    NSUInteger length = self.text.length;
    if (length < 6 || length > 16) {
        [MSToast show:NSLocalizedString(@"hint_alert_password_error", @"")];
        return true;
    }
    return false;
}

- (BOOL)verifyCodeFormateError {

    if (self.text.length != 6) {
        [MSToast show:NSLocalizedString(@"hint_input_correct_verifycode", @"")];
        return true;
    }
    return false;
}

- (BOOL)tradePasswordError {

    if (self.text.length != 6) {
        [MSToast show:NSLocalizedString(@"hint_alert_correct_trade_password", @"")];
        return true;
    }
    
    if ([MSCheckInfoUtils tradePasswordCheckout:self.text]) {
        [MSToast show:NSLocalizedString(@"hint_alert_trade_password_simple", @"")];
        return true;
    }
    return false;
}

- (BOOL)idCardNumberFormateError {

    if ([MSCheckInfoUtils identityCardCheckout:self.text]) {
        return false;
    } else {
        [MSToast show:NSLocalizedString(@"hint_input_identity_card_error", @"")];
        return true;
    }
}

- (BOOL)bankCardNumberFormateError {
    if ([MSCheckInfoUtils bankCardNumberCheckout:self.text]) {
        return false;
    } else {
        [MSToast show:NSLocalizedString(@"hint_alert_bank_card_error", @"")];
        return true;
    }
}

- (BOOL)realNameFormateError {
    if ([MSCheckInfoUtils realNameCheckout:self.text]) {
        return false;
    } else {
        [MSToast show:NSLocalizedString(@"hint_alert_realname_error", @"")];
        return true;
    }
}

@end
