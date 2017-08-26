//
//  AccountHeader.m
//  Sword
//
//  Created by lee on 2017/5/17.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "AccountHeader.h"
#import "NSString+Ext.h"
#import "MSUserInfoController.h"
#import "UIView+viewController.h"
#import "MSMessageController.h"

@interface AccountHeader()

@property (weak, nonatomic) IBOutlet UILabel *totalAsset;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *tobeReceived;
@property (weak, nonatomic) IBOutlet UIButton *btnMessage;
@property (strong, nonatomic) UILabel *lbMessage;

@end

@implementation AccountHeader

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"AccountHeader" owner:nil options:nil];
        AccountHeader *view = nibView.firstObject;
        view.frame = frame;
        self = view;
    }
    return self;
}

#pragma mark - action

- (IBAction)userInfoButtonClick:(UIButton *)sender {
    MSUserInfoController *info = [[MSUserInfoController alloc] init];
    [self.ms_viewController.navigationController pushViewController:info animated:YES];
}

- (IBAction)message:(UIButton *)sender {
    MSMessageController *message = [[MSMessageController alloc] init];
    [self.ms_viewController.navigationController pushViewController:message animated:YES];
}

- (void)setAssetInfo:(AssetInfo *)assetInfo {

    _assetInfo = assetInfo;
    [self setUpAsset];

}

- (UILabel *)lbMessage {
    if (!_lbMessage) {
        _lbMessage = [[UILabel alloc] init];
        _lbMessage.font = [UIFont systemFontOfSize:11];
        _lbMessage.backgroundColor = [UIColor redColor];
        _lbMessage.textColor = [UIColor whiteColor];
        _lbMessage.layer.masksToBounds = YES;
        _lbMessage.textAlignment = NSTextAlignmentCenter;
    }
    return _lbMessage;
}

- (void)setMessageCount:(NSInteger)messageCount {

    _messageCount = messageCount;
    
    if (messageCount == 0) {
        self.lbMessage.hidden = YES;
        return;
    }
    
    self.lbMessage.hidden = NO;
    [_btnMessage addSubview:self.lbMessage];
    
    NSString *count = [NSString stringWithFormat:@"%ld",(long)messageCount];
    CGSize size = [count sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11]}];
    
    if (messageCount >= 100) {
        self.lbMessage.frame = CGRectMake(0, 0, 28, size.height);
        self.lbMessage.text = @"99+";
        self.lbMessage.layer.cornerRadius = size.height/2.0;
    }else {
        if (messageCount < 10) {
            self.lbMessage.frame = CGRectMake(0, 0, 15, 15);
            self.lbMessage.layer.cornerRadius = 15/2.0;
        }else {
            self.lbMessage.frame = CGRectMake(0, 0, 25, size.height);
            self.lbMessage.layer.cornerRadius = size.height/2.0;
        }
        self.lbMessage.text = count;
    }
    self.lbMessage.center = CGPointMake(self.btnMessage.bounds.size.width, 0);
    
}

- (void)setUpAsset {
    
    if (self.assetInfo) {
        self.totalAsset.text = [NSString convertMoneyFormate:self.assetInfo.totalAmount.doubleValue];
        self.balance.text = [NSString convertMoneyFormate:self.assetInfo.regularAsset.tobeReceivedPrincipal.doubleValue+self.assetInfo.regularAsset.investFrozenAmount.doubleValue];
        self.tobeReceived.text = [NSString convertMoneyFormate:self.assetInfo.regularAsset.tobeReceivedInterest.doubleValue];
    }
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 110;
    params.title = @"我的账户";
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
