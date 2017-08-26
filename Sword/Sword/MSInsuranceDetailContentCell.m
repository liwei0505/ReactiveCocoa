//
//  MSInsuranceDetailContentCell.m
//  Sword
//
//  Created by lee on 2017/8/11.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceDetailContentCell.h"
#import "MSInsuranceprotocolViewController.h"
#import "MSDownloadImageView.h"
#import "MSInsuranceScrollView.h"

@interface MSInsuranceDetailContentCell()<UIScrollViewDelegate>

@property (strong, nonatomic) MSInsuranceScrollView *scrollView;
@property (strong, nonatomic) UIButton *currentButton;
@property (strong, nonatomic) UIView *selectedBtnView;
@property (strong, nonatomic) UIView *selectedView;
@property (strong, nonatomic) UITextField *tfBenefit;
@property (strong, nonatomic) NSDictionary *imageDict;
@property (strong, nonatomic) UIView *protocolView;
@property (assign, nonatomic) float scrollBottom;
@property (assign, nonatomic) float contentOffsetY;
@property (strong, nonatomic) UIButton *btnLeft;
@property (strong, nonatomic) UIButton *btnMiddle;
@property (strong, nonatomic) UIButton *btnRight;
@property (strong, nonatomic) UILabel *explain;
@property (strong, nonatomic) UILabel *lbExplain;
@property (strong, nonatomic) NSLayoutConstraint *specialConstraint;
@property (assign, nonatomic) BOOL buttonSelectedFlag;

@end

@implementation MSInsuranceDetailContentCell

+ (MSInsuranceDetailContentCell *)cellWithTableView:(UITableView *)tableView {
    
    NSString *reuseId = @"DetailContent";
    MSInsuranceDetailContentCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[MSInsuranceDetailContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    return cell;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *la = [UIView newAutoLayoutView];
        la.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        [self.contentView addSubview:la];
        [la autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [la autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [la autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [la autoSetDimension:ALDimensionHeight toSize:8];
        
        UILabel *lbBenefit = [UILabel newAutoLayoutView];
        lbBenefit.text = @"受益人";
        lbBenefit.font = [UIFont systemFontOfSize:14];
        lbBenefit.textColor = [UIColor ms_colorWithHexString:@"333333"];
        [self.contentView addSubview:lbBenefit];
        [lbBenefit autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [lbBenefit autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:la withOffset:14];
        [lbBenefit autoSetDimension:ALDimensionWidth toSize:50];
        
        self.tfBenefit = [UITextField newAutoLayoutView];
        self.tfBenefit.userInteractionEnabled = NO;
        self.tfBenefit.font = [UIFont systemFontOfSize:12];
        self.tfBenefit.placeholder = @"法定受益人";
        self.tfBenefit.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.tfBenefit];
        [self.tfBenefit autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.tfBenefit autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lbBenefit];
        [self.tfBenefit autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lbBenefit];
        
        UIView *lb = [UIView newAutoLayoutView];
        lb.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        [self.contentView addSubview:lb];
        [lb autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [lb autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lbBenefit withOffset:14];
        [lb autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [lb autoSetDimension:ALDimensionHeight toSize:8];
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        [self.contentView addSubview:line];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
        self.specialConstraint = [line autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:lb withOffset:0];
        [line autoSetDimension:ALDimensionHeight toSize:8];
        
        UILabel *explain = [UILabel newAutoLayoutView];
        explain.font = [UIFont systemFontOfSize:14];
        explain.text = @"特别约定";
        self.explain = explain;
        [self.contentView addSubview:self.explain];
        [self.explain autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [self.explain autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lb withOffset:14];
        self.explain.hidden = YES;
        
        UILabel *lbExplain = [UILabel newAutoLayoutView];
        lbExplain.font = [UIFont systemFontOfSize:12];
        lbExplain.text = _detail.specialAgreement;
        self.lbExplain = lbExplain;
        [self.contentView addSubview:self.lbExplain];
        [self.lbExplain autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [self.lbExplain autoAlignAxis:ALAxisHorizontal toSameAxisOfView:explain];
        self.lbExplain.hidden = YES;
        
        float width = [UIScreen mainScreen].bounds.size.width / 3.0;
        [self.contentView addSubview:self.btnLeft];
        [self.btnLeft autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
        [self.btnLeft autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.btnLeft autoSetDimensionsToSize:CGSizeMake(width, 42)];
        
        [self.contentView addSubview:self.btnMiddle];
        [self.btnMiddle autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
        [self.btnMiddle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:width];
        [self.btnMiddle autoSetDimensionsToSize:CGSizeMake(width, 42)];
        
        [self.contentView addSubview:self.btnRight];
        [self.btnRight autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line];
        [self.btnRight autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:width*2];
        [self.btnRight autoSetDimensionsToSize:CGSizeMake(width, 42)];
        
        [self.contentView addSubview:self.selectedView];
        [self.selectedView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:line withOffset:42];
        [self.selectedView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.currentButton];
        
        [self.contentView addSubview:self.scrollView];
        [self.scrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line withOffset:45];
        [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
    }
    return self;
}

- (void)addImage {
    
    if (!self.imageDict || ![self.imageDict objectForKey:@(INSURACE_CONTENT_TYPE_INTRODUCTION)]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product_img_content"]];
        [self.scrollView addSubview:imageView];
        self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(imageView.frame));
        return;
    }
    
    self.scrollView.imageDict = self.imageDict;
    self.scrollView.viewModel = self.viewModel;

    for (int i=1; i<=self.imageDict.count; i++) {
        
        NSNumber *height = [self.viewModel.scrollHeightArray objectAtIndex:(i-1)];
        [self addWithY:height.doubleValue type:i list:[self.imageDict objectForKey:@(i)]];
        
    }
    
//    CGSize size = self.scrollView.contentSize;
//    self.protocolView.frame = CGRectMake(0, size.height, [UIScreen mainScreen].bounds.size.width, 50);
//    [self.scrollView addSubview:self.protocolView];
//    self.scrollView.contentSize = CGSizeMake(0, size.height+50);
    
}


- (void)addWithY:(float)y type:(InsuranceContentType)type list:(NSArray *)list {
    
    for (int i=0; i<list.count; i++) {
        MSDownloadImageView *imageView = [[MSDownloadImageView alloc] initWithImage:[UIImage imageNamed:@"product_img_content"]];
        [self.scrollView addSubview:imageView];
        @weakify(self);
        [imageView loadImageWithURL:list[i] completion:^(int tag, UIImage *image) {
            @strongify(self);
            [self reloadImage];
            NSLog(@"%@",NSStringFromCGSize(image.size));
            
        }];
        
        if (i==(list.count-1)) {
            float max = CGRectGetMaxY(imageView.frame);
            self.scrollView.contentSize = CGSizeMake(0, max);
            self.viewModel.scrollHeightArray[type] = [NSNumber numberWithFloat:max];
            self.scrollBottom = (max > self.scrollBottom) ? max : self.scrollBottom;
        }
    }
}

- (void)reloadImage {

        float lastBottom = 0;
        float lastItem = 0;
    
        for (int i=1; i<=self.imageDict.count; i++) {
    
            NSArray *array = [self.imageDict objectForKey:@(i)];
    
            for (int j=0; j<array.count; j++) {
                id obj = [self.scrollView.subviews objectAtIndex:j+lastItem];
                if (![obj isKindOfClass:[MSDownloadImageView class]]) {
                    continue;
                }
    
                MSDownloadImageView *imageView = (MSDownloadImageView *)obj;
                imageView.y += lastBottom;
                lastBottom = CGRectGetMaxY(imageView.frame);
    
                if (j==(array.count-1)) {
                    float max = CGRectGetMaxY(imageView.frame);
                    self.scrollView.contentSize = CGSizeMake(0, max);
                    self.viewModel.scrollHeightArray[i] = [NSNumber numberWithFloat:max];
                }
            }
            lastItem += array.count;
        }
    
}


- (void)titleClick:(UIButton *)sender {
    NSLog(@"%ld",(long)sender.tag);

    if (self.currentButton.tag == sender.tag) {
        return;
    }
    
    self.currentButton.selected = !self.currentButton.selected;
    sender.selected = !sender.selected;
    self.currentButton = sender;
    self.selectedView.centerX = sender.centerX;
    
    self.buttonSelectedFlag = YES;
    
    NSNumber *height = [self.viewModel.scrollHeightArray objectAtIndex:(sender.tag)];
//    if (sender.tag == 2 && self.scrollBottom <= height.floatValue) {
//        return;
//    }
    
    CGPoint point = self.scrollView.contentOffset;
    point.y = height.doubleValue;
    [self.scrollView setContentOffset:point animated:YES];
    
}

#pragma delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.contentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.buttonSelectedFlag = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    if (!self.canScroll && !self.buttonSelectedFlag) {
        scrollView.contentOffset = CGPointZero;
    }
    
    CGFloat y = scrollView.contentOffset.y;
    
    if (y <= 0) {
        self.canScroll = NO;
        return;
    }
    
    if (self.buttonSelectedFlag) {
        
    } else {
        
        NSNumber *leftGroup = [self.viewModel.scrollHeightArray objectAtIndex:1];
        NSNumber *centerGroup = [self.viewModel.scrollHeightArray objectAtIndex:2];
        
        if (y < self.contentOffsetY) {
            
            if (y < leftGroup.floatValue) {
                self.currentButton.selected = !self.currentButton.selected;
                self.currentButton = self.btnLeft;
                self.selectedView.centerX = self.btnLeft.centerX;
                [self.btnLeft setSelected:YES];
                [self.btnMiddle setSelected:NO];
            } else if (y>leftGroup.floatValue && y < centerGroup.floatValue) {
                self.currentButton.selected = !self.currentButton.selected;
                self.currentButton = self.btnMiddle;
                self.selectedView.centerX = self.btnMiddle.centerX;
                [self.btnMiddle setSelected:YES];
                [self.btnRight setSelected:NO];
            }
            
            NSLog(@"down");
        } else if (y > self.contentOffsetY) {
            NSLog(@"up");
            if (y > leftGroup.floatValue && y<centerGroup.floatValue) {
                self.currentButton.selected = !self.currentButton.selected;
                self.selectedView.centerX = self.btnMiddle.centerX;
                self.currentButton = self.btnMiddle;
                [self.btnLeft setSelected:NO];
                [self.btnMiddle setSelected:YES];
            } else if (y > centerGroup.floatValue) {
                self.currentButton.selected = !self.currentButton.selected;
                self.selectedView.centerX = self.btnRight.centerX;
                self.currentButton = self.btnRight;
                [self.btnMiddle setSelected:NO];
                [self.btnRight setSelected:YES];
            }
        }
    }
    
}

#pragma mark - lazy

- (UIButton *)btnLeft {
    if (!_btnLeft) {
        _btnLeft = [self getButton:@"产品介绍" tag:0];
        _btnLeft.selected = YES;
        self.currentButton = _btnLeft;
    }
    return _btnLeft;
}

- (UIButton *)btnMiddle {
    if (!_btnMiddle) {
        _btnMiddle = [self getButton:@"理赔流程" tag:1];
    }
    return _btnMiddle;
}

- (UIButton *)btnRight {
    if (!_btnRight) {
        _btnRight = [self getButton:@"常见问题" tag:2];
    }
    return _btnRight;
}

- (UIView *)selectedView {
    if (!_selectedView) {
        _selectedView = [UIView newAutoLayoutView];
        _selectedView.backgroundColor = [UIColor ms_colorWithHexString:@"F3091C"];
        [self.contentView addSubview:self.selectedView];
        [self.selectedView autoSetDimensionsToSize:CGSizeMake(64, 2)];
    }
    return _selectedView;
}

- (MSInsuranceScrollView *)scrollView {

    if (!_scrollView) {
        _scrollView = [[MSInsuranceScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
    
}

- (UIView *)protocolView {
    if (!_protocolView) {
        _protocolView = [[UIView alloc] init];//CGRectMake(0, 0, self.bounds.size.width, 60)
        _protocolView.backgroundColor = [UIColor ms_colorWithHexString:@"f0f0f0"];
        UIButton *btnAgree = [UIButton newAutoLayoutView];
        [btnAgree setBackgroundImage:[UIImage imageNamed:@"agreeSelected"] forState:UIControlStateSelected];
        [btnAgree setBackgroundImage:[UIImage imageNamed:@"agreeNormal"] forState:UIControlStateNormal];
        [btnAgree setSelected:YES];
        [btnAgree addTarget:self action:@selector(agreeClick:) forControlEvents:UIControlEventTouchUpInside];
        [_protocolView addSubview:btnAgree];
        [btnAgree autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [btnAgree autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [btnAgree autoSetDimensionsToSize:CGSizeMake(12, 12)];
        
        NSArray *protocolArray = self.detail.contractList;
        NSString *titleString = @"";
        for (int i=0; i<protocolArray.count; i++) {
            ContractInfo *info = protocolArray[i];
            titleString = [titleString stringByAppendingString:[NSString stringWithFormat:@"《%@》",info.contractName]];
        }
        
        NSString *string = [NSString stringWithFormat:@"本人承诺投保信息的真实性,理解并同意%@的全部内容",titleString];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:string];
        [attribute addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10],NSForegroundColorAttributeName: [UIColor ms_colorWithHexString:@"333333"]} range:NSMakeRange(0, string.length)];
        
        for (int i=0; i<protocolArray.count; i++) {
            ContractInfo *info = protocolArray[i];
            NSRange range = [string rangeOfString:info.contractName];
            NSRange titleRange = NSMakeRange(range.location-1, range.length+2);
            [attribute yy_setTextHighlightRange:titleRange color:[UIColor ms_colorWithHexString:@"4945B7"] backgroundColor:[UIColor ms_colorWithHexString:@"f0f0f0"] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                MSInsuranceprotocolViewController *web = [[MSInsuranceprotocolViewController alloc] init];
                if (info.contractURL) {
                    [web updateWithFileName:info.contractName fileUrl:info.contractURL];
                    [[[MSAppDelegate getInstance] getNavigationController] pushViewController:web animated:YES];
                }
            }];
        }
        
        YYLabel *protocol = [[YYLabel alloc] init];
        [protocol configureForAutoLayout];
        protocol.numberOfLines = 0;
        protocol.attributedText = attribute;
        [_protocolView addSubview:protocol];
        YYTextContainer *lbContainer = [YYTextContainer containerWithSize:CGSizeMake(self.bounds.size.width-36, MAXFLOAT)];
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:lbContainer text:attribute];
        [protocol autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [protocol autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:36];
        [protocol autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        [protocol autoSetDimension:ALDimensionHeight toSize:layout.textBoundingSize.height];
        
    }
    return _protocolView;
}

- (void)agreeClick:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (UIButton *)getButton:(NSString *)title tag:(int)tag {
    UIButton *button = [UIButton newAutoLayoutView];
    button.tag = tag;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor ms_colorWithHexString:@"333333"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor ms_colorWithHexString:@"F3091C"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setDetail:(InsuranceDetail *)detail {
    _detail = detail;
    @weakify(self);
    
    if (_detail.specialAgreement.length) {
        self.explain.hidden = NO;
        self.lbExplain.hidden = NO;
        self.lbExplain.text = _detail.specialAgreement;
        self.specialConstraint.constant = 48+8;
    }
    
    [_viewModel queryContentCompletion:^(BOOL status, NSDictionary *dict) {
        @strongify(self);
        if (status) {
            self.imageDict = dict;
            [self addImage];
        } else {
            NSLog(@"保险详情图片链接获取失败");
        }
    }];
}

- (void)setCanScroll:(BOOL)canScroll {
    _canScroll = canScroll;
    [self.scrollView setScrollEnabled:canScroll];
}

- (void)setImageDict:(NSDictionary *)imageDict {
    _imageDict = imageDict;
}



@end
