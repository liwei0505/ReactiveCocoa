//
//  MSChargeBankCardView.m
//  Sword
//
//  Created by msj on 2017/6/14.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSBalanceBankCardView.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "NSString+Ext.h"


@interface MSBalanceBankCardView ()

@property (strong, nonatomic) UIImageView *bankIcon;
@property (strong, nonatomic) UIImageView *arrowIcon;
@property (strong, nonatomic) UILabel *lbBankName;
@property (strong, nonatomic) UILabel *lbLimitMoney;
@property (strong, nonatomic) UILabel *lbCashCount;

@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) BankInfo *bankInfo;
@property (strong, nonatomic) WithdrawConfig *withdrawConfig;


@end

@implementation MSBalanceBankCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.bankIcon = [[UIImageView alloc] init];
        self.bankIcon.image = [UIImage imageNamed:@"bank_icon_placeholder"];
        [self addSubview:self.bankIcon];
        
        self.lbBankName = [[UILabel alloc] init];
        self.lbBankName.textAlignment = NSTextAlignmentLeft;
        self.lbBankName.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        self.lbBankName.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.lbBankName];
        
        self.lbLimitMoney = [[UILabel alloc] init];
        self.lbLimitMoney.textAlignment = NSTextAlignmentLeft;
        self.lbLimitMoney.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbLimitMoney.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.lbLimitMoney];
        
        self.lbCashCount = [[UILabel alloc] init];
        self.lbCashCount.textAlignment = NSTextAlignmentLeft;
        self.lbCashCount.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.lbCashCount];
        self.lbCashCount.hidden = YES;
        
        self.arrowIcon = [[UIImageView alloc] init];
        self.arrowIcon.image = [UIImage imageNamed:@"ms_bank_arrow"];
        [self addSubview:self.arrowIcon];
        
        self.lbBankName.text = @"暂无数据";
        self.lbLimitMoney.text = @"单笔限额--元，单日限额--元";
        self.lbCashCount.attributedText = [[NSMutableAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
    }
    return self;
}

- (void)updateWithBankInfo:(BankInfo *)bankInfo accountInfo:(AccountInfo *)accountInfo withdrawConfig:(WithdrawConfig *)withdrawConfig {
    _bankInfo = bankInfo;
    _accountInfo = accountInfo;
    _withdrawConfig = withdrawConfig;
    
    [self.bankIcon sd_setImageWithURL:[NSURL URLWithString:self.bankInfo.bankUrl] placeholderImage:[UIImage imageNamed:@"bank_icon_placeholder"] options:SDWebImageAllowInvalidSSLCertificates];
    
    if (self.cardViewStyle == MSBalanceBankCardViewStyle_cash) {
        
        self.lbCashCount.hidden = NO;
        
        if (bankInfo) {
            if (accountInfo) {
                self.lbBankName.text = [NSString stringWithFormat:@"%@ 尾号 %@",self.bankInfo.bankName,[self.accountInfo.cardId substringFromIndex:self.accountInfo.cardId.length-4]];
            }else {
                self.lbBankName.text = [NSString stringWithFormat:@"%@ 尾号 --",self.bankInfo.bankName];
            }
        }else {
            self.lbBankName.text = @"暂无数据";
        }
        
        if (withdrawConfig) {
            
            NSString *singleLimit = [self coverStringWithMoney:withdrawConfig.maxCash.doubleValue];
            NSString *dayLimit = [self coverStringWithMoney:withdrawConfig.dayCashAmountLimit.doubleValue];
            self.lbLimitMoney.text = [NSString stringWithFormat:@"单笔%@，单日%@",singleLimit,dayLimit];
            
            NSString *str1 = [NSString stringWithFormat:@"单日可提现 %ld 次（",(long)withdrawConfig.dayCashCountLimit];
            NSString *str2 = [NSString stringWithFormat:@"今日剩余 %ld 次",(long)withdrawConfig.canCashCount];
            NSString *str3 = @"）";
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:str1 attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
            NSMutableAttributedString *att2 = [[NSMutableAttributedString alloc] initWithString:str2 attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#F3091C"]}];
            NSMutableAttributedString *att3 = [[NSMutableAttributedString alloc] initWithString:str3 attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
            [att1 appendAttributedString:att2];
            [att1 appendAttributedString:att3];
            self.lbCashCount.attributedText = att1;
            
        } else {
            
            self.lbLimitMoney.text = @"单笔限额--元，单日限额--元";
            self.lbCashCount.attributedText = [[NSMutableAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"#999999"]}];
        
        }
        
    } else {
        
        if (bankInfo) {
            if (accountInfo) {
                self.lbBankName.text = [NSString stringWithFormat:@"%@ 尾号 %@",self.bankInfo.bankName,[self.accountInfo.cardId substringFromIndex:self.accountInfo.cardId.length-4]];
            }else {
                self.lbBankName.text = [NSString stringWithFormat:@"%@ 尾号 --",self.bankInfo.bankName];
            }
            NSString *singleLimit = [self coverStringWithMoney:self.bankInfo.singleLimit];
            NSString *dayLimit = [self coverStringWithMoney:self.bankInfo.dayLimit];
            self.lbLimitMoney.text = [NSString stringWithFormat:@"单笔%@，单日%@",singleLimit,dayLimit];
        }else {
            self.lbBankName.text = @"暂无数据";
            self.lbLimitMoney.text = @"单笔限额--元，单日限额--元";
        }
        
        self.lbCashCount.hidden = YES;
    }
    [self setNeedsLayout];
}

- (NSString *)coverStringWithMoney:(double)money
{
    if (money >= 10000) {
        return [NSString stringWithFormat:@"限额 %.f 万元",money / 10000.00];
    } else if(money > 0){
        return [NSString stringWithFormat:@"限额 %.f 元",money];
    }
    return @"无限额";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bankIcon.frame = CGRectMake(16, (self.height - 48)/2.0, 48, 48);
    self.arrowIcon.frame = CGRectMake(self.width - 32, (self.height - 16)/2.0, 16, 16);
    
    if (self.cardViewStyle == MSBalanceBankCardViewStyle_cash) {
        self.lbBankName.frame = CGRectMake(CGRectGetMaxX(self.bankIcon.frame)+16, 16, self.width - (CGRectGetMaxX(self.bankIcon.frame)+32), 20);
        self.lbLimitMoney.frame = CGRectMake(CGRectGetMaxX(self.bankIcon.frame)+16, CGRectGetMaxY(self.lbBankName.frame)+2, self.width - (CGRectGetMaxX(self.bankIcon.frame)+32), 17);
        self.lbCashCount.frame = CGRectMake(CGRectGetMaxX(self.bankIcon.frame)+16, CGRectGetMaxY(self.lbLimitMoney.frame)+1, self.width - (CGRectGetMaxX(self.bankIcon.frame)+32), 17);
    } else {
        self.lbBankName.frame = CGRectMake(CGRectGetMaxX(self.bankIcon.frame)+16, 24, self.width - (CGRectGetMaxX(self.bankIcon.frame)+32), 20);
        self.lbLimitMoney.frame = CGRectMake(CGRectGetMaxX(self.bankIcon.frame)+16, CGRectGetMaxY(self.lbBankName.frame)+2, self.width - (CGRectGetMaxX(self.bankIcon.frame)+32), 17);
    }
}

@end
