//
//  MSInvestDetailController.m
//  Sword
//
//  Created by haorenjie on 16/6/12.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSInvestDetailController.h"
#import "MSAppDelegate.h"
#import "MSProjectInstructionCell.h"
#import "MSProjectInstructionController.h"
#import "MSInvestRecordCell.h"
#import "MSTextUtils.h"
#import "MSStoryboardLoader.h"
#import "MSInvestConfirmController.h"
#import "MJSStatistics.h"
#import "UIView+FrameUtil.h"
#import "MSNavigationController.h"
#import "MSShareManager.h"
#import "MSBindCardController.h"
#import "MSSetTradePassword.h"
#import "MSRefreshHeader.h"
#import "MSLoginController.h"
#import "InviteCode.h"
#import "MSInvestRecordController.h"
#import "MSInvestDetailHeaderView.h"
#import "MSLoanProgress.h"
#import "MSLoanBar.h"
#import "MSHomeFooterView.h"

@interface MSInvestDetailController() <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MSInvestDetailHeaderView *tableHeaderView;
@property (strong, nonatomic) MSHomeFooterView *tableFooterView;
@property (strong, nonatomic) MSLoanBar *loanBar;
@property (strong, nonatomic) UIButton *btnShare;

@property (strong, nonatomic) InviteCode *inviteCode;
@property (strong, nonatomic) NSMutableArray *datas;
@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) RACDisposable *accountInfoSubscription;

@property (strong, nonatomic) LoanDetail *loanDetail;
@end
@implementation MSInvestDetailController

#pragma mark - Life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureElement];
    [self subscribe];
    [self setupDatas];
    [self addSubviews];
    [self setupHeaderView];
    [self setupFooterView];
    [self setupRefreshHeader];
    [self queryInvestDetail:self.loanId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc {
    if (self.accountInfoSubscription) {
        [self.accountInfoSubscription dispose];
        self.accountInfoSubscription = nil;
    }
    NSLog(@"%s",__func__);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSProjectInstructionCell *cell = [MSProjectInstructionCell cellWithTableView:tableView];
    cell.model = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MSProjectInstructionModel *model = self.datas[indexPath.row];
    
    if (model.type != INSTRUCTION_TYPE_INVESTMENT_RECORD) {
        if (![[MSAppDelegate getServiceManager] isLogin]) {
            [self login];
            return;
        }
        
        if (self.accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
            [self bindCard];
            return;
        }
        MSProjectInstructionController *vc = [MSStoryboardLoader loadViewController:@"invest" withIdentifier:@"segue_show_project_instruction"];
        vc.loanId = self.loanId;
        vc.type = model.type;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else {
        [self eventWithName:@"投资记录" elementId:51 title:self.navigationItem.title pageId:107 params:nil];
        MSInvestRecordController *vc = [[MSInvestRecordController alloc] init];
        vc.loanId = self.loanId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [self eventWithIntroduceType:model.type];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

#pragma mark - Private
- (void)setupRefreshHeader {
    @weakify(self);
    MSRefreshHeader *header =[MSRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self queryInvestDetail:self.loanId];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)configureElement {
    self.navigationItem.title = @"项目详情";
    self.btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.btnShare.showsTouchWhenHighlighted = YES;
    self.btnShare.hidden = YES;
    [self.btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    @weakify(self);
    [[self.btnShare rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self eventWithName:@"分享" elementId:48 LoanId:self.loanId];
        self.btnShare.userInteractionEnabled = NO;
        if (self.inviteCode) {
            [self shareWithInviteCode:self.inviteCode];
            self.btnShare.userInteractionEnabled = YES;
        }else {
            [self queryShareInvestCode];
        }
        
    }];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.btnShare];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)subscribe {
    @weakify(self);
    self.accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
        
        if (self.loanDetail && self.loanDetail.loanLimit == LOAN_LIMIT_ADD_UP) {
            [self queryMyInvestedAmount:self.loanId];
        }
    }];
}

- (void)shareWithInviteCode:(InviteCode *)inviteCode {
    
    NSString *title = self.loanDetail.baseInfo.title;
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",inviteCode.codeLink,self.loanId];
    NSString *content = inviteCode.desc;
    NSString *iconUrl = inviteCode.shareUrl;
    NSString *shareId = self.loanId.stringValue;
    
    [MSShareManager sharedManager].selectedShareType = ^(NSString *title) {
        [self eventWithName:title elementId:96 LoanId:self.loanId];
    };
    
    [[MSShareManager sharedManager] ms_setShareUrl:urlStr shareTitle:title shareContent:content shareIcon:iconUrl shareId:shareId shareType:MSShareManager_share];
    
}

- (void)setupDatas {
    self.datas = [NSMutableArray array];
    MSProjectInstructionModel *risk = [MSProjectInstructionModel new];
    risk.type = INSTRUCTION_TYPE_RISK_WARNING;
    [self.datas addObject:risk];
    
    MSProjectInstructionModel *disclaimer = [MSProjectInstructionModel new];
    disclaimer.type = INSTRUCTION_TYPE_DISCLAIMER;
    [self.datas addObject:disclaimer];
    
    MSProjectInstructionModel *manual = [MSProjectInstructionModel new];
    manual.type = INSTRUCTION_TYPE_TRADING_MANUAL;
    [self.datas addObject:manual];
    
    MSProjectInstructionModel *record = [MSProjectInstructionModel new];
    record.type = INSTRUCTION_TYPE_INVESTMENT_RECORD;
    [self.datas addObject:record];
}

- (void)addSubviews {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 55, 0);
    [self.view addSubview:self.tableView];
    
    self.loanBar = [[MSLoanBar alloc] initWithFrame:CGRectMake(0, screenHeight - 64 - 55, self.view.width, 55)];
    [self.view addSubview:self.loanBar];
    @weakify(self);
    [[self.loanBar rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        NSInteger checkResult = ERR_NONE;
        checkResult = [[MSAppDelegate getServiceManager] investCheck:self.loanDetail];
        if (checkResult == ERR_NONE) {
            MSInvestConfirmController *vc = [[MSInvestConfirmController alloc] init];
            [vc updateWithLoanId:self.loanId myInvestedAmount:self.loanBar.myInvestedAmount];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSString *errorHint = @"";
            if (checkResult == ERR_NOT_LOGIN) {
                [self login];
            }else if (checkResult == ERR_NOT_AUTHENTICATED){
                [self bindCard];
            }else if (checkResult == ERR_NO_PAY_PASSWORD){
                MSSetTradePassword *vc = [[MSSetTradePassword alloc] init];
                vc.type = TRADE_PASSWORD_SET;
                [self.navigationController pushViewController:vc animated:YES];
            }else if (checkResult == ERR_NOT_TIRO){
                errorHint = NSLocalizedString(@"hint_cannot_buy_tiro_loan", nil);
                [MSToast show:errorHint];
            }
        }
    }];
}

- (void)setupHeaderView {
    @weakify(self);
    self.tableHeaderView = [[MSInvestDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 344)];
    self.tableHeaderView.countdownTimeoutBlock = ^{
        @strongify(self);
        self.loanBar.loanDetail = self.loanDetail;
        if (self.loanBar.myInvestedAmount) {
            self.loanBar.myInvestedAmount = self.loanBar.myInvestedAmount;
        }
        [self queryInvestDetail:self.loanId];
    };
    self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)setupFooterView {
    self.tableFooterView = [[MSHomeFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
    self.tableView.tableFooterView = self.tableFooterView;
}

- (void)bindCard {
    MSBindCardController *vc = [[MSBindCardController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)login {
    MSLoginController *loginVc = [MSStoryboardLoader loadViewController:@"login" withIdentifier:@"login"];
    MSNavigationController *nav = [[MSNavigationController alloc] initWithRootViewController:loginVc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - query
- (void)queryInvestDetail:(NSNumber *)loanId {
    [MSLog debug:@"%@",loanId];
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryLoanDetailById:loanId] subscribeNext:^(NSNumber *loanId) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        if ([self.loanId isEqualToNumber:loanId]) {
            self.loanDetail = [[MSAppDelegate getServiceManager] getLoanInfo:self.loanId];
            self.tableHeaderView.loanDetail = self.loanDetail;
            self.loanBar.loanDetail = self.loanDetail;
            self.btnShare.hidden = NO;
        }

        [self queryMyInvestedAmount:loanId];
        
    } error:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        RACError *result = (RACError *)error;
        self.btnShare.hidden = YES;
        if (result.result == ERR_LOGIN_KICK) {
            [MSToast show:result.message];
        }
    }];
}

- (void)queryMyInvestedAmount:(NSNumber *)loanId {
    if (self.loanBar.loanDetail.loanLimit != LOAN_LIMIT_ADD_UP) {
        return;
    }

    if (![[MSAppDelegate getServiceManager] isLogin]) {
        return;
    }

    [[[MSAppDelegate getServiceManager] queryMyInvestedAmount:loanId] subscribeNext:^(NSDecimalNumber *investedAmount) {
        self.loanBar.myInvestedAmount = investedAmount;
    } error:^(NSError *error) {
        [MSLog error:@"Query my invested amount failed, loanId = %@, error = %@", loanId, error];
    }];
}

- (void)queryShareInvestCode{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryInviteCode:SHARE_INVEST] subscribeNext:^(InviteCode *inviteCode) {
        @strongify(self);
        self.btnShare.userInteractionEnabled = YES;
        [self shareWithInviteCode:inviteCode];
        self.inviteCode = inviteCode;
    } error:^(NSError *error) {
        @strongify(self);
        self.btnShare.userInteractionEnabled = YES;
        RACError *result = (RACError *)error;
        [MSLog error:@"Query share invest code failed, result: %d", result.result];
        [MSToast show:NSLocalizedString(@"hint_share_error", @"")];
    }];
}

#pragma mark - 统计
- (void)pageEvent {
    
    NSString *title = self.loanDetail.baseInfo.title;
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 107;
    params.title = title;
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithIntroduceType:(NSInteger)type {
    
    switch (type) {
        case INSTRUCTION_TYPE_RISK_WARNING: {
            [self eventWithName:@"风险揭示" elementId:52 LoanId:self.loanId];
            break;
        }
        case INSTRUCTION_TYPE_DISCLAIMER: {
            [self eventWithName:@"免责声明" elementId:53 LoanId:self.loanId];
            break;
        }
        case INSTRUCTION_TYPE_TRADING_MANUAL: {
            [self eventWithName:@"产品说明" elementId:54 LoanId:self.loanId];
            break;
        }
    }
}

- (void)eventWithName:(NSString *)name elementId:(int)eId LoanId:(NSNumber *)loanId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 107;
    params.title = @"项目详情";
    params.elementId = eId;
    params.elementText = name;
    if (loanId) {
        NSDictionary *dic = @{@"loan_id":loanId};
        params.params = dic;
    }
    [MJSStatistics sendEventParams:params];
}
@end
