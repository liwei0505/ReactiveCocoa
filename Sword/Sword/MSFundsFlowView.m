//
//  MSFundsFlowView.m
//  Sword
//
//  Created by msj on 2017/7/4.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSFundsFlowView.h"
#import "UIColor+StringColor.h"
#import "UIView+FrameUtil.h"
#import "MSConfig.h"

@interface MSFundsFlowModel : NSObject
@property (assign, nonatomic) int recordTypeIndex;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL isSelected;
@end
@implementation MSFundsFlowModel
@end

@interface MSFundsFlowView()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (strong, nonatomic) NSMutableArray *btns;
@property (assign, nonatomic) CGPoint point;
@end

@implementation MSFundsFlowView
- (instancetype)initWithFrame:(CGRect)frame point:(CGPoint)point
{
    self = [super initWithFrame:frame];
    if (self) {
        self.point = point;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self setupDatas];
        [self addSubviews];
    }
    return self;
}

- (void)setupDatas {
    
    self.btns = [NSMutableArray array];
    self.datas = [NSMutableArray array];
    MSFundsFlowModel *all = [MSFundsFlowModel new];
    all.recordTypeIndex = TYPE_ALL,
    all.title = NSLocalizedString(@"str_flowtype_all", @"");
    all.isSelected = YES;
    [self.datas addObject:all];
    
    MSFundsFlowModel *principal = [MSFundsFlowModel new];
    principal.recordTypeIndex = TYPE_RECOVER_PRINCIPAL,
    principal.title = NSLocalizedString(@"str_flowtype_principal", @"");
    principal.isSelected = NO;
    [self.datas addObject:principal];
    
    MSFundsFlowModel *interest = [MSFundsFlowModel new];
    interest.recordTypeIndex = TYPE_RECOVER_INTEREST,
    interest.title = NSLocalizedString(@"str_flowtype_interest", @"");
    interest.isSelected = NO;
    [self.datas addObject:interest];
    
    MSFundsFlowModel *invest = [MSFundsFlowModel new];
    invest.recordTypeIndex = TYPE_INVEST,
    invest.title = NSLocalizedString(@"str_flowtype_invest", @"");
    invest.isSelected = NO;
    [self.datas addObject:invest];
    
    MSFundsFlowModel *charge = [MSFundsFlowModel new];
    charge.recordTypeIndex = TYPE_CHARGE,
    charge.title = NSLocalizedString(@"str_flowtype_charge", @"");
    charge.isSelected = NO;
    [self.datas addObject:charge];
    
    MSFundsFlowModel *cash = [MSFundsFlowModel new];
    cash.recordTypeIndex = TYPE_WITHDRAW,
    cash.title = NSLocalizedString(@"str_flowtype_cash", @"");
    cash.isSelected = NO;
    [self.datas addObject:cash];
    
    MSFundsFlowModel *other = [MSFundsFlowModel new];
    other.recordTypeIndex = TYPE_OTHER,
    other.title = NSLocalizedString(@"str_flowtype_other", @"");
    other.isSelected = NO;
    [self.datas addObject:other];
}

- (void)addSubviews {
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(self.width - 102*scaleX - 12, self.point.y + 10, 102*scaleX, 34*scaleY * self.datas.count)];
    self.contentView.layer.anchorPoint = CGPointMake(0.8, 0);
    self.contentView.frame = CGRectMake(self.width - 102*scaleX - 12, self.point.y + 10, 102*scaleX, 34*scaleY * self.datas.count);
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 6;
    [self addSubview:self.contentView];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.contentView.width * 0.8, -10)];
    [path addLineToPoint:CGPointMake(self.contentView.width * 0.7, 0)];
    [path addLineToPoint:CGPointMake(self.contentView.width * 0.9, 0)];
    [path closePath];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.contentView.layer addSublayer:shapeLayer];
    
    for (int i = 0; i < self.datas.count; i++) {
        
        MSFundsFlowModel *model = self.datas[i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i * 34*scaleY, self.contentView.width, 34*scaleY)];
        [btn setTitle:model.title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor ms_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor ms_colorWithHexString:@"#F3091C"] forState:UIControlStateSelected];
        btn.selected = model.isSelected;
        btn.tag = i;
        [self.contentView addSubview:btn];
        [self.btns addObject:btn];
        [btn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i < self.datas.count - 1) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn.frame)-0.5, self.contentView.width, 1)];
            line.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
            [self.contentView addSubview:line];
        }
    }
}

- (void)tap:(UIButton *)button {
    for (int i = 0; i < self.datas.count; i++) {
        MSFundsFlowModel *model = self.datas[i];
        UIButton *btn = self.btns[i];
        model.isSelected = NO;
        btn.selected = model.isSelected;
    }
    button.selected = YES;
    MSFundsFlowModel *selectedModel = self.datas[button.tag];
    if (self.blcok) {
        self.blcok(selectedModel.recordTypeIndex);
    }
    [self removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        return;
    }
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
}

- (void)removeFromSuperview {
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}
@end
