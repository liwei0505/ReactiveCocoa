//
//  MSRiskTopicViewController.m
//  Sword
//
//  Created by msj on 2016/12/15.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSRiskTopicViewController.h"
#import "MSRiskResultViewController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "UIImage+color.h"
#import "UIImageView+WebCache.h"
#import "MSAppDelegate.h"
#import "MSRiskCollectionView.h"
#import "MSRiskCollectionViewCell.h"
#import "MSAlertController.h"
#import "MSUserInfoController.h"

@interface MSRiskTopicViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) MSRiskCollectionView *collection;
@property (strong, nonatomic,readwrite) NSMutableArray *dataArr;
@end

@implementation MSRiskTopicViewController

#pragma mark - Life Style
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCollectionView];
    [self addBackItem];
    [self configPageStateView];
    [self configureElement];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEvent];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5;
    self.navigationItem.title = [NSString stringWithFormat:@"风险测评(%d / %lu)",index+1,(unsigned long)self.dataArr.count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    RiskInfo *info = self.dataArr[index];
    if (info.isCompeleted) {
    }else{
        for (int i = 0; i < self.dataArr.count; i++) {
            RiskInfo *info = self.dataArr[i];
            if (!info.isCompeleted) {
                [self.collection setContentOffset:CGPointMake(i * [UIScreen mainScreen].bounds.size.width, 0) animated:YES];
                return;
            }
        }
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSRiskCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSRiskCollectionViewCell" forIndexPath:indexPath];
    [cell update:self.dataArr[indexPath.item] index:indexPath.item riskInfoArr:self.dataArr];
    __weak typeof(self)weakSelf = self;
    cell.selectedCallBlcok = ^(NSInteger index){
        if (weakSelf.collection.isDecelerating) {
            return ;
        }
        if (index < weakSelf.dataArr.count - 1) {
            [weakSelf.collection setContentOffset:CGPointMake(weakSelf.collection.contentOffset.x + [UIScreen mainScreen].bounds.size.width, 0) animated:YES];
        }
        
    };
    cell.compeleted = ^{
        NSMutableArray *arr = [NSMutableArray array];
        for (RiskInfo *info in weakSelf.dataArr) {
            NSDictionary *dic = @{@"answerId" : info.answerId, @"questionId" : info.questionId};
            [arr addObject:dic];
        }
        [weakSelf commitRiskAssessment:arr];
    };
    return cell;
}

#pragma mark - Private
- (void)configureElement {
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#EEEEEE"];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    NSMutableArray *arr = [MSAppDelegate getServiceManager].topics;
    if (arr && arr.count > 0) {
        for (RiskInfo *info in arr) {
            info.isCompeleted = NO;
            info.answerId = nil;
            for (RiskDetailInfo *detailInfo in info.riskDetailInfoArr) {
                detailInfo.isSelected = NO;
            }
        }
        self.dataArr = arr;
        self.navigationItem.title = [NSString stringWithFormat:@"风险测评(1 / %d)",(int)self.dataArr.count];
    }else{
        self.dataArr = nil;
    }
}

- (void)setDataArr:(NSMutableArray *)dataArr
{
    _dataArr = dataArr;
    if (dataArr) {
        self.pageStateView.state = MSPageStateMachineType_loaded;
        [self.collection reloadData];
        [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }else{
        self.pageStateView.state = MSPageStateMachineType_loading;
        [self queryRiskAssessment];
    }
}

- (void)configPageStateView {
    @weakify(self);
    self.pageStateView.refreshBlock = ^{
        @strongify(self);
        [self queryRiskAssessment];
    };
    [self.pageStateView showInView:self.view];
}

- (void)addCollectionView
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(frame.size.width, frame.size.height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collection = [[MSRiskCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.collection.delegate = self;
    self.collection.dataSource = self;
    self.collection.showsVerticalScrollIndicator = NO;
    self.collection.showsHorizontalScrollIndicator = NO;
    self.collection.bounces = NO;
    self.collection.backgroundColor = [UIColor whiteColor];
    self.collection.pagingEnabled = YES;
    
    [self.collection registerClass:[MSRiskCollectionViewCell class] forCellWithReuseIdentifier:@"MSRiskCollectionViewCell"];
    [self.view addSubview:self.collection];
}

- (void)addBackItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"risk_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonOnClick)];
}

- (void)backButtonOnClick
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    __weak typeof(self)weakSelf = self;
    MSAlertController *vc = [MSAlertController alertControllerWithTitle:@"提示" message:@"本次风险偏好测试还未完成，退出后将不保存当前进度，确定退出吗?" preferredStyle:UIAlertControllerStyleAlert];
    [vc msSetMssageColor:[UIColor ms_colorWithHexString:@"#000000"] mssageFont:[UIFont systemFontOfSize:14.0]];
    [vc msSetTitleColor:[UIColor ms_colorWithHexString:@"#000000"] titleFont:[UIFont boldSystemFontOfSize:17.0]];
    MSAlertAction *sure = [MSAlertAction actionWithTitle:@"继续测评" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self eventWithName:@"继续评测" elementId:107];
    }];
    sure.mstextColor = [UIColor ms_colorWithHexString:@"#2C90FD"];
    MSAlertAction *cancel = [MSAlertAction actionWithTitle:@"立即退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self eventWithName:@"立即退出" elementId:107];
        [MSAppDelegate getServiceManager].topics = nil;
        [weakSelf pop];
    }];
    sure.mstextColor = [UIColor ms_colorWithHexString:@"#007AFF"];
    [vc addAction:sure];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)pop {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[MSUserInfoController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return ;
        }
    }
}

- (void)queryRiskAssessment{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] queryRiskAssessment] subscribeNext:^(NSMutableArray *questionList) {
        @strongify(self);
        self.dataArr = questionList;
        [MSAppDelegate getServiceManager].topics = questionList;
        self.navigationItem.title = [NSString stringWithFormat:@"风险测评(1 / %d)",(int)self.dataArr.count];
        self.pageStateView.state = MSPageStateMachineType_loaded;
    } error:^(NSError *error) {
        @strongify(self);
        self.pageStateView.state = MSPageStateMachineType_error;
    }];
    
}

- (void)commitRiskAssessment:(NSArray *)commitList{
    @weakify(self);
    [[[MSAppDelegate getServiceManager] commitRiskAssessmentWithAnswers:commitList] subscribeNext:^(RiskResultInfo *userRiskInfo) {
        @strongify(self);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"type"] = [NSString stringWithFormat:@"%ld",(long)userRiskInfo.type];
        dic[@"typeName"] = userRiskInfo.title;
        [MSNotificationHelper notify:NOTIFY_RISK_COMPLETION result:nil userInfo:dic];
        
        MSRiskResultViewController *resultViewController = [[MSRiskResultViewController alloc] init];
        resultViewController.resultInfo = userRiskInfo;
        [self.navigationController pushViewController:resultViewController animated:YES];
        
    } error:^(NSError *error) {
        RACError *result = (RACError *)error;
        [MSToast show:result.message];
    } ];
    
}

- (void)pageEvent {
    
    MSPageParams *params = [[MSPageParams alloc] init];
    params.pageId = 144;
    params.title = @"风险测评";
    [MJSStatistics sendPageParams:params];
    
}

- (void)eventWithName:(NSString *)name elementId:(int)eId {
    
    MSEventParams *params = [[MSEventParams alloc] init];
    params.pageId = 144;
    params.title = @"风险测评";
    params.elementId = eId;
    params.elementText = name;
    [MJSStatistics sendEventParams:params];
}

@end
