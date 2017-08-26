//
//  MSMyAttornController.m
//  Sword
//
//  Created by haorenjie on 16/6/24.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMyAttornController.h"
#import "MSLog.h"
#import "MSAppDelegate.h"
#import "MSNotificationHelper.h"
#import "MSMyAttornCanTransferCell.h"
#import "MSMyAttornTitleCell.h"
#import "MSMyTransferRecordCell.h"
#import "MSMyAttornBoughtCell.h"
#import "MSToast.h"
#import "MSTransferApplyController.h"
#import "MSMyAttornSectionFooterView.h"
#import "UIView+FrameUtil.h"
#import "MSRefreshHeader.h"

typedef NS_ENUM(NSInteger, AttornRecordType) {
    RECORD_TYPE_CAN_TRANSFER,
    RECORD_TYPE_TRANSFERRED,
    RECORD_TYPE_BOUGHT,
};

@interface MSMyAttornController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,  IDebtTransferDelegate, ITransferUndoDelegate>
{
    AttornRecordType _recordType;
    NSNumber *_transferDebtId;
}

@property (weak, nonatomic) IBOutlet UIButton *btnCanTransfer;
@property (weak, nonatomic) IBOutlet UIButton *btnTransferred;
@property (weak, nonatomic) IBOutlet UIButton *btnCompleted;
@property (weak, nonatomic) IBOutlet UIView *vSelected;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MSMyAttornController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self prepareUI];
    [MSNotificationHelper addObserver:self selector:@selector(onReloadMyCanTransferAttorn:) name:NOTIFY_MY_ATTORN_LIST_RELOAD];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)prepareUI {

    self.title = NSLocalizedString(@"str_account_my_debt", nil);
    _recordType = RECORD_TYPE_CAN_TRANSFER;
    
    __weak typeof(self)weakSelf = self;
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf onRefreshViewControlEventValueChanged];
    }];
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header.frame = CGRectMake(0, 0, self.view.width, 54);
    
    [self onRefreshViewControlEventValueChanged];
    
}

- (void)onRefreshViewControlEventValueChanged {
    [self queryMyAttornList:[self getCurrentCategory] requestType:LIST_REQUEST_NEW];
}

- (void)dealloc
{
    [MSNotificationHelper removeObserver:self];
    NSLog(@"%s",__func__);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sugue_transfer_apply"]) {
        MSTransferApplyController *viewController = segue.destinationViewController;
        viewController.debtId = _transferDebtId;
    }
}

#pragma mark - table view data source and delegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    MSListWrapper *myDebtList = [[MSAppDelegate getServiceManager] getMyDebtList:[self getCurrentCategory]];
    if (myDebtList.hasMore) {
        return [[MSMyAttornSectionFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
    }else{
        return nil;
    }

}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    [self queryMyAttornList:[self getCurrentCategory] requestType:LIST_REQUEST_MORE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_recordType == RECORD_TYPE_CAN_TRANSFER) {
        return 105.f;
    }

    if (indexPath.row == 0) {
        return 35.f;
    }

    if (_recordType == RECORD_TYPE_TRANSFERRED) {
        return 82.f;
    } else {
        return 70.f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MSListWrapper *attornList = [[MSAppDelegate getServiceManager] getMyDebtList:[self getCurrentCategory]];
    NSInteger count = [attornList getList].count;
    if (_recordType != RECORD_TYPE_CAN_TRANSFER) {
        count += 1; // Add the title cell.
        if (count > 1) {
            [self hideEmptyView];
        } else {
            [self showEmptyView];
        }
    }else{
        if (count > 0) {
            [self hideEmptyView];
        } else {
            [self showEmptyView];
        }
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger category = [self getCurrentCategory];
    MSListWrapper *attornList = [[MSAppDelegate getServiceManager] getMyDebtList:[self getCurrentCategory]];
    NSInteger index = indexPath.row;

    if (_recordType == RECORD_TYPE_CAN_TRANSFER) {
        MSMyAttornCanTransferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_can_transfer"];
        cell.transferDelegate = self;
        cell.attornInfo = [attornList getList][index];
        return cell;
    }

    if (indexPath.row == 0) {
        MSMyAttornTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:@"cell_title"];
        titleCell.category = category;
        return titleCell;
    }

    --index;
    if (_recordType == RECORD_TYPE_TRANSFERRED) {
        MSMyTransferRecordCell *transferCell = [tableView dequeueReusableCellWithIdentifier:@"cell_transfer"];
        transferCell.attornInfo = [attornList getList][index];
        transferCell.transferUndoDelegate = self;
        return transferCell;
    }

    MSMyAttornBoughtCell *boughtCell = [tableView dequeueReusableCellWithIdentifier:@"cell_bought"];
    boughtCell.attornInfo = [attornList getList][index];
    return boughtCell;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    [self undoDebtSell:@(actionSheet.tag)];
}

#pragma mark - actions
- (IBAction)onCanTransferButtonClicked:(id)sender
{
    _recordType = RECORD_TYPE_CAN_TRANSFER;
    [self setSelectedButton:sender];
    [self eventWithName:@"可转让" elementId:69];
}

- (IBAction)onTransferredButtonCliecked:(id)sender
{
    _recordType = RECORD_TYPE_TRANSFERRED;
    [self setSelectedButton:sender];
    [self eventWithName:@"转让记录" elementId:70];
}

- (IBAction)onTransferCompltedButtonClicked:(id)sender
{
    _recordType = RECORD_TYPE_BOUGHT;
    [self setSelectedButton:sender];
    [self eventWithName:@"认购记录" elementId:71];
}

#pragma mark - IDebtTransferDelegate
- (void)onTransferDebt:(NSNumber *)debtId
{
    _transferDebtId = debtId;
    [self performSegueWithIdentifier:@"sugue_transfer_apply" sender:self];
}

#pragma mark - ITransferUndoDelegate
- (void)onTransferUndo:(NSNumber *)debtId
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"str_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"str_undo", nil), nil];
    actionSheet.tag = debtId.integerValue;
    [actionSheet showInView:self.view];
}

#pragma mark - notifications
- (void)onReloadMyCanTransferAttorn:(NSNotification *)notification
{
    [self onRefreshViewControlEventValueChanged];
}

#pragma mark - private
- (void)queryMyAttornList:(NSInteger)status requestType:(ListRequestType)type{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyDebtListByType:type status:status] subscribeError:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [MSLog error:@"Query my attorn list failed"];
    } completed:^{
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)undoDebtSell:(NSNumber *)debtId
{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] undoDebtSoldOfId:debtId] subscribeNext:^(NSDictionary *dic) {
        @strongify(self);
        
        if (![debtId isEqualToNumber:dic[KEY_DEBT_ID]]) {
            return;
        }
        
        [self reloadAttornList];
        [MSNotificationHelper notify:NOTIFY_INVEST_LIST_RELOAD result:nil];
        [MSToast show:NSLocalizedString(@"hint_undo_success", nil)];
        
    } error:^(NSError *error) {
       [MSToast show:NSLocalizedString(@"hint_undo_failed", nil)];
    }];
}

- (void)setSelectedButton:(UIButton *)button
{
    [self showEmptyView];
    [self.tableView.mj_header endRefreshing];
    
    self.btnCanTransfer.selected = (self.btnCanTransfer == button);
    self.btnTransferred.selected = (self.btnTransferred == button);
    self.btnCompleted.selected = (self.btnCompleted == button);

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.vSelected.x = button.x;
    }];

    [self reloadAttornList];
}

- (NSInteger)getCurrentCategory
{
    if (_recordType == RECORD_TYPE_CAN_TRANSFER) {
        return STATUS_CAN_BE_TRANSFER;
    }

    if (_recordType == RECORD_TYPE_TRANSFERRED) {
        return STATUS_TRANSFERRING | STATUS_TRANSFERRED;
    }

    return STATUS_HAS_BOUGHT;
}

- (void)reloadAttornList
{
    NSInteger category = [self getCurrentCategory];
    MSListWrapper *attornList = [[MSAppDelegate getServiceManager] getMyDebtList:category];
    if (!attornList || attornList.isEmpty) {
        [self queryMyAttornList:category requestType:LIST_REQUEST_NEW];
    }
    [self.tableView reloadData];
}

- (void)showEmptyView {
    
    [super showEmptyView];
    self.emptyView.frame = CGRectMake(0, 35, self.view.frame.size.width, self.view.frame.size.height-35);
    [self.tableView addSubview:self.emptyView];
    
}

- (void)hideEmptyView {

    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 112;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 112;
    params.title = self.title;
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
