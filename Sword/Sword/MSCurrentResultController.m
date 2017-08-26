//
//  MSCurrentResultController.m
//  Sword
//
//  Created by msj on 2017/4/8.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSCurrentResultController.h"
#import "NSDate+Add.h"
#import "UIView+FrameUtil.h"
#import "UIImage+color.h"

#define screenWidth    [UIScreen mainScreen].bounds.size.width
#define screenHeight   [UIScreen mainScreen].bounds.size.height

@interface MSCurrentResultController ()
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic) MSCurrentResultMode mode;
@property (strong, nonatomic) NSMutableArray *times;
@property (strong, nonatomic) NSArray *tips;

@property (strong, nonatomic) NSMutableArray *circles;
@end

@implementation MSCurrentResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configueElement];
    [self addSubViews];
}

- (void)updateWithTimes:(NSArray *)times mode:(MSCurrentResultMode)mode {
    self.times = [NSMutableArray array];
    for (NSNumber *value in times) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:value.longValue];
        NSString *time = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)date.year,(long)date.month,(long)date.day];
        [self.times addObject:time];
    }
    self.mode = mode;
}

#pragma mark - Private
- (void)configueElement {
    self.view.backgroundColor = [UIColor whiteColor];
    self.circles = [NSMutableArray array];
    if (self.mode == MSCurrentResultModeRedeem) {
        self.navigationItem.title = @"申请结果";
        self.message = @"申请成功";
        self.tips = @[@"赎回申请", @"预计到账"];
    }else if (self.mode == MSCurrentResultModePurchase){
        self.navigationItem.title = @"投资结果";
        self.message = @"投资成功";
        self.tips = @[@"投资申请", @"开始计息", @"收益到账"];
    }
}

- (void)addSubViews {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, screenHeight - 64)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - 110) / 2.0, 80, 110, 110)];
    imageView.image = [UIImage imageNamed:@"current_success"];
    [scrollView addSubview:imageView];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 15, self.view.width, 16)];
    lbTitle.text = self.message;
    lbTitle.textColor = [UIColor ms_colorWithHexString:@"#83E560"];
    lbTitle.textAlignment = NSTextAlignmentCenter;
    lbTitle.font = [UIFont boldSystemFontOfSize:16];
    [scrollView addSubview:lbTitle];
    
    CGFloat width = (self.view.width - 70) / self.times.count;
    for (int i = 0; i < self.times.count; i++) {
        UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(35 + width * i, CGRectGetMaxY(lbTitle.frame) + 75, width, 12)];
        lbTime.text = self.times[i];
        lbTime.font = [UIFont systemFontOfSize:12];
        
        UILabel *lbTips = [[UILabel alloc] initWithFrame:CGRectMake(35 + width * i, CGRectGetMaxY(lbTime.frame) + 23, width, 16)];
        lbTips.text = self.tips[i];
        lbTips.font = [UIFont systemFontOfSize:14];
        
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lbTime.frame) + 6, 8, 8)];
        circle.backgroundColor = [UIColor whiteColor];
        circle.layer.cornerRadius = 4;
        circle.layer.masksToBounds = YES;
        circle.layer.borderWidth = 1;
        
        if (i == 0) {
            lbTime.textColor = [UIColor ms_colorWithHexString:@"#83E560"];
            lbTime.textAlignment = NSTextAlignmentLeft;
            
            lbTips.textColor = [UIColor ms_colorWithHexString:@"#83E560"];
            lbTips.textAlignment = NSTextAlignmentLeft;
            
            circle.x = lbTime.x;
            circle.layer.borderColor = [UIColor ms_colorWithHexString:@"#83E560"].CGColor;
            
        }else if (i == self.times.count - 1){
            lbTime.textColor = [UIColor ms_colorWithHexString:@"#B5B5B5"];
            lbTime.textAlignment = NSTextAlignmentRight;
            
            lbTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
            lbTips.textAlignment = NSTextAlignmentRight;
            
            circle.x = self.view.width - 35 - 8;
            circle.layer.borderColor = [UIColor ms_colorWithHexString:@"#DCDCDC"].CGColor;
        }else {
            lbTime.textColor = [UIColor ms_colorWithHexString:@"#B5B5B5"];
            lbTime.textAlignment = NSTextAlignmentCenter;
            
            lbTips.textColor = [UIColor ms_colorWithHexString:@"#666666"];
            lbTips.textAlignment = NSTextAlignmentCenter;
            
            circle.centerX = lbTime.centerX;
            circle.layer.borderColor = [UIColor ms_colorWithHexString:@"#DCDCDC"].CGColor;
        }
        [scrollView addSubview:lbTime];
        [scrollView addSubview:lbTips];
        [scrollView addSubview:circle];
        [self.circles addObject:circle];
    }
    
    CGFloat lineW = (self.view.width - 70 - (self.circles.count - 1) * 2 * 4 - self.circles.count * 8) / (self.circles.count - 1);
    CGFloat lineH = 1;
    for (int i = 0; i < self.circles.count - 1; i++) {
        UIView *circle = self.circles[i];
        CGFloat lineX = CGRectGetMaxX(circle.frame) + 4;
        CGFloat lineY = circle.centerY;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
        line.backgroundColor = [UIColor ms_colorWithHexString:@"#DCDCDC"];
        if (i == 0) {
            UIView *subLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineW / 2.0, lineH)];
            subLine.backgroundColor = [UIColor ms_colorWithHexString:@"#83E560"];
            [line addSubview:subLine];
        }
        [scrollView addSubview:line];
    }
    
    UIButton *btnDetail = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lbTitle.frame) + 203, self.view.width - 40, 44)];
    [btnDetail setTitle:@"查看详情" forState:UIControlStateNormal];
    [btnDetail setTitleColor:[UIColor ms_colorWithHexString:@"#FC646B"] forState:UIControlStateNormal];
    [btnDetail setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor whiteColor] withSize:CGSizeMake(self.view.width - 40, 44)] forState:UIControlStateNormal];
    [btnDetail setBackgroundImage:[UIImage ms_createImageWithColor:[UIColor ms_colorWithHexString:@"FFCACC"] withSize:CGSizeMake(self.view.width - 40, 44)] forState:UIControlStateHighlighted];
    btnDetail.layer.cornerRadius = 4;
    btnDetail.layer.borderColor = [UIColor ms_colorWithHexString:@"#FC646B"].CGColor;
    btnDetail.layer.borderWidth = 1;
    btnDetail.layer.masksToBounds = YES;
    @weakify(self);
    [[btnDetail rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [scrollView addSubview:btnDetail];
    
    scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(btnDetail.frame) + 1);
    
}
@end
