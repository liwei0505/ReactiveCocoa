//
//  MSTradePasswordView.m
//  showTime
//
//  Created by msj on 2016/12/21.
//  Copyright © 2016年 msj. All rights reserved.
//

#import "MSTradePasswordView.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "MSPinView.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define RGB(r,g,b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface MSTradePasswordView ()
@property (strong, nonatomic) MSPinView *pinView;
@property (strong, nonatomic) UILabel *lbMoney;
@property (strong, nonatomic) YYLabel *lbProtocol;
@property (strong, nonatomic) UIImageView *imageTips;
@property (strong, nonatomic) UILabel *lbTips;

@property (copy, nonatomic) NSString *money;
@property (copy, nonatomic) NSString *protocolName;
@end

@implementation MSTradePasswordView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
        
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, screenWidth, 18)];
        lbTitle.textColor = [UIColor ms_colorWithHexString:@"#323232"];
        lbTitle.text = @"请输入交易密码";
        lbTitle.textAlignment = NSTextAlignmentCenter;
        lbTitle.font = [UIFont systemFontOfSize:18];
        [self addSubview:lbTitle];
        
        UIImageView *cancelIcon = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - 15 - 23, 0, 23, 23)];
        cancelIcon.centerY = lbTitle.centerY;
        cancelIcon.image = [UIImage imageNamed:@"pay_cancel"];
        cancelIcon.userInteractionEnabled = YES;
        [cancelIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)]];
        [self addSubview:cancelIcon];
        
        self.lbMoney = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, screenWidth, 14)];
        self.lbMoney.textColor = [UIColor ms_colorWithHexString:@"#969696"];
        self.lbMoney.textAlignment = NSTextAlignmentCenter;
        self.lbMoney.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.lbMoney];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 68, screenWidth - 32, 0.5)];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"DADADA"];
        [self addSubview:line];
        
        CGFloat distance = 28.5;
        CGFloat pinViewX = distance;
        CGFloat pinViewW = screenWidth - distance*2;
        CGFloat pinViewH = (screenWidth - distance*2)/6.0;
        CGFloat pinViewY = 96.5;
        self.pinView = [[MSPinView alloc] initWithFrame:CGRectMake(pinViewX, pinViewY, pinViewW, pinViewH)];
        __weak typeof(self)weakSelf = self;
        self.pinView.finish = ^(NSString *password){
            if (weakSelf.finishInputTradePasswordBlock) {
                weakSelf.finishInputTradePasswordBlock(password);
            }
        };
        [self addSubview:self.pinView];
        
        self.imageTips = [[UIImageView alloc] initWithFrame:CGRectMake(distance, 76.5, 12, 12)];
        self.imageTips.image = [UIImage imageNamed:@"info_tips"];
        [self addSubview:self.imageTips];
        
        self.lbTips = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageTips.frame)+4, 0, screenWidth - (CGRectGetMaxX(self.imageTips.frame)+4), 12)];
        self.lbTips.centerY = self.imageTips.centerY;
        self.lbTips.text = @"交易密码不正确，请重新输入";
        self.lbTips.textAlignment = NSTextAlignmentLeft;
        self.lbTips.textColor = [UIColor ms_colorWithHexString:@"#ED1B23"];
        self.lbTips.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.lbTips];
        
        self.isPasswordSuccess = YES;
        
        NSString *forgetStr = @"忘记交易密码";
        NSMutableAttributedString *forgetAttribute = [[NSMutableAttributedString alloc] initWithString:forgetStr];
        @weakify(self);
        [forgetAttribute yy_setTextHighlightRange:NSMakeRange(0, forgetStr.length)
                                      color:[UIColor ms_colorWithHexString:@"#5C4E9C"]
                            backgroundColor:RGB(220,220,220)
                                  tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                                      @strongify(self);
                                      if (self.forgetPasswordBlock) {
                                          self.forgetPasswordBlock();
                                      }
                                  }];
        YYLabel *lbCancel = [[YYLabel alloc] initWithFrame:CGRectMake(screenWidth - 87 - distance, CGRectGetMaxY(self.pinView.frame)+10, 87, 20)];
        lbCancel.attributedText = forgetAttribute;
        lbCancel.font = [UIFont systemFontOfSize:13];
        lbCancel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lbCancel];
        
        self.lbProtocol = [[YYLabel alloc] initWithFrame:CGRectMake(0, 210, screenWidth, 20)];
        self.lbProtocol.numberOfLines = 0;
        self.lbProtocol.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.lbProtocol];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (void)setIsPasswordSuccess:(BOOL)isPasswordSuccess
{
    _isPasswordSuccess = isPasswordSuccess;
    self.imageTips.hidden = isPasswordSuccess;
    self.lbTips.hidden = isPasswordSuccess;
}

- (void)updateMoney:(NSString *)money protocolName:(NSString *)protocolName
{
    self.money = money;
    self.protocolName = protocolName;
}

- (void)setMoney:(NSString *)money
{
    _money = money;
    self.lbMoney.text = money;
    self.lbMoney.hidden = (money && money.length > 0) ? NO : YES;
}

- (void)setProtocolName:(NSString *)protocolName
{
    _protocolName = protocolName;
    self.lbProtocol.hidden = (protocolName && protocolName.length > 0) ? NO : YES;
    if (self.lbProtocol.hidden) {  return;  }
    
    NSString *str = @"输入密码，即表示您已阅读并同意";
    NSString *name = [NSString stringWithFormat:@"%@《%@》",str,protocolName];
    
    NSString *pattern = @"《[a-zA-Z0-9\u4e00-\u9fa5]+》";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:name options:NSMatchingReportCompletion range:NSMakeRange(0, name.length)];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:name];
    [attribute addAttributes:@{NSForegroundColorAttributeName : [UIColor ms_colorWithHexString:@"646464"]} range:NSMakeRange(0, str.length)];
    attribute.yy_alignment = NSTextAlignmentCenter;
    @weakify(self);
    [attribute yy_setTextHighlightRange:match.range
                                  color:[UIColor ms_colorWithHexString:@"5C4E9C"]
                        backgroundColor:RGB(220,220,220)
                              tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                                  @strongify(self);
                                  if (self.lookProtocolBlock) {
                                      self.lookProtocolBlock();
                                  }
                              }];
    
    self.lbProtocol.attributedText = attribute;
    YYTextContainer  *titleContarer = [YYTextContainer containerWithSize:CGSizeMake(self.width, MAXFLOAT) insets:UIEdgeInsetsMake(2, 0, 2, 0)];
    YYTextLayout *titleLayout = [YYTextLayout layoutWithContainer:titleContarer text:attribute];
    self.lbProtocol.frame = CGRectMake(0, self.height - titleLayout.textBoundingSize.height, screenWidth, titleLayout.textBoundingSize.height);
}

- (void)cancel
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)toFirstResponder
{
    [self.pinView toFirstResponder];
}
- (void)unToFirstResponder
{
    [self.pinView unToFirstResponder];
}
- (void)reset
{
    [self.pinView reset];
}

@end
