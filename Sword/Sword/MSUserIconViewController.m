//
//  MSUserIconViewController.m
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSUserIconViewController.h"
#import "UIView+FrameUtil.h"
#import "UIColor+StringColor.h"
#import "MSTemporaryCache.h"
#import "MSUserIconButton.h"

@interface MSUserIconViewController ()
@property (strong, nonatomic) MSUserIconButton *currentSelectedBtn;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation MSUserIconViewController

#pragma mark - Life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self conFigure];
    [self addSubViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.navigationItem.title pageId:179 params:nil];
}

#pragma mark - Private
- (void)conFigure {
    self.navigationItem.title = @"修改头像";
}

- (void)addSubViews {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [UIScreen mainScreen].bounds.size.height - 64)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 48, 0);
    self.scrollView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.scrollView];
    
    CGFloat distanceX = (self.view.width - 192 - 47) / 2.0;
    CGFloat distanceY = 58 * scaleY;
    CGFloat width = 96;
    CGFloat height = width;
    for (int i = 0; i < 6; i++) {
        int col = i % 2;//列
        int row = i / 2;//行
        MSUserIconButton *btn = [[MSUserIconButton alloc] initWithFrame:CGRectMake(distanceX + (47+width)*col, distanceY + (height+56)*row, width, height)];
        NSString *normal = [NSString stringWithFormat:@"user_icon_normal_%d",i+1];
        NSString *selected = [NSString stringWithFormat:@"user_icon_selected_%d",i+1];
        btn.tag = i+1;
        [btn setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btn];
        self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(btn.frame) + 20);

        NSString *currentSelected = [MSTemporaryCache getTemporaryUserIcon] ?: @"user_icon_normal_1";
        if ([normal isEqualToString:currentSelected]) {
            btn.selected = YES;
            self.currentSelectedBtn = btn;
        }
    }
    
    @weakify(self);
    UIButton *completedBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64 - 48, self.view.width, 48)];
    [completedBtn setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [completedBtn setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    [completedBtn setTitle:@"就选Ta了" forState:UIControlStateNormal];
    [self.view addSubview:completedBtn];
    [[completedBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [MSTemporaryCache saveTemporaryUserIcon:[NSString stringWithFormat:@"user_icon_normal_%ld",(long)self.currentSelectedBtn.tag]];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)tap:(MSUserIconButton *)btn {
    if (self.currentSelectedBtn == btn) {
        return;
    }
    btn.selected = YES;
    self.currentSelectedBtn.selected = NO;
    self.currentSelectedBtn = btn;
}

@end
