//
//  MSUserInfoController.m
//  Sword
//
//  Created by lee on 2017/6/9.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSUserInfoController.h"
#import "MSCommonListCell.h"
#import "MSMyInfoModel.h"
#import "MSCheckInfoUtils.h"
#import "MSTextUtils.h"
#import "MSPasswordManageController.h"
#import "MSBindCardController.h"
#import "MSRiskHomeViewController.h"
#import "MSRiskResultViewController.h"
#import "MSSetTradePassword.h"
#import "MSResetTradePasswordA.h"
#import "MSWebViewController.h"
#import "NoticeInfo.h"
#import "MSPasswordModifyController.h"
#import "MSUserIconViewController.h"
#import "MSVersionViewController.h"
#import "MSPhoneController.h"

@interface MSUserInfoController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cellArray;
@property (strong, nonatomic) UIButton *logout;
@property (strong, nonatomic) AccountInfo *accountInfo;
@end

@implementation MSUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    __weak typeof(self)weakSelf = self;
    [[[MSAppDelegate getServiceManager] queryMyInfo] subscribeNext:^(AccountInfo *info) {
        weakSelf.accountInfo = info;
        [weakSelf.tableView reloadData];
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        if (![MSTextUtils isEmpty:result.message]) {
            [MSToast show:result.message];
        } else {
            [MSToast show:NSLocalizedString(@"hint_alert_getaccount_error", @"")];
        }
 
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MSMyInfoModel *risk = self.cellArray[1][2];
    RiskResultInfo *userRiskInfo = [MSAppDelegate getServiceManager].riskResultInfo;
    risk.detail = userRiskInfo.title;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.title pageId:178 params:nil];
}

- (void)prepareUI {

    self.automaticallyAdjustsScrollViewInsets = YES;
    self.title = @"我的信息";
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height-64) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"EBEBF2"];
    self.tableView.rowHeight = 65;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.cellArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    MSCommonListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"common_list_cell"];
    MSMyInfoModel *model = self.cellArray[indexPath.section][indexPath.row];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MSCommonListCell" owner:nil options:nil].firstObject;
    }
    cell.model = model;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSMyInfoModel *model = self.cellArray[indexPath.section][indexPath.row];
    if (model.selectedBlock) {
        model.selectedBlock();
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 4) {
        return 16;
    }
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSMutableArray *)cellArray {

    if (!_cellArray) {
        _cellArray = [NSMutableArray array];
        
        __weak typeof(self)weakSelf = self;
        
        MSMyInfoModel *avatar = [[MSMyInfoModel alloc] init];
        avatar.title = @"我的头像";
        avatar.icon = YES;
        avatar.selectedBlock = ^{
            MSUserIconViewController *vc = [[MSUserIconViewController alloc] init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        MSMyInfoModel *name = [[MSMyInfoModel alloc] init];
        name.title = @"我的用户名";
        name.detail = [self getUserName:self.accountInfo.phoneNumber];
        name.selectedBlock = ^{
            
        };
        
        [_cellArray addObject:@[avatar, name]];
        
        MSMyInfoModel *card = [[MSMyInfoModel alloc] init];
        card.title = @"我的银行卡";
        card.detail = [self bindCardStatus:self.accountInfo.payStatus];
        card.selectedBlock = ^{
            if (weakSelf.accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
                MSBindCardController *vc = [[MSBindCardController alloc] init];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }

        };
        
        MSMyInfoModel *phone = [[MSMyInfoModel alloc] init];
        phone.title = @"绑定手机";
        phone.detail = [self getUserName:self.accountInfo.phoneNumber];
        phone.selectedBlock = ^{
            MSPhoneController *phone = [[MSPhoneController alloc] init];
            phone.phonenumber = weakSelf.accountInfo.phoneNumber;
            [weakSelf.navigationController pushViewController:phone animated:YES];
        };
        
        MSMyInfoModel *risk = [[MSMyInfoModel alloc] init];
        risk.title = @"风险测评";
        RiskResultInfo *userRiskInfo = [MSAppDelegate getServiceManager].riskResultInfo;
        risk.detail = userRiskInfo.title;
        risk.selectedBlock = ^{
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:121 control:42 params:nil];
            [weakSelf handleRiskEvaluateCellClick];
        };
        
        [_cellArray addObject:@[card, phone, risk]];
        
        MSMyInfoModel *password = [[MSMyInfoModel alloc] init];
        password.title = @"修改登录密码";
        password.selectedBlock = ^{
            [self eventWithName:@"登录密码" elementId:31 params:nil];
            MSPasswordModifyController *modify = [[MSPasswordModifyController alloc] init];
            [self.navigationController pushViewController:modify animated:YES];
        };
        
        MSMyInfoModel *loginWay = [[MSMyInfoModel alloc] init];
        loginWay.title = @"登录验证方式";
        loginWay.selectedBlock = ^{
            
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:121 control:25 params:nil];
            MSPasswordManageController *manage = [[MSPasswordManageController alloc] init];
            [weakSelf.navigationController pushViewController:manage animated:YES];
        };
        
        MSMyInfoModel *tradePassword = [[MSMyInfoModel alloc] init];
        tradePassword.title = @"修改交易密码";
        tradePassword.selectedBlock = ^{
            [weakSelf tradePasswordModify];
        };
        
        [_cellArray addObject:@[password, loginWay, tradePassword]];
        
        MSMyInfoModel *about = [[MSMyInfoModel alloc] init];
        about.title = @"关于民金所";
        about.selectedBlock = ^{
            MSVersionViewController *vc = [[MSVersionViewController alloc] init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        [_cellArray addObject:@[about]];
        
        MSMyInfoModel *logout = [[MSMyInfoModel alloc] init];
        logout.logout = YES;
        logout.selectedBlock = ^{
            [weakSelf userLogout];
        };
        
        [_cellArray addObject:@[logout]];
        
    }
    return _cellArray;
}

- (void)userLogout {
    
    [[MSAppDelegate getServiceManager] logout];
    [self setTabbarControllerIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (NSString *)bindCardStatus:(PayStatus)status {
    
    if (status == STATUS_PAY_NOT_REGISTER) {
        return NSLocalizedString(@"str_bind_card_failed", @"");
    }
    return NSLocalizedString(@"str_bind_card_succeed", @"");

}

- (NSString *)getUserName:(NSString *)phone {
    if ([MSCheckInfoUtils phoneNumCheckout:phone]) {
        return [phone stringByReplacingCharactersInRange:NSMakeRange(3,4) withString:@"****"];
    }
    return phone;
}

- (void)handleRiskEvaluateCellClick {
    
    RiskResultInfo *userRiskInfo = [MSAppDelegate getServiceManager].riskResultInfo;
    if (userRiskInfo.type == EVALUATE_NOT) {
        MSRiskHomeViewController *riskHomeViewController = [[MSRiskHomeViewController alloc] init];
        [self.navigationController pushViewController:riskHomeViewController animated:YES];
    } else {
        MSRiskResultViewController *resultViewController = [[MSRiskResultViewController alloc] init];
        resultViewController.resultInfo = userRiskInfo;
        [self.navigationController pushViewController:resultViewController animated:YES];
    }
    return;
    
}

- (void)tradePasswordModify {
    
    PayStatus status = self.accountInfo.payStatus;
    if (status == STATUS_PAY_NOT_REGISTER) {//未绑卡
        
        [MSAlert showWithTitle:@"请先绑定银行卡" message:nil buttonClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                MSBindCardController *vc = [[MSBindCardController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        } cancelButtonTitle:@"暂不绑卡" otherButtonTitles:@"立即绑卡", nil];
        
    } else {
        
        switch (status) {
            case STATUS_PAY_NO_PASSWORD: {
                MSSetTradePassword *set = [[MSSetTradePassword alloc] init];
                set.type = TRADE_PASSWORD_SET;
                set.backBlock = ^ {
                };
                [self.navigationController pushViewController:set animated:YES];
            }
                break;
            case STATUS_PAY_PASSWORD_SET: {
                MSResetTradePasswordA *resetTradePassword = [[MSResetTradePasswordA alloc] init];
                [self.navigationController pushViewController:resetTradePassword animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

- (NSString *)tradeStatusText:(PayStatus)status {
    switch (status) {
        case STATUS_PAY_NOT_REGISTER:
            return NSLocalizedString(@"str_set", @"");
        case STATUS_PAY_NO_PASSWORD:
            return NSLocalizedString(@"str_set", @"");
        case STATUS_PAY_PASSWORD_SET:
            return NSLocalizedString(@"str_reset", @"");
        default:
            return @"";
    }
}

- (void)eventWithName:(NSString *)name elementId:(int)eId params:(NSString *)type {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 123;
    params.title = self.title;
    params.elementId = eId;
    params.elementText = name;
    if (type) {
        NSDictionary *dic = @{@"alter_type":type};
        params.params = dic;
    }
    [MJSStatistics sendEventParams:params];
}

@end
