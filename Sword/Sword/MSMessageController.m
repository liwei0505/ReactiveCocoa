//
//  MSMessageController.m
//  Sword
//
//  Created by lee on 16/7/1.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSMessageController.h"
#import "MSWebViewController.h"
#import "MSMessageCell.h"
#import "MessageInfo.h"
#import "UIView+FrameUtil.h"
#import "MSMessageView.h"
#import "MSNoticeView.h"
#import "MSMessageHeaderView.h"

@interface MSMessageController()
@property (strong, nonatomic) MSMessageHeaderView *headerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MSMessageView *messageView;
@property (strong, nonatomic) MSNoticeView *noticeView;
@end
@implementation MSMessageController

#pragma mark - lazy
- (MSMessageView *)messageView {
    if (!_messageView) {
        _messageView = [[MSMessageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.scrollView.height)];
    }
    return _messageView;
}

- (MSNoticeView *)noticeView {
    if (!_noticeView) {
        _noticeView = [[MSNoticeView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.scrollView.height)];
    }
    return _noticeView;
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.navigationItem.title pageId:177 params:nil];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}
   
#pragma mark - Private
- (void)addSubViews {
    self.navigationItem.title = @"消息和公告";
    self.view.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    
    @weakify(self);
    self.headerView = [[MSMessageHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 48)];
    [self.view addSubview:self.headerView];
    self.headerView.block = ^(MESSAGE_TYPE type) {
        @strongify(self);
        if (type == MESSAGE) {
            if (!self.messageView.superview) {
                [self.scrollView addSubview:self.messageView];
            }
            self.scrollView.contentOffset = CGPointMake(0, 0);
        } else if (type == NOTICE){
            if (!self.noticeView.superview) {
                [self.scrollView addSubview:self.noticeView];
            }
            self.scrollView.contentOffset = CGPointMake(self.view.width, 0);
        }
    };
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+8, self.view.width, [UIScreen mainScreen].bounds.size.height - 64 - self.headerView.height - 8)];
    self.scrollView.backgroundColor = [UIColor ms_colorWithHexString:@"#f8f8f8"];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.width * 2, 0);
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
    self.scrollView.pagingEnabled = NO;
    self.scrollView.scrollEnabled = NO;
    [self.scrollView addSubview:self.messageView];
}

@end
