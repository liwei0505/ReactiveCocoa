//
//  MSPayView.h
//  Sword
//
//  Created by msj on 2016/12/22.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSPayMode) {
    MSPayModeCash,
    MSPayModeCharge,
    MSPayModeInvest,
    MSPayModeLoan,
    MSPayModeCurrentInvest,
    MSPayModeCurrentRedeem
};

@protocol MSPayViewDelegate <NSObject>
@optional
- (void)ms_payViewDidCancel;
- (void)ms_payViewDidInputTradePassword:(NSString *)tradePassword;
- (void)ms_payViewDidForgetTradePassword;
- (void)ms_payViewDidLookProtocol;
- (void)ms_payViewNeedVerificationCode;
- (void)ms_payViewDidClickConfirmButton:(NSString *)verificationCode;
@end

@interface MSPayView : UIView
@property (assign, nonatomic) MSPayMode payMode;
@property (weak, nonatomic) id<MSPayViewDelegate> delegate;
- (void)updateMoney:(NSString *)money protocolName:(NSString *)protocolName phoneNumber:(NSString *)phoneNumber;
- (instancetype)init __attribute__((unavailable("init不可用，请使用initWithFrame:")));
+ (instancetype)new __attribute__((unavailable("new不可用，请使用initWithFrame:")));
- (void)pageEvent:(int)pageId title:(NSString *)title;
@end
