//
//  MSInsuranceTypeView.m
//  Sword
//
//  Created by lee on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSInsuranceTypeView.h"

@interface MSInsuranceTypeView()

@property (strong, nonatomic) UILabel *lbUpgrade;
@property (strong, nonatomic) UILabel *lbAdvance;
@property (strong, nonatomic) UILabel *lbCheap;
@property (strong, nonatomic) UILabel *lbLeft;
@property (strong, nonatomic) UILabel *lbMid;
@property (strong, nonatomic) UILabel *lbRight;
@property (strong, nonatomic) UIView *selectedView;
@property (assign, nonatomic) int current;
@property (assign, nonatomic) float margin;

@end

@implementation MSInsuranceTypeView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {

    self.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [UIView newAutoLayoutView];
    line.backgroundColor = [UIColor ms_colorWithHexString:@"F0F0F0"];
    [self addSubview:line];
    [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [line autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [line autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:64];
    [line autoSetDimension:ALDimensionHeight toSize:1];
    
    self.selectedView = [UIView newAutoLayoutView];
    self.selectedView.backgroundColor = [UIColor ms_colorWithHexString:@"F3091C"];
    [self addSubview:self.selectedView];
    [self.selectedView autoSetDimensionsToSize:CGSizeMake(64, 2)];
    [self.selectedView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:line withOffset:0];
    self.selectedView.hidden = YES;
    
    self.current = -1;
    self.margin = 2;
    
}

- (void)setDataArray:(NSArray<InsuranceProduct *> *)dataArray {
    if (!dataArray || dataArray.count == 0) {
        return;
    } else {
        _dataArray = dataArray;;
    }
    
    if (dataArray.count == 1) {
        [self one:dataArray];
    } else if (dataArray.count == 2) {
        [self two:dataArray];
    } else if (dataArray.count == 3) {
        [self three:dataArray];
    }
    
}

- (void)one:(NSArray *)data {

    [self.selectedView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    [self addSubview:self.lbUpgrade];
    [self.lbUpgrade autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    [self.lbUpgrade autoAlignAxisToSuperviewAxis:ALAxisVertical];

    [self addSubview:self.lbLeft];
//    [self.lbLeft autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:30];
//    [self.lbLeft autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.lbLeft autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbUpgrade withOffset:self.margin];
    [self.lbLeft autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbUpgrade];
    
    InsuranceProduct *data1 = data[0];
    self.lbUpgrade.text = [NSString stringWithFormat:@"%.2f元起",data1.premium.doubleValue];
    self.lbLeft.text = data1.productName;
    
    [self changeStatus:SelectedLeft];
}

- (void)two:(NSArray *)data {

    float width = self.bounds.size.width * 0.5;
    [self addSubview:self.lbUpgrade];
    [self.lbUpgrade autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    [self.lbUpgrade autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.lbUpgrade autoSetDimension:ALDimensionWidth toSize:width];
    
    [self addSubview:self.lbAdvance];
    [self.lbAdvance autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    [self.lbAdvance autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.lbAdvance autoSetDimension:ALDimensionWidth toSize:width];
    
    [self addSubview:self.lbLeft];
    [self.lbLeft autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbUpgrade withOffset:self.margin];
    [self.lbLeft autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbUpgrade];
    
    [self addSubview:self.lbMid];
    [self.lbMid autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbAdvance withOffset:self.margin];
    [self.lbMid autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbAdvance];
    
    InsuranceProduct *data1 = data[0];
    self.lbUpgrade.text = [NSString stringWithFormat:@"%.2f元起",data1.premium.doubleValue];
    self.lbLeft.text = data1.productName;

    InsuranceProduct *data2 = data[1];
    self.lbAdvance.text = [NSString stringWithFormat:@"%.2f元起",data2.premium.doubleValue];
    self.lbMid.text = data2.productName;
    
    [self changeStatus:SelectedLeft];
    [self.selectedView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:(width*0.5-32)];
    self.selectedView.hidden = NO;
}

- (void)three:(NSArray *)data {

    [self.selectedView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    float width = (self.bounds.size.width-40) / 3.0;
    [self addSubview:self.lbUpgrade];
    [self.lbUpgrade autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    [self.lbUpgrade autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.lbUpgrade autoSetDimension:ALDimensionWidth toSize:width];
    
    [self addSubview:self.lbAdvance];
    [self.lbAdvance autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    [self.lbAdvance autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.lbAdvance autoSetDimension:ALDimensionWidth toSize:width];
    
    [self addSubview:self.lbCheap];
    [self.lbCheap autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    [self.lbCheap autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [self.lbCheap autoSetDimension:ALDimensionWidth toSize:width];

    [self addSubview:self.lbLeft];
    [self.lbLeft autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbUpgrade withOffset:self.margin];
    [self.lbLeft autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbUpgrade];
    
    [self addSubview:self.lbMid];
    [self.lbMid autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbAdvance withOffset:self.margin];
    [self.lbMid autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbAdvance];
    
    [self addSubview:self.lbRight];
    [self.lbRight autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lbCheap withOffset:self.margin];
    [self.lbRight autoAlignAxis:ALAxisVertical toSameAxisOfView:self.lbCheap];
    
    InsuranceProduct *data1 = data[0];
    self.lbUpgrade.text = [NSString stringWithFormat:@"%.2f元起",data1.premium.doubleValue];
    self.lbLeft.text = data1.productName;

    InsuranceProduct *data2 = data[1];
    self.lbAdvance.text = [NSString stringWithFormat:@"%.2f元起",data2.premium.doubleValue];
    self.lbMid.text = data2.productName;

    InsuranceProduct *data3 = data[2];
    self.lbCheap.text = [NSString stringWithFormat:@"%.2f元起",data3.premium.doubleValue];
    self.lbRight.text = data3.productName;
    
    [self changeStatus:SelectedMiddle];
    self.selectedView.hidden = NO;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    
    if (self.dataArray.count == 2) {
        float width = self.bounds.size.width*0.5;
        if (point.x < width) {
            [self changeStatus:SelectedLeft];
        } else {
            [self changeStatus:SelectedMiddle];
        }
    } else if (self.dataArray.count == 3) {
        float width = self.bounds.size.width / 3.0;
        if (point.x < width) {
            [self changeStatus:SelectedLeft];
        } else if (point.x < 2*width) {
            [self changeStatus:SelectedMiddle];
        } else {
            [self changeStatus:SelectedRight];
        }
    }

}

- (void)changeStatus:(InsuranceTypeSelected)status {

    if (self.current == status) {
        return;
    }
    switch (_current) {
        case SelectedLeft:{
            self.lbLeft.textColor = [UIColor ms_colorWithHexString:@"999999"];
            self.lbUpgrade.textColor = [UIColor ms_colorWithHexString:@"333333"];
        }
            break;
        case SelectedMiddle:{
            self.lbMid.textColor = [UIColor ms_colorWithHexString:@"999999"];
            self.lbAdvance.textColor = [UIColor ms_colorWithHexString:@"333333"];
        }
            break;
        case SelectedRight:{
            self.lbRight.textColor = [UIColor ms_colorWithHexString:@"999999"];
            self.lbCheap.textColor = [UIColor ms_colorWithHexString:@"333333"];
        }
            break;
    }
    
    switch (status) {
        case SelectedLeft:{
            self.lbLeft.textColor = [UIColor ms_colorWithHexString:@"F3091C"];
            self.lbUpgrade.textColor = [UIColor ms_colorWithHexString:@"F3091C"];
            self.selectedView.centerX = self.lbUpgrade.centerX;
        }
            break;
        case SelectedMiddle:{
            self.lbMid.textColor = [UIColor ms_colorWithHexString:@"F3091C"];
            self.lbAdvance.textColor = [UIColor ms_colorWithHexString:@"F3091C"];
            self.selectedView.centerX = self.lbAdvance.centerX;
        }
            break;
        case SelectedRight:{
            self.lbRight.textColor = [UIColor ms_colorWithHexString:@"F3091C"];
            self.lbCheap.textColor = [UIColor ms_colorWithHexString:@"F3091C"];
            self.selectedView.centerX = self.lbCheap.centerX;
        }
            break;
    }
    self.current = status;
    self.selectBlock(status);

}

- (UILabel *)lbUpgrade {
    if (!_lbUpgrade) {
        _lbUpgrade = [self getLabel];
    }
    return _lbUpgrade;
}

- (UILabel *)lbAdvance {
    if (!_lbAdvance) {
        _lbAdvance = [self getLabel];
    }
    return _lbAdvance;
}

- (UILabel *)lbCheap {
    if (!_lbCheap) {
        _lbCheap = [self getLabel];
    }
    return _lbCheap;
}

- (UILabel *)getLabel {
    UILabel *label = [UILabel newAutoLayoutView];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
//    label.textColor = [UIColor ms_colorWithHexString:@"333333"];
    return label;
}

- (UILabel *)lbLeft {
    if (!_lbLeft) {
        _lbLeft = [self getTitleLabel];
    }
    return _lbLeft;
}

- (UILabel *)lbMid {
    if (!_lbMid) {
        _lbMid = [self getTitleLabel];
    }
    return _lbMid;
}

- (UILabel *)lbRight {
    if (!_lbRight) {
        _lbRight = [self getTitleLabel];
    }
    return _lbRight;
}

- (UILabel *)getTitleLabel {
    UILabel *label = [UILabel newAutoLayoutView];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
//    label.textColor = [UIColor ms_colorWithHexString:@"999999"];
    return label;
}

@end
