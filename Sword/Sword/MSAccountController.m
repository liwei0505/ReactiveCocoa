//
//  MSAccountController.m
//  Sword
//
//  Created by lee on 16/5/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSAccountController.h"
#import "MSConfig.h"
#import "MSUtils.h"
#import "NSString+Ext.h"
#import "MSTextUtils.h"
#import "MSSettings.h"
#import "MSBindCardController.h"
#import "MSSetTradePassword.h"
#import "MSCommonListCell.h"
#import "MSStoryboardLoader.h"
#import "MSMyInvestController.h"
#import "MSMyAttornController.h"
#import "MSFundsFlowController.h"
#import "MSRedEnvelopeController.h"
#import "MSMyInviteController.h"
#import "MSAlertController.h"
#import "MSRefreshHeader.h"
#import "MSNewPointController.h"
#import "MSCurrentDetailController.h"
#import "MSAccountModel.h"
#import "AccountHeader.h"
#import "MSAccountCell.h"
#import "MSBalanceViewController.h"
#import "MSMyCardController.h"
#import "MSWebViewController.h"
#import "NoticeInfo.h"
#import "MSHelpViewController.h"
#import "MSMyPolicyViewController.h"

@interface MSAccountController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    RACDisposable *_accountInfoSubscription;
    RACDisposable *_assetInfoSubscription;
}

@property (strong, nonatomic) AccountInfo *accountInfo;
@property (strong, nonatomic) AssetInfo *assetInfo;
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) AccountHeader *headerView;
@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation MSAccountController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepare];
    [self subscribe];
}

- (void)subscribe {
    @weakify(self);
    _accountInfoSubscription = [[RACEventHandler subscribe:[AccountInfo class]] subscribeNext:^(AccountInfo *accountInfo) {
        @strongify(self);
        self.accountInfo = accountInfo;
        [self refreshAccountInfo];
    }];
    
    _assetInfoSubscription = [[RACEventHandler subscribe:[AssetInfo class]] subscribeNext:^(AssetInfo *assetInfo) {
        @strongify(self);
        self.assetInfo = assetInfo;
        self.headerView.assetInfo = assetInfo;
        MSAccountModel *model = self.dataArr[0][0];
        NSString *money = [NSString convertMoneyFormate:self.assetInfo.balance.doubleValue];
        model.detail = [NSString stringWithFormat:@"%@元",money];
        [self.collectionView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tabBarController.selectedIndex == 2) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    [self pageEventWithTitle:NSLocalizedString(@"str_title_account", @"") pageId:110 params:nil];
    [self refreshAccountInfo];
    
    if (!self.accountInfo) {
        [self queryAccountInfo];
    }
    if (!self.assetInfo) {
        [self queryAssetInfo];
    }
    [self queryMessageCount];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    if (self.tabBarController.selectedIndex == 2) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)dealloc
{
    [MSNotificationHelper removeObserver:self];
    if (_accountInfoSubscription) {
        [_accountInfoSubscription dispose];
        _accountInfoSubscription = nil;
    }
    if (_assetInfoSubscription) {
        [_assetInfoSubscription dispose];
        _assetInfoSubscription = nil;
    }
}

#pragma mark - UI

- (void)prepare {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    float width = self.view.bounds.size.width;
    layout.itemSize = CGSizeMake(width*0.5, 92);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, self.view.bounds.size.height-TAB_BAR_HEIGHT) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[MSAccountCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    [self.view addSubview:self.collectionView];
    
    self.headerView = [[AccountHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    
    __weak typeof(self)weakSelf = self;
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf queryAccountInfo];
        [weakSelf queryAssetInfo];
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    
}

#pragma mark - datasource and delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MSAccountModel *model = self.dataArr[indexPath.section][indexPath.row];
    if (model.actionBlock) {
        model.actionBlock();
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        [header addSubview:self.headerView];
        return header;
    } else {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        if (indexPath.section == 2) {
            float width = self.view.bounds.size.width;
            float height = 20;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            label.text = @"账户安全保障中";
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
            label.textColor = [UIColor ms_colorWithHexString:@"c5c5c5"];
            [footer addSubview:label];
            
            CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}];
            float x = (width - size.width)*0.5;
            label.frame = CGRectMake(x, 0, width-x, height);
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ms_shield"]];
            imageView.bounds = CGRectMake(0, 0, 10, 10);
            imageView.center = CGPointMake(label.frame.origin.x-15, label.center.y);
            [footer addSubview:imageView];
        } else {
            for (UIView *view in footer.subviews) {
                [view removeFromSuperview];
            }
        }
        return footer;
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *items = self.dataArr[section];
    return items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MSAccountModel *model = self.dataArr[indexPath.section][indexPath.row];
    MSAccountCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(self.view.bounds.size.width, 210);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    float width = self.view.bounds.size.width;
    if (section == 2) {
        return CGSizeMake(width, 20);
    } else {
        return CGSizeMake(width, 8);
    }
}

#pragma mark - IBAction

- (void)refreshAccountInfo {
    if (!self.accountInfo) {
        return;
    }
    
    MSAccountModel *card = self.dataArr[0][1];
    card.detail = (self.accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) ? NSLocalizedString(@"str_bind_card_failed", @"") : NSLocalizedString(@"str_bind_card_succeed", @"");
    MSAccountModel *envelop = self.dataArr[1][1];
    envelop.detail = [NSString stringWithFormat:@"有%d张红包可用",(int)self.accountInfo.canUseRedEnvelopeNumber];
    [self.collectionView reloadData];
    
}

#pragma mark - private

- (void)queryMessageCount {

    __weak typeof(self)weakSelf = self;
    [[[MSAppDelegate getServiceManager] queryUnreadMessageCount] subscribeNext:^(NSNumber *count) {
        weakSelf.headerView.messageCount = [count integerValue];
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        if (result.message) {
            [MSToast show:result.message];
        }
    }];
}

- (void)queryCurrentList {

    [[[MSAppDelegate getServiceManager] queryCurrentListByType:LIST_REQUEST_NEW isRecommended:YES] subscribeError:^(NSError *error) {
//        RACError *result = (RACError *)error;
//        if (result.message) {
//            [MSToast show:result.message];
//        } else {
//            [MSLog error:@"query current list error!"];
//        }
    } completed:^{
        [MSToast show:@"加载中"];
    }];
}

- (void)queryAboutContext {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryAbout] subscribeNext:^(NoticeInfo *noticeInfo) {
        @strongify(self);
        MSWebViewController *webController = [MSWebViewController load];
        webController.pageId = 185;
        webController.title = @"品牌实力";
        webController.url = noticeInfo.h5url;
        [self.navigationController pushViewController:webController animated:YES];
    } error:^(NSError *error) {
        
    }];
}

- (void)jumpToCurrentDetail:(NSNumber *)currentId {
    
    MSCurrentDetailController *current = [[MSCurrentDetailController alloc] init];
    current.currentID = currentId;
    [self.navigationController pushViewController:current animated:YES];
}

- (void)queryAccountInfo {
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyInfo] subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        [self refreshAccountInfo];
    } error:^(NSError *error) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        RACError *result = (RACError *)error;
        if (![MSTextUtils isEmpty:result.message]) {
            [MSToast show:result.message];
        } else {
            [MSToast show:NSLocalizedString(@"hint_alert_getaccount_error", @"")];
        }
    } completed:^{
        
    }];
}

- (void)queryAssetInfo {

    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryMyAsset] subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        self.headerView.assetInfo = self.assetInfo;
    } error:^(NSError *error) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        RACError *result = (RACError *)error;
        if ([MSTextUtils isEmpty:result.message]) {
            [MSToast show:NSLocalizedString(@"hint_alert_getaccount_error", @"")];
        } else {
            [MSToast show:result.message];
        }
    } completed:^{
        
    }];
}

- (void)gotoBindCard:(BOOL)charge {
    int index = charge ? 85 : 86;
    
    __weak typeof(self)weakSelf = self;
    [MSAlert showWithTitle:@"请先绑定银行卡" message:nil buttonClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            [self eventWithName:@"立即绑卡" elementId:index title:NSLocalizedString(@"str_title_account", @"") pageId:110 params:nil];
            MSBindCardController *vc = [[MSBindCardController alloc] init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            [self eventWithName:@"暂不绑卡" elementId:index title:NSLocalizedString(@"str_title_account", @"") pageId:110 params:nil];
        }
    } cancelButtonTitle:@"暂不绑卡" otherButtonTitles:@"立即绑卡", nil];
    
}

- (void)gotoSetTradePassword {
    __weak typeof(self)weakSelf = self;
    
    [MSAlert showWithTitle:@"请先设置交易密码" message:nil buttonClickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex) {
            MSSetTradePassword *vc = [[MSSetTradePassword alloc] init];
            vc.type = TRADE_PASSWORD_SET;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    } cancelButtonTitle:@"暂不设置" otherButtonTitles:@"立即设置", nil];
    
}

- (void)bindCard {
    [self eventWithName:@"未绑卡用户提示" elementId:73 title:NSLocalizedString(@"str_title_account", @"") pageId:110 params:nil];
    MSBindCardController *vc = [[MSBindCardController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableAttributedString *)attributedString:(NSString *)elementString lastTextIndex:(int) i {
    NSString * str  = elementString;
    NSMutableAttributedString * attr = [[NSMutableAttributedString alloc] initWithString:str];
    // 设置单位字体和颜色
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(str.length-i, i)];
    return attr;
}

#pragma mark - lazyLoad

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        
        _dataArr = [NSMutableArray array];
        @weakify(self);
        
        MSAccountModel *balance = [[MSAccountModel alloc] init];
        balance.title = @"我的余额";
        balance.iconStr = @"ms_account_balance";
        balance.actionBlock = ^{
            @strongify(self);
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:110 control:15 params:nil];
            AccountInfo *accountInfo = self.accountInfo;
            if (accountInfo.payStatus == STATUS_PAY_NOT_REGISTER) {
                [self gotoBindCard:YES];
            }else if (accountInfo.payStatus == STATUS_PAY_NO_PASSWORD){
                [self gotoSetTradePassword];
            }else {
                MSBalanceViewController *vc = [[MSBalanceViewController alloc] init];
                vc.getIntoType = MSBalanceGetIntoType_accountPage;
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
        
        MSAccountModel *card = [[MSAccountModel alloc] init];
        card.title = @"我的银行卡";
        card.iconStr = @"ms_account_mycard";
        card.actionBlock = ^{
            if (!self.accountInfo) {
                [MSToast show:@"加载中..."];
                return;
            }
            MSMyCardController *card = [[MSMyCardController alloc] init];
            card.accountInfo = self.accountInfo;
            [self.navigationController pushViewController:card animated:YES];
        };

        MSAccountModel *regular = [[MSAccountModel alloc] init];
        regular.title = NSLocalizedString(@"str_account_my_regular", @"");
        regular.detail = @"优质资产";
        regular.iconStr = @"ms_account_finance";
        regular.actionBlock = ^{
            @strongify(self);
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:110 control:9 params:nil];
            MSMyInvestController *controller = [MSStoryboardLoader loadViewController:@"account" withIdentifier:@"sid_my_invest"];
            [self.navigationController pushViewController:controller animated:YES];
        };
        
        MSAccountModel *insurance = [[MSAccountModel alloc] init];
        insurance.title = @"我的保单";
        insurance.detail = @"全方位保障";
        insurance.iconStr = @"ms_my_insurance";
        insurance.actionBlock = ^{
            @strongify(self);
            if (!self.accountInfo) {
                [MSToast show:@"加载中..."];
                return;
            }
            MSMyPolicyViewController *policy = [[MSMyPolicyViewController alloc] init];
            policy.type = MSMyPolicyViewFromType_account;
            [self.navigationController pushViewController:policy animated:YES];
          
        };
        
        [_dataArr addObject:@[balance, card, regular, insurance]];
        
        MSAccountModel *fundsflow = [[MSAccountModel alloc] init];
        fundsflow.title = NSLocalizedString(@"str_account_fundsflow", @"");
        fundsflow.detail = @"资金流水";
        fundsflow.iconStr = @"ms_account_traderecord";
        fundsflow.actionBlock = ^{
            @strongify(self);
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:110 control:11 params:nil];
            MSFundsFlowController *controller = [MSStoryboardLoader loadViewController:@"account" withIdentifier:@"sid_funds_flow"];
            [self.navigationController pushViewController:controller animated:YES];
        };
        
        MSAccountModel *envelope = [[MSAccountModel alloc] init];
        envelope.title = @"我的卡券";
        envelope.iconStr = @"ms_account_mycoupon";
        envelope.actionBlock = ^{
            @strongify(self);
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:110 control:12 params:nil];
            MSRedEnvelopeController *controller = [[MSRedEnvelopeController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        };
        
        [_dataArr addObject:@[fundsflow, envelope]];

        /*
        MSAccountModel *invite = [[MSAccountModel alloc] init];
        invite.title = @"邀请有礼";
        invite.detail = @"好友投资我赚钱";
        invite.iconStr = @"ms_account_invite";
        invite.actionBlock = ^{
            @strongify(self);
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:110 control:14 params:nil];
            MSMyInviteController *controller = [MSStoryboardLoader loadViewController:@"account" withIdentifier:@"sid_my_invite"];
            [self.navigationController pushViewController:controller animated:YES];
        };
        
        [_dataArr addObject:@[envelope, invite]];
         */
        
        MSAccountModel *feedback = [[MSAccountModel alloc] init];
        feedback.title = @"帮助反馈";
        feedback.detail = @"问题解答";
        feedback.iconStr = @"ms_account_help";
        feedback.actionBlock = ^{
            @strongify(self);
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:121 control:27 params:nil];
            MSHelpViewController *help = [[MSHelpViewController alloc] init];
            [self.navigationController pushViewController:help animated:YES];
        };
        
        MSAccountModel *security = [[MSAccountModel alloc] init];
        security.title = @"品牌实力";
        security.detail = @"民生金服品牌";
        security.iconStr = @"ms_account_brandintroduction";
        security.actionBlock = ^{
            @strongify(self);
            [MJSStatistics sendEvent:STATS_EVENT_TOUCH_UP page:121 control:26 params:nil];
            [self queryAboutContext];
        };
        
        [_dataArr addObject:@[feedback, security]];
    }
    return _dataArr;
}

@end
