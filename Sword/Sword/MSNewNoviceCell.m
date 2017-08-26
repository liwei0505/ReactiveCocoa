//
//  MSNewNoviceCell.m
//  Sword
//
//  Created by msj on 2017/6/13.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSNewNoviceCell.h"
#import "MSCircleProgressView.h"
#import "UIView+FrameUtil.h"
#import "UIImage+color.h"
#import "MSTextUtils.h"

#define RGB(R,G,B,A) [UIColor colorWithRed:(R)/255.0f green:(G)/255.0f blue:(B)/255.0f alpha:(A)]

@interface MSButton : UIButton
@end
@implementation MSButton
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat titleH = contentRect.size.height - 11;
    CGFloat titleW = contentRect.size.width;
    return CGRectMake(0, 0, titleW, titleH);
}
@end


#pragma mark - MSNewSubCell
@interface MSNewSubCell : UICollectionViewCell
@property (copy, nonatomic) void (^block)(NSNumber *loanId);
@property (strong, nonatomic) LoanDetail *loanDetail;
@end

@interface MSNewSubCell ()
@property (strong, nonatomic) UILabel *lbTitle;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lbStartAmount;
@property (strong, nonatomic) UILabel *lbInterest;
@property (strong, nonatomic) UILabel *lbTerm;
@property (strong, nonatomic) UILabel *lbInterestTips;
@property (strong, nonatomic) UILabel *lbTermTips;
@property (strong, nonatomic) MSButton *btnInvest;
@property (strong, nonatomic) UIView *topLine;
@property (strong, nonatomic) UIView *centerLine;
@property (strong, nonatomic) UIView *line;
@end

@implementation MSNewSubCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.topLine = [[UIView alloc] init];
        self.topLine.backgroundColor = [UIColor ms_colorWithHexString:@"f8f8f8"];
        [self.contentView addSubview:self.topLine];
        
        self.lbTitle = [[UILabel alloc] init];
        self.lbTitle.text = @"新手专享";
        self.lbTitle.font = [UIFont boldSystemFontOfSize:16];
        self.lbTitle.textColor = [UIColor ms_colorWithHexString:@"#333333"];
        self.lbTitle.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbTitle];
        
        self.icon = [[UIImageView alloc] init];
        self.icon.image = [UIImage imageNamed:@"ms_new_novice"];
        [self.contentView addSubview:self.icon];
        
        self.lbStartAmount = [[UILabel alloc] init];
        self.lbStartAmount.font = [UIFont boldSystemFontOfSize:12];
        self.lbStartAmount.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbStartAmount.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.lbStartAmount];
        
        self.centerLine = [[UIView alloc] init];
        self.centerLine.backgroundColor = [UIColor ms_colorWithHexString:@"f8f8f8"];
        [self.contentView addSubview:self.centerLine];
        
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor ms_colorWithHexString:@"f8f8f8"];
        [self.contentView addSubview:self.line];
        
        self.lbInterest = [[UILabel alloc] init];
        self.lbInterest.textColor = [UIColor ms_colorWithHexString:@"#F3091C"];
        self.lbInterest.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbInterest];
        
        self.lbTerm = [[UILabel alloc] init];
        self.lbTerm.textColor = [UIColor ms_colorWithHexString:@"#666666"];
        self.lbTerm.font = [UIFont systemFontOfSize:14];
        self.lbTerm.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbTerm];
        
        self.lbInterestTips = [[UILabel alloc] init];
        self.lbInterestTips.font = [UIFont systemFontOfSize:12];
        self.lbInterestTips.text = @"预期年化收益";
        self.lbInterestTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbInterestTips.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbInterestTips];
        
        self.lbTermTips = [[UILabel alloc] init];
        self.lbTermTips.font = [UIFont systemFontOfSize:12];
        self.lbTermTips.text = @"投资期限";
        self.lbTermTips.textColor = [UIColor ms_colorWithHexString:@"#999999"];
        self.lbTermTips.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.lbTermTips];
        
        self.btnInvest = [[MSButton alloc] init];
        self.btnInvest.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.btnInvest.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnInvest setBackgroundImage:[UIImage imageNamed:@"ms_btn_home_default"] forState:UIControlStateNormal];
        [self.btnInvest setBackgroundImage:[UIImage imageNamed:@"ms_btn_home_highlight"] forState:UIControlStateHighlighted];
        [self.btnInvest setTitle:@"立即投资" forState:UIControlStateNormal];
        @weakify(self);
        [[self.btnInvest rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.block) {
                self.block(@(self.loanDetail.baseInfo.loanId));
            }
        }];
        [self.contentView addSubview:self.btnInvest];
    }
    return self;
}

- (void)setLoanDetail:(LoanDetail *)loanDetail {
    _loanDetail = loanDetail;
    if (loanDetail.baseInfo.maxInvestLimit > 0) {
        self.lbStartAmount.text = [NSString stringWithFormat:@"%d元起,上限%.f元", loanDetail.baseInfo.startAmount, loanDetail.baseInfo.maxInvestLimit];
    }else {
        self.lbStartAmount.text = [NSString stringWithFormat:@"%d元起", loanDetail.baseInfo.startAmount];
    }
    
    
    NSString *ratioStr = nil;
    NSString *interestStr = nil;
    CGFloat ratio = loanDetail.baseInfo.salesRate;
    if (ratio) {
        ratioStr = [NSString stringWithFormat:@"+%.1f%%",ratio];
    } else {
        ratioStr = @"%";
    }
    interestStr = [NSString stringWithFormat:@"%.1f", loanDetail.baseInfo.interest-ratio];
    
    
    CGFloat largeFontSize = 0;
    CGFloat smallFontSize = 0;
    if ([UIScreen mainScreen].bounds.size.width > 320) {
        largeFontSize = 45;
        smallFontSize = 20;
    }else {
        largeFontSize = 40;
        smallFontSize = 16;
    }
    NSMutableAttributedString *interestAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",interestStr,ratioStr]];
    [interestAttributedString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:largeFontSize]} range:NSMakeRange(0, interestStr.length)];
    [interestAttributedString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:smallFontSize]} range:NSMakeRange(interestStr.length, ratioStr.length)];
    self.lbInterest.attributedText = interestAttributedString;
    
    NSString *term = [NSString stringWithFormat:@"%d%@", [loanDetail.baseInfo.termInfo getTermCount], loanDetail.baseInfo.termInfo.term];
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:term];
    [attribString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:largeFontSize] range:NSMakeRange(0, term.length)];
    NSRange range = NSMakeRange(term.length - loanDetail.baseInfo.termInfo.term.length, loanDetail.baseInfo.termInfo.term.length);
    [attribString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:smallFontSize] range:range];
    self.lbTerm.attributedText = attribString;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topLine.frame = CGRectMake(0, 0, self.contentView.width, 10);
    self.lbTitle.frame = CGRectMake(16, CGRectGetMaxY(self.topLine.frame)+16, 66, 16);
    self.icon.frame = CGRectMake(CGRectGetMaxX(self.lbTitle.frame)+8, 0, 16, 16);
    self.icon.centerY = self.lbTitle.centerY;
    self.lbStartAmount.frame = CGRectMake(self.contentView.width - 216, 0, 200, 12);
    self.lbStartAmount.centerY = self.lbTitle.centerY;
    self.centerLine.frame = CGRectMake(0, CGRectGetMaxY(self.topLine.frame) + 48, self.contentView.width, 1);
    
    CGFloat width = (self.contentView.width - 40)/2.0;
    self.lbInterest.frame = CGRectMake(20, CGRectGetMaxY(self.centerLine.frame)+24, width, 48);
    self.lbTerm.frame = CGRectMake(CGRectGetMaxX(self.lbInterest.frame), CGRectGetMaxY(self.centerLine.frame)+24, width, 48);
    self.lbInterestTips.frame = CGRectMake(20, CGRectGetMaxY(self.lbInterest.frame)+3, width, 12);
    self.lbTermTips.frame = CGRectMake(CGRectGetMaxX(self.lbInterestTips.frame), CGRectGetMaxY(self.lbTerm.frame)+3, width, 12);
    self.line.frame = CGRectMake((self.contentView.width - 1)/2.0, CGRectGetMaxY(self.centerLine.frame)+41, 1, 32);
    self.btnInvest.frame = CGRectMake((self.contentView.width - 176)/2.0, CGRectGetMaxY(self.lbTermTips.frame)+14, 176, 56);
}
@end


#pragma mark - MSNewNoviceCell
@interface MSNewNoviceCell ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation MSNewNoviceCell
+ (MSNewNoviceCell *)cellWithTableView:(UITableView *)tableView {
    MSNewNoviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSNewNoviceCell"];
    if (!cell) {
        cell = [[MSNewNoviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MSNewNoviceCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 226.0);
        layout.minimumLineSpacing = 10;
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.1];
        self.collectionView.alwaysBounceHorizontal = YES;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator= NO;
        [self.collectionView registerClass:[MSNewSubCell class] forCellWithReuseIdentifier:@"MSNewSubCell"];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.contentView addSubview:self.collectionView];
        
    }
    return self;
}

- (void)setList:(MSSectionList *)list {
    _list = list;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.listWrapper.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSNewSubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSNewSubCell" forIndexPath:indexPath];
    NSNumber *loanId = [self.list.listWrapper getItemWithIndex:indexPath.row];
    cell.loanDetail = [[MSAppDelegate getServiceManager] getLoanInfo:loanId];
    @weakify(self);
    cell.block = ^(NSNumber *loanId){
        @strongify(self);
        if (self.block) {
            self.block(loanId);
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *loanId = [self.list.listWrapper getItemWithIndex:indexPath.row];
    if (self.block) {
        self.block(loanId);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
}
@end
