//
//  MSCurrentDetailHeaderView.m
//  Sword
//
//  Created by msj on 2017/4/5.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentDetailHeaderView.h"
#import "UIView+viewController.h"
#import "MSCurrentIncomeDetail.h"
#import "MSTrendChartView.h"
#import "UIView+FrameUtil.h"
#import "NSDate+Add.h"

#pragma mark - MSNoInvestCurrentHeaderView
@interface MSNoInvestCurrentHeaderView : UIView
@property (strong, nonatomic) CurrentDetail *currentDetail;
@end
@interface MSNoInvestCurrentHeaderView ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UILabel *lbInterest;
@property (strong, nonatomic) UILabel *lbEarningsPer10000;
@property (strong, nonatomic) UILabel *lbTermUnit;
@property (strong, nonatomic) UILabel *lbStartAmount;
@end
@implementation MSNoInvestCurrentHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lbTitle = [UILabel newAutoLayoutView];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#6D6AD2"];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        self.lbTitle.font = [UIFont systemFontOfSize:12];
        self.lbTitle.text = @"---";
        [self addSubview:self.lbTitle];
        [self.lbTitle autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 0, 0, 0) excludingEdge:ALEdgeBottom];
        [self.lbTitle autoSetDimension:ALDimensionHeight toSize:13];
        
        self.lbInterest = [UILabel newAutoLayoutView];
        self.lbInterest.textColor = [UIColor ms_colorWithHexString:@"#FFFFFF"];
        self.lbInterest.textAlignment = NSTextAlignmentCenter;
        self.lbInterest.text = @"--";
        [self addSubview:self.lbInterest];
        [self.lbInterest autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbInterest autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbInterest autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTitle withOffset:7];
        [self.lbInterest autoSetDimension:ALDimensionHeight toSize:36];
        
        self.lbEarningsPer10000 = [UILabel newAutoLayoutView];
        self.lbEarningsPer10000.textColor = [UIColor ms_colorWithHexString:@"#FFFFFF"];
        self.lbEarningsPer10000.textAlignment = NSTextAlignmentCenter;
        self.lbEarningsPer10000.text = @"每日万元收益：--元";
        [self addSubview:self.lbEarningsPer10000];
        [self.lbEarningsPer10000 autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbEarningsPer10000 autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbEarningsPer10000 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbInterest withOffset:8];
        [self.lbEarningsPer10000 autoSetDimension:ALDimensionHeight toSize:14];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#6D6AD2"];
        [self addSubview:line];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbEarningsPer10000 withOffset:16];
        [line autoSetDimension:ALDimensionHeight toSize:0.5];
        
        CGFloat height = 47;
        CGFloat width = self.width / 2.0;
        self.lbTermUnit = [UILabel newAutoLayoutView];
        self.lbTermUnit.textColor = [UIColor ms_colorWithHexString:@"#FFFFFF"];
        self.lbTermUnit.textAlignment = NSTextAlignmentCenter;
        self.lbTermUnit.font = [UIFont systemFontOfSize:16];
        self.lbTermUnit.text = @"---";
        [self addSubview:self.lbTermUnit];
        [self.lbTermUnit autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbTermUnit autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
        [self.lbTermUnit autoSetDimensionsToSize:CGSizeMake(width, height)];
        
        self.lbStartAmount = [UILabel newAutoLayoutView];
        self.lbStartAmount.textColor = [UIColor ms_colorWithHexString:@"#FFFFFF"];
        self.lbStartAmount.textAlignment = NSTextAlignmentCenter;
        self.lbStartAmount.font = [UIFont systemFontOfSize:16];
        self.lbStartAmount.text = @"--元起投";
        [self addSubview:self.lbStartAmount];
        [self.lbStartAmount autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbStartAmount autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
        [self.lbStartAmount autoSetDimensionsToSize:CGSizeMake(width, height)];
        
    }
    return self;
}

- (void)setCurrentDetail:(CurrentDetail *)currentDetail {
    _currentDetail = currentDetail;
    self.lbTitle.text = currentDetail.baseInfo.interestRateDescription;
    
    NSString *interestRate = [NSString stringWithFormat:@"%.2f%%",currentDetail.baseInfo.interestRate.doubleValue * 100];
    NSMutableAttributedString *interestRateAtt = [[NSMutableAttributedString alloc] initWithString:interestRate];
    [interestRateAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:36]} range:NSMakeRange(0, interestRate.length - 1)];
    [interestRateAtt addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} range:NSMakeRange(interestRate.length - 1, 1)];
    self.lbInterest.attributedText = interestRateAtt;

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingMode = kCFNumberFormatterRoundDown;
    formatter.minimumIntegerDigits = 1;
    formatter.maximumFractionDigits = 4;
    NSString *earningsPer10000 = [formatter stringFromNumber:currentDetail.earningsPer10000];
    self.lbEarningsPer10000.text = [NSString stringWithFormat:@"每日万元收益：%@元", earningsPer10000];
    self.lbTermUnit.text = currentDetail.baseInfo.termUnit;
    self.lbStartAmount.text = [NSString stringWithFormat:@"%.2f元起投",currentDetail.baseInfo.startAmount.doubleValue];
}
@end

#pragma mark - MSHasInvestCurrentHeaderView
@interface MSHasInvestCurrentHeaderView : UIView
@property (strong, nonatomic) AssetInfo *assetInfo;
@end
@interface MSHasInvestCurrentHeaderView ()
@property (strong, nonatomic) UILabel *lbYesterdayEarnings;
@property (strong, nonatomic) UILabel *lbHistoryAddUpAmount;
@property (strong, nonatomic) UILabel *lbTotalAmount;
@property (strong, nonatomic) UILabel *lbRedeemFrozonAmountAmount;
@property (strong, nonatomic) UILabel *lbInvestAmount;
@property (strong, nonatomic) UILabel *lbPurchaseFrozenAmount;
@property (strong, nonatomic) UILabel *lbAddUpAmount;

@property (strong, nonatomic) UIButton *btnEye;
@end
@implementation MSHasInvestCurrentHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *topView = [UIView newAutoLayoutView];
        topView.backgroundColor = [UIColor ms_colorWithHexString:@"#333092"];
        [self addSubview:topView];
        [topView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
        [topView autoSetDimension:ALDimensionHeight toSize:219];
        
        UILabel *lbYesterdayEarningsTips = [UILabel newAutoLayoutView];
        lbYesterdayEarningsTips.textColor = [UIColor ms_colorWithHexString:@"#6D6AD2"];
        lbYesterdayEarningsTips.textAlignment = NSTextAlignmentCenter;
        lbYesterdayEarningsTips.font = [UIFont systemFontOfSize:12];
        lbYesterdayEarningsTips.text = @"昨日收益(元)";
        [topView addSubview:lbYesterdayEarningsTips];
        [lbYesterdayEarningsTips autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(13, 0, 0, 0) excludingEdge:ALEdgeBottom];
        [lbYesterdayEarningsTips autoSetDimension:ALDimensionHeight toSize:13];
        
        self.lbYesterdayEarnings = [UILabel newAutoLayoutView];
        self.lbYesterdayEarnings.textColor = [UIColor ms_colorWithHexString:@"#FFFFFF"];
        self.lbYesterdayEarnings.textAlignment = NSTextAlignmentCenter;
        self.lbYesterdayEarnings.font = [UIFont systemFontOfSize:36];
        self.lbYesterdayEarnings.text = @"--";
        [topView addSubview:self.lbYesterdayEarnings];
        [self.lbYesterdayEarnings autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbYesterdayEarnings autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbYesterdayEarnings autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbYesterdayEarningsTips withOffset:17];
        [self.lbYesterdayEarnings autoSetDimension:ALDimensionHeight toSize:36];
        
        self.lbHistoryAddUpAmount = [UILabel newAutoLayoutView];
        self.lbHistoryAddUpAmount.textColor = [UIColor ms_colorWithHexString:@"#FFFFFF"];
        self.lbHistoryAddUpAmount.textAlignment = NSTextAlignmentCenter;
        self.lbHistoryAddUpAmount.font = [UIFont systemFontOfSize:12];
        self.lbHistoryAddUpAmount.text = @"--";
        [topView addSubview:self.lbHistoryAddUpAmount];
        [self.lbHistoryAddUpAmount autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbHistoryAddUpAmount autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbHistoryAddUpAmount autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbYesterdayEarnings withOffset:16];
        [self.lbHistoryAddUpAmount autoSetDimension:ALDimensionHeight toSize:13];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#6D6AD2"];
        [topView addSubview:line];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbHistoryAddUpAmount withOffset:14];
        [line autoSetDimension:ALDimensionHeight toSize:0.5];
        
        UILabel *lbTotalAmountTips = [UILabel newAutoLayoutView];
        lbTotalAmountTips.textColor = [UIColor ms_colorWithHexString:@"#6D6AD2"];
        lbTotalAmountTips.textAlignment = NSTextAlignmentCenter;
        lbTotalAmountTips.font = [UIFont systemFontOfSize:12];
        lbTotalAmountTips.text = @"活期总资产(元)";
        [topView addSubview:lbTotalAmountTips];
        [lbTotalAmountTips autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line withOffset:14];
        [lbTotalAmountTips autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [lbTotalAmountTips autoSetDimension:ALDimensionHeight toSize:13];
        
        self.btnEye = [UIButton newAutoLayoutView];
        [self.btnEye setImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
        [self.btnEye setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateSelected];
        self.btnEye.showsTouchWhenHighlighted = YES;
        [topView addSubview:self.btnEye];
        [self.btnEye autoSetDimensionsToSize:CGSizeMake(30, 20)];
        [self.btnEye autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbTotalAmountTips];
        [self.btnEye autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lbTotalAmountTips withOffset:50];
        self.btnEye.hidden = YES;
        @weakify(self);
        [[self.btnEye rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            self.btnEye.selected = !self.btnEye.selected;
            if (self.btnEye.selected) {
                self.lbTotalAmount.text = @"****";
            } else {
                self.lbTotalAmount.text = [NSString stringWithFormat:@"%.2f",self.assetInfo.currentAsset.totalAmount.doubleValue];
            }
        }];
        
        self.lbTotalAmount = [UILabel newAutoLayoutView];
        self.lbTotalAmount.textColor = [UIColor ms_colorWithHexString:@"#FFFFFF"];
        self.lbTotalAmount.textAlignment = NSTextAlignmentCenter;
        self.lbTotalAmount.font = [UIFont systemFontOfSize:24];
        self.lbTotalAmount.text = @"--";
        [topView addSubview:self.lbTotalAmount];
        [self.lbTotalAmount autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbTotalAmount autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbTotalAmount autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbTotalAmountTips withOffset:9];
        [self.lbTotalAmount autoSetDimension:ALDimensionHeight toSize:24];
        
        self.lbRedeemFrozonAmountAmount = [UILabel newAutoLayoutView];
        self.lbRedeemFrozonAmountAmount.textColor = [UIColor whiteColor];
        self.lbRedeemFrozonAmountAmount.text = @"赎回中：--元";
        self.lbRedeemFrozonAmountAmount.textAlignment = NSTextAlignmentCenter;
        self.lbRedeemFrozonAmountAmount.font = [UIFont systemFontOfSize:12];
        [topView addSubview:self.lbRedeemFrozonAmountAmount];
        [self.lbRedeemFrozonAmountAmount autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbTotalAmount withOffset:9];
        [self.lbRedeemFrozonAmountAmount autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbRedeemFrozonAmountAmount autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.lbRedeemFrozonAmountAmount autoSetDimension:ALDimensionHeight toSize:13];
        
        UIView *bottomView = [UIView newAutoLayoutView];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomView];
        [bottomView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topView];
        [bottomView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [bottomView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [bottomView autoSetDimension:ALDimensionHeight toSize:80];
        
        CGFloat width = self.width / 3.0;
        
        UILabel *lbInvestAmountTips = [UILabel newAutoLayoutView];
        lbInvestAmountTips.text = @"投资金额(元)";
        lbInvestAmountTips.textAlignment = NSTextAlignmentCenter;
        lbInvestAmountTips.font = [UIFont systemFontOfSize:12];
        lbInvestAmountTips.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [bottomView addSubview:lbInvestAmountTips];
        [lbInvestAmountTips autoSetDimensionsToSize:CGSizeMake(width, 12)];
        [lbInvestAmountTips autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [lbInvestAmountTips autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
        
        UILabel *lbPurchaseFrozenAmountTips = [UILabel newAutoLayoutView];
        lbPurchaseFrozenAmountTips.text = @"申购中(元)";
        lbPurchaseFrozenAmountTips.textAlignment = NSTextAlignmentCenter;
        lbPurchaseFrozenAmountTips.font = [UIFont systemFontOfSize:12];
        lbPurchaseFrozenAmountTips.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [bottomView addSubview:lbPurchaseFrozenAmountTips];
        [lbPurchaseFrozenAmountTips autoSetDimensionsToSize:CGSizeMake(width, 12)];
        [lbPurchaseFrozenAmountTips autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbInvestAmountTips];
        [lbPurchaseFrozenAmountTips autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lbInvestAmountTips];
        
        UILabel *lbAddUpAmountTips = [UILabel newAutoLayoutView];
        lbAddUpAmountTips.text = @"未结转收益(元)";
        lbAddUpAmountTips.textAlignment = NSTextAlignmentCenter;
        lbAddUpAmountTips.font = [UIFont systemFontOfSize:12];
        lbAddUpAmountTips.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [bottomView addSubview:lbAddUpAmountTips];
        [lbAddUpAmountTips autoSetDimensionsToSize:CGSizeMake(width, 12)];
        [lbAddUpAmountTips autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbPurchaseFrozenAmountTips];
        [lbAddUpAmountTips autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lbPurchaseFrozenAmountTips];
        
        self.lbInvestAmount = [UILabel newAutoLayoutView];
        self.lbInvestAmount.text = @"--";
        self.lbInvestAmount.textAlignment = NSTextAlignmentCenter;
        self.lbInvestAmount.font = [UIFont systemFontOfSize:18];
        self.lbInvestAmount.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [bottomView addSubview:self.lbInvestAmount];
        [self.lbInvestAmount autoSetDimensionsToSize:CGSizeMake(width, 18)];
        [self.lbInvestAmount autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.lbInvestAmount autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbInvestAmountTips withOffset:12];
        
        self.lbPurchaseFrozenAmount = [UILabel newAutoLayoutView];
        self.lbPurchaseFrozenAmount.text = @"--";
        self.lbPurchaseFrozenAmount.textAlignment = NSTextAlignmentCenter;
        self.lbPurchaseFrozenAmount.font = [UIFont systemFontOfSize:18];
        self.lbPurchaseFrozenAmount.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [bottomView addSubview:self.lbPurchaseFrozenAmount];
        [self.lbPurchaseFrozenAmount autoSetDimensionsToSize:CGSizeMake(width, 18)];
        [self.lbPurchaseFrozenAmount autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbInvestAmount];
        [self.lbPurchaseFrozenAmount autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.lbInvestAmount];
        
        self.lbAddUpAmount = [UILabel newAutoLayoutView];
        self.lbAddUpAmount.text = @"--";
        self.lbAddUpAmount.textAlignment = NSTextAlignmentCenter;
        self.lbAddUpAmount.font = [UIFont systemFontOfSize:18];
        self.lbAddUpAmount.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        [bottomView addSubview:self.lbAddUpAmount];
        [self.lbAddUpAmount autoSetDimensionsToSize:CGSizeMake(width, 18)];
        [self.lbAddUpAmount autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.lbPurchaseFrozenAmount];
        [self.lbAddUpAmount autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.lbPurchaseFrozenAmount];
  
        CGFloat distance = (self.width - 1) / 3.0;
        
        UIImageView *leftLine = [UIImageView newAutoLayoutView];
        leftLine.image = [UIImage imageNamed:@"line_vertical"];
        [bottomView addSubview:leftLine];
        [leftLine autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:lbInvestAmountTips];
        [leftLine autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.lbInvestAmount];
        [leftLine autoSetDimension:ALDimensionWidth toSize:0.5];
        [leftLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:distance];
        
        UIImageView *rightLine = [UIImageView newAutoLayoutView];
        rightLine.image = [UIImage imageNamed:@"line_vertical"];
        [bottomView addSubview:rightLine];
        [rightLine autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:lbInvestAmountTips];
        [rightLine autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.lbInvestAmount];
        [rightLine autoSetDimension:ALDimensionWidth toSize:0.5];
        [rightLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:distance * 2];
        
    }
    return self;
}

- (void)setAssetInfo:(AssetInfo *)assetInfo {
    _assetInfo = assetInfo;
    self.lbYesterdayEarnings.text = [NSString stringWithFormat:@"%.2f",assetInfo.currentAsset.yesterdayEarnings.doubleValue];
    self.lbHistoryAddUpAmount.text = [NSString stringWithFormat:@"累计收益：%.2f元",assetInfo.currentAsset.historyAddUpAmount.doubleValue];
    if (self.btnEye.selected) {
        self.lbTotalAmount.text = @"****";
    } else {
        self.lbTotalAmount.text = [NSString stringWithFormat:@"%.2f",assetInfo.currentAsset.totalAmount.doubleValue];
    }
    self.lbRedeemFrozonAmountAmount.text = [NSString stringWithFormat:@"赎回中：%.2f元",assetInfo.currentAsset.redeemFrozenAmount.doubleValue];
    self.lbInvestAmount.text = [NSString stringWithFormat:@"%.2f",assetInfo.currentAsset.investAmount.doubleValue];
    self.lbPurchaseFrozenAmount.text = [NSString stringWithFormat:@"%.2f",assetInfo.currentAsset.purchaseFrozenAmount.doubleValue];
    self.lbAddUpAmount.text = [NSString stringWithFormat:@"%.2f",assetInfo.currentAsset.addUpAmount.doubleValue];
}
@end

#pragma mark - MSCurrentDetailHeaderView
@interface MSCurrentDetailHeaderView ()
@property (strong, nonatomic) MSTrendChartView *trendChartView;
@property (strong, nonatomic) MSNoInvestCurrentHeaderView *noInvestCurrentHeaderView;
@property (strong, nonatomic) MSHasInvestCurrentHeaderView *hasInvestCurrentHeaderView;

@property (strong, nonatomic) AssetInfo *assetInfo;
@property (strong, nonatomic) CurrentDetail *currentDetail;
@end

@implementation MSCurrentDetailHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
        
        self.noInvestCurrentHeaderView = [[MSNoInvestCurrentHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, 155)];
        self.noInvestCurrentHeaderView.backgroundColor = [UIColor ms_colorWithHexString:@"#333092"];
        self.noInvestCurrentHeaderView.hidden = YES;
        [self addSubview:self.noInvestCurrentHeaderView];
        
        self.hasInvestCurrentHeaderView = [[MSHasInvestCurrentHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, 308)];
        self.hasInvestCurrentHeaderView.backgroundColor = [UIColor ms_colorWithHexString:@"#F8F8F8"];
        self.hasInvestCurrentHeaderView.hidden = YES;
        [self addSubview:self.hasInvestCurrentHeaderView];
        @weakify(self);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap.rac_gestureSignal subscribeNext:^(id x) {
            @strongify(self);
            MSCurrentIncomeDetail *inComeVC = [[MSCurrentIncomeDetail alloc] initWithCurrentId:self.currentDetail.baseInfo.currentID];
            [self.ms_viewController.navigationController pushViewController:inComeVC animated:YES];
        }];
        [self.hasInvestCurrentHeaderView addGestureRecognizer:tap];
        
        self.trendChartView = [[MSTrendChartView alloc] initWithFrame:CGRectMake(0, 0, self.width, 250)];
        [self addSubview:self.trendChartView];
        self.height = CGRectGetMaxY(self.trendChartView.frame) + 10;
    }
    return self;
}

- (void)updateWithAssetInfo:(AssetInfo *)assetInfo currentInfo:(CurrentInfo *)currentInfo currentDetail:(CurrentDetail *)currentDetail {
    if (assetInfo.currentAsset.totalAmount.doubleValue > 0 || assetInfo.currentAsset.historyAddUpAmount.doubleValue > 0) {
        self.noInvestCurrentHeaderView.hidden = YES;
        self.hasInvestCurrentHeaderView.hidden = NO;
        self.trendChartView.y = CGRectGetMaxY(self.hasInvestCurrentHeaderView.frame);
    }else {
        self.noInvestCurrentHeaderView.hidden = NO;
        self.hasInvestCurrentHeaderView.hidden = YES;
        self.trendChartView.y = CGRectGetMaxY(self.noInvestCurrentHeaderView.frame);
    }
    self.height = CGRectGetMaxY(self.trendChartView.frame) + 10;
    
    if (currentDetail) {
        NSMutableArray *times = [NSMutableArray array];
        NSMutableArray *points = [NSMutableArray array];
        for (DayInterestRate *rate in currentDetail.last7DaysInterestRates) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:rate.date];
            [times addObject:[NSString stringWithFormat:@"%02ld-%02ld",(long)date.month,(long)date.day]];
            [points addObject:@(rate.interestRate)];
        }
        UIColor *brokenLineColor = [UIColor ms_colorWithHexString:@"#333092"];
        [self.trendChartView updateWithMinTrend:currentDetail.minDisplayInterestRate maxTrend:currentDetail.maxDisplayInterestRate lineCount:currentDetail.intervalRateCount + 1 brokenLineColor:brokenLineColor times:times points:points mask:YES animation:YES];
    }
    
    if (!currentDetail) {
        currentDetail = [[CurrentDetail alloc] init];
        currentDetail.baseInfo = currentInfo;
    }
    self.noInvestCurrentHeaderView.currentDetail = currentDetail;
    self.hasInvestCurrentHeaderView.assetInfo = assetInfo;
    
    self.assetInfo = assetInfo;
    self.currentDetail = currentDetail;
}
@end
