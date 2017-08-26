//
//  MSAttornDetailController.m
//  Sword
//
//  Created by haorenjie on 16/6/14.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSAttornDetailController.h"
#import "MSAppDelegate.h"
#import "MJSNotifications.h"
#import "TimeUtils.h"
#import "MSAttornDetailCell.h"
#import "MSUtils.h"
#import "MSTextUtils.h"
#import "MSAttornConfirmController.h"
#import "MSStoryboardLoader.h"
#import "MJSStatistics.h"
#import "NSString+Ext.h"
#import "UIView+FrameUtil.h"
#import "MSNavigationController.h"
#import "MSBindCardController.h"
#import "MSSetTradePassword.h"
#import "MSLoginController.h"

@interface MSAttornDetailController () <UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _segmentType;
    NSArray *_debtDetailFields;
    NSArray *_loanDetailFields;
}

typedef NS_ENUM(NSInteger, AttornDetailSegmentType)
{
    SEGMENT_TYPE_DEBT_DETAIL,
    SEGMENT_TYPE_LAON_DETAIL,
};

@property (weak, nonatomic) IBOutlet UIButton *btnDebtDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnLoanDetail;
@property (weak, nonatomic) IBOutlet UIView *vSelector;

@property (weak, nonatomic) IBOutlet UIImageView *ivNovice;
@property (weak, nonatomic) IBOutlet UILabel *lbInterest;
@property (weak, nonatomic) IBOutlet UILabel *lbSubscription;
@property (weak, nonatomic) IBOutlet UILabel *lbPublishDate;
@property (weak, nonatomic) IBOutlet UILabel *lbCountdown;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation MSAttornDetailController

#pragma mark - lifecyecle
- (void)viewDidLoad {
    [super viewDidLoad];

    _segmentType = SEGMENT_TYPE_DEBT_DETAIL;
    _debtDetailFields = @[
        [NSNumber numberWithInteger:ATTORN_FIELD_EXPECTED_EARNINGS],
        [NSNumber numberWithInteger:ATTORN_FIELD_LEFT_TERM],
        [NSNumber numberWithInteger:ATTORN_FIELD_DEBT_VALUE],
        [NSNumber numberWithInteger:ATTORN_FIELD_INCOMING_WAY],
        [NSNumber numberWithInteger:ATTORN_FIELD_CEASE_DATE],
        [NSNumber numberWithInteger:ATTORN_FIELD_REPAYMENT_RECEIVE_DATE],];
    _loanDetailFields = @[
        [NSNumber numberWithInteger:ATTORN_FIELD_SCALE_OF_FINANCING],
        [NSNumber numberWithInteger:ATTORN_FIELD_INVEST_TERM],
        [NSNumber numberWithInteger:ATTORN_FIELD_REPAYMENT_WAY],
        [NSNumber numberWithInteger:ATTORN_FIELD_MIN_INVESTMENT],
        [NSNumber numberWithInteger:ATTORN_FIELD_VALUE_DATE],
        [NSNumber numberWithInteger:ATTORN_FIELD_CEASE_DATE],];

    DebtDetail *debtInfo = [[MSAppDelegate getServiceManager] getDebtInfo:self.debtId];
    self.navigationItem.title = debtInfo.baseInfo.loanInfo.baseInfo.title;

    if (debtInfo.payAmount > 0) {
        [self updateInfoPane:debtInfo];
    } else {
        [self queryAttornDetail:self.debtId];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [MSLog warning:@"didReceiveMemoryWarning"];
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_segmentType == SEGMENT_TYPE_DEBT_DETAIL) {
        return _debtDetailFields.count;
    } else if (_segmentType == SEGMENT_TYPE_LAON_DETAIL) {
        return _loanDetailFields.count;
    } else {
        [MSLog warning:@"Unexpected segment type: %d", _segmentType];
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSAttornDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell_attorn_filed"];

    DebtDetail *debtDetail = [[MSAppDelegate getServiceManager] getDebtInfo:self.debtId];
    if (_segmentType == SEGMENT_TYPE_DEBT_DETAIL) {
        cell.type = [[_debtDetailFields objectAtIndex:indexPath.row] integerValue];
    } else {
        cell.type = [[_loanDetailFields objectAtIndex:indexPath.row] integerValue];

        NSNumber *loanId = [NSNumber numberWithInt:debtDetail.baseInfo.loanInfo.baseInfo.loanId];
        LoanDetail *loanInfo = [[MSAppDelegate getServiceManager] getLoanInfo:loanId];
        if (loanInfo) {
            debtDetail.baseInfo.loanInfo = loanInfo;
        } else {
            [self queryInvestDetail:loanId];
        }
    }
    [cell updateInfo:debtDetail withIndex:indexPath.row];
    return cell;
}

#pragma mark - actions
- (IBAction)onDebtDetailButtonClicked:(id)sender
{
    _segmentType = SEGMENT_TYPE_DEBT_DETAIL;
    [self setSelectButton:sender];
}

- (IBAction)onLoanDetailButtonClicked:(id)sender
{
    _segmentType = SEGMENT_TYPE_LAON_DETAIL;
    [self setSelectButton:sender];
}

- (IBAction)onSubscribeButtonClicked:(id)sender
{
    [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:109 control:8 params:nil];
    NSInteger checkResult = [[MSAppDelegate getServiceManager] attornCheck:[[MSAppDelegate getServiceManager] getDebtInfo:self.debtId]];
    if (checkResult == ERR_NONE) {
        [self performSegueWithIdentifier:@"segue_attorn_confirm" sender:self];
    } else {
        [self handleError:checkResult];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_attorn_confirm"]) {
        MSAttornConfirmController *viewController = segue.destinationViewController;
        viewController.debtId = self.debtId;
    }
}

#pragma mark - private
- (void)setSelectButton:(UIButton *)button
{
    self.btnDebtDetail.selected = (self.btnDebtDetail == button);
    self.btnLoanDetail.selected = (self.btnLoanDetail == button);

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.vSelector.x = button.x;
    }];

    [self.tableview reloadData];
}

- (void)updateInfoPane:(DebtDetail *)debtDetail
{
    self.ivNovice.hidden = (debtDetail.baseInfo.loanInfo.baseInfo.classify != CLASSIFY_FOR_TIRO);
    
    self.lbInterest.text = [NSString stringWithFormat:@"%.2f", debtDetail.expectedRate];
    
    double amount = debtDetail.payAmount;
    NSString *amountStr = [NSString convertMoneyFormate:amount];
    self.lbSubscription.text = [NSString stringWithFormat:@"%@元",amountStr];
    
    self.lbPublishDate.text = debtDetail.releaseDate;
    [self countdown:debtDetail.deadline];
}

- (void)countdown:(NSTimeInterval)deadline
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        long interval = deadline - [TimeUtils date].timeIntervalSince1970;
        BOOL timeout = interval <= 0;
        if (interval < 0) {
            interval = 0;
        }
        NSString *timeFmt = NSLocalizedString(@"fmt_time_countdown", nil);
        weakSelf.lbCountdown.text = [MSTextUtils format:timeFmt time:interval];
        if (timeout) {
            [weakSelf onCountdownTimeout];
        } else {
            [weakSelf countdown:deadline];
        }
    });
}

- (void)onCountdownTimeout
{
    [self queryAttornDetail:self.debtId];
}

- (void)queryAttornDetail:(NSNumber *)debtId{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryDebtDetailById:debtId] subscribeNext:^(NSNumber *debtId) {
        @strongify(self); 
        DebtDetail *debtDetail = [[MSAppDelegate getServiceManager] getDebtInfo:self.debtId];
        [self updateInfoPane:debtDetail];
        if (_segmentType == SEGMENT_TYPE_DEBT_DETAIL) {
            [self.tableview reloadData];
        }
    } error:^(NSError *error) {
        
    }];
}

- (void)queryInvestDetail:(NSNumber *)loanId{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryLoanDetailById:loanId] subscribeNext:^(NSNumber *loanId) {
        @strongify(self);
        DebtDetail *debtInfo = [[MSAppDelegate getServiceManager] getDebtInfo:self.debtId];
        if (loanId.intValue != debtInfo.baseInfo.loanInfo.baseInfo.loanId) {
            return;
        }
        
        if (_segmentType == SEGMENT_TYPE_LAON_DETAIL) {
            [self.tableview reloadData];
        }
    } error:^(NSError *error) {
        
    }];
}

- (void)handleError:(NSInteger)errorCode
{
    NSString *errorHint = @"";
    switch (errorCode) {
        case ERR_NOT_LOGIN: {
            MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
            MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        } break;
        case ERR_NOT_AUTHENTICATED: {
            MSBindCardController *vc = [[MSBindCardController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case ERR_NO_PAY_PASSWORD: {
            MSSetTradePassword *vc = [[MSSetTradePassword alloc] init];
            vc.type = TRADE_PASSWORD_SET;
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case ERR_BUY_FROM_SELF: {
            errorHint = NSLocalizedString(@"hint_cannot_buy_self_loan", nil);
            [MSToast show:errorHint];
        } break;
        default: break;
    }
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 109;
    params.title = self.navigationItem.title;
    [MJSStatistics sendPageParams:params];
    
}

@end
