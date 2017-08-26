//
//  MSNewPointShopController.m
//  Sword
//
//  Created by msj on 2017/3/2.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNewPointShopController.h"
#import "MSRefreshHeader.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "MSNewPointProductCell.h"
#import "GoodsInfo.h"
#import "MSTextUtils.h"
#import "UIView+Toast.h"

@interface MSNewPointShopController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) MSEmptyView *emptyGoodsView;

@end

@implementation MSNewPointShopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"str_title_point_shop", @"");
    [self addSubviews];
    [self setupRefreshHeader];
    [self setupRefreshFooter];
    
    [self refreshNewData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)addSubviews{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    CGSize size = [UIScreen mainScreen].bounds.size;
    layout.itemSize = CGSizeMake((size.width - 30)/2.0, size.width/2.0 + 95);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, size.height - 64) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor ms_colorWithHexString:@"#F6F6F6"];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[MSNewPointProductCell class] forCellWithReuseIdentifier:@"MSNewPointProductCell"];

}

- (void)setupRefreshHeader{
    __weak typeof(self)weakSelf = self;
    MSRefreshHeader *header = [MSRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refreshNewData];
    }];
    self.collectionView.mj_header = header;
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)setupRefreshFooter{
    __weak typeof(self)weakSelf = self;
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf refreshMoreData];
    }];
    self.collectionView.mj_footer.hidden = YES;
}

- (void)refreshNewData{
    [self queryProductList:LIST_REQUEST_NEW];
}

- (void)refreshMoreData{
    [self queryProductList:LIST_REQUEST_MORE];
}

#pragma mark - Private
- (void)queryProductList:(ListRequestType)requestType{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryGoodsListByType:requestType] subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        [self.collectionView reloadData];
    } error:^(NSError *error) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

- (void)exchange:(GoodsInfo *)goodsInfo{
    [[[MSAppDelegate getServiceManager] exchangeByGoodsId:@(goodsInfo.goodId)] subscribeNext:^(RACError *result) {
        [MSNotificationHelper notify:NOTIFY_PRODUCT_EXCHANGE_SUCCESS result:nil];
        [[MSAppDelegate getInstance].window makeToast:result.message duration:1.25 position:CSToastPositionCenter];
    } error:^(NSError *error) {
        [[MSAppDelegate getInstance].window makeToast:NSLocalizedString(@"hint_alert_point_product_exchage_error", @"") duration:1.25 position:CSToastPositionCenter];
    }];
}

- (void)showEmptyView {
    if (!self.emptyGoodsView) {
        self.emptyGoodsView = [MSEmptyView instance];
    }
    self.emptyGoodsView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    [self.collectionView addSubview:self.emptyGoodsView];
}

- (void)hideEmptyView {
    [self.emptyGoodsView removeFromSuperview];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count = [[MSAppDelegate getServiceManager] getGoodsList].count;
    BOOL isHasMoreGoods = [[MSAppDelegate getServiceManager] hasMoreGoodsList];
    self.collectionView.mj_footer.hidden = !isHasMoreGoods;
    
    if (count > 0) {
        [self hideEmptyView];
    } else {
        [self showEmptyView];
    }
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MSNewPointProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSNewPointProductCell" forIndexPath:indexPath];
    cell.goodInfo = [[MSAppDelegate getServiceManager] getGoodsList][indexPath.item];
    @weakify(self);
    cell.exchange = ^(GoodsInfo *goodInfo){
        [MSAlert showWithTitle:nil message:NSLocalizedString(@"hint_alert_exchange", @"") buttonClickBlock:^(NSInteger buttonIndex) {
            @strongify(self);
            if (1 == buttonIndex) {
                [self exchange:goodInfo];
            }
        } cancelButtonTitle:NSLocalizedString(@"str_cancel", @"") otherButtonTitles:NSLocalizedString(@"str_confirm", @""), nil];
    };
    return cell;
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 140;
    params.title = self.title;
    [MJSStatistics sendPageParams:params];
    
}

@end
