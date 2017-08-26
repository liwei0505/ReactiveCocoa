//
//  MSFeedbackController.m
//  feedback
//
//  Created by lee on 2017/5/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSFeedbackController.h"
#import "UIColor+StringColor.h"
#import "MSTextView.h"
#import "MSPhotoSelector.h"
#import "MSTextUtils.h"
#import "MSCommonButton.h"
#import "FeedbackInfo.h"
#import "FileManager.h"
#import "TimeUtils.h"
#import "MSCheckInfoUtils.h"
#import "MSFeedbackLoadView.h"

@interface MSFeedbackController ()<UITextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MSTextView *textView;
@property (strong, nonatomic) UILabel *lbTextCount;
@property (strong, nonatomic) MSCommonButton *commit;
@property (strong, nonatomic) MSPhotoSelector *photoView;
@property (strong, nonatomic) UIView *contactView;
@property (strong, nonatomic) UITextField *phoneText;
@property (assign, nonatomic) float keyboardHeight;
@property (strong, nonatomic) UIView *mask;
@property (strong, nonatomic) MSFeedbackLoadView *feedbackLoadView;

@end

@implementation MSFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self prepare];
    [self setupMaskView];
    __weak typeof(self)weakSelf = self;
    [[[MSAppDelegate getServiceManager] queryMyInfo] subscribeNext:^(AccountInfo *info) {
        weakSelf.phoneText.text = info.phoneNumber;
    } error:^(NSError *error) {

    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pageEventWithTitle:self.title pageId:184 params:nil];
}

- (void)dealloc {
    [self clearCacheImage];
}

- (void)prepare {

    self.title = @"意见反馈";
    float width = self.view.bounds.size.width;
    float margin = 16;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, self.view.frame.size.height-44)];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, width-2*margin, 140)];
    inputView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:inputView];
    
    MSTextView *textView = [[MSTextView alloc] initWithFrame:CGRectMake(margin, 0, width-3*margin, 120)];
    textView.font = [UIFont systemFontOfSize:14];
    textView.placeholder = @"请写下宝贵意见";
    self.textView = textView;
    [inputView addSubview:self.textView];
    
    UILabel *lbTextCount = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.textView.frame), width-3*margin, 20)];
    lbTextCount.textAlignment = NSTextAlignmentRight;
    lbTextCount.font = [UIFont systemFontOfSize:14];
    lbTextCount.textColor = [UIColor ms_colorWithHexString:@"CCCCCC"];
    lbTextCount.text = @"0/200";
    self.lbTextCount = lbTextCount;
    [inputView addSubview:self.lbTextCount];
    
    __weak typeof(self)weakSelf = self;
    self.textView.textCountBlock = ^(NSInteger count) {
        if (count) {
            weakSelf.lbTextCount.text = [NSString stringWithFormat:@"%ld/200",(long)count];
            weakSelf.commit.enabled = YES;
        } else {
            weakSelf.lbTextCount.text = [NSString stringWithFormat:@"%ld/200",(long)count];
            weakSelf.commit.enabled = NO;
        }
    };
    
    self.photoView = [[MSPhotoSelector alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(inputView.frame)+margin, width-margin, 48)];
    [self.scrollView addSubview:self.photoView];
    
    self.contactView = [[UIView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(self.photoView.frame)+margin, width-2*margin, 44)];
    self.contactView.backgroundColor = [UIColor whiteColor];
    self.contactView.layer.cornerRadius = 4;
    self.contactView.layer.masksToBounds = YES;
    [self.scrollView addSubview:self.contactView];
    
    UILabel *lbPhone = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, 70, 44)];
    lbPhone.font = [UIFont systemFontOfSize:14];
    lbPhone.textColor = [UIColor ms_colorWithHexString:@"CCCCCC"];
    lbPhone.text = @"联系方式:";
    [self.contactView addSubview:lbPhone];
    
    UITextField *phoneText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lbPhone.frame), 0, self.contactView.bounds.size.width-CGRectGetMaxX(lbPhone.frame), 44)];
    phoneText.font = [UIFont systemFontOfSize:14];
    phoneText.textColor = [UIColor ms_colorWithHexString:@"CCCCCC"];
    self.phoneText = phoneText;
    self.phoneText.delegate = self;
    [self.contactView addSubview:self.phoneText];
    
    MSCommonButton *commit = [MSCommonButton buttonWithType:UIButtonTypeCustom];
    commit.frame = CGRectMake(margin, CGRectGetMaxY(self.contactView.frame)+margin, width-2*margin, 64);
    [commit setTitle:@"提交" forState:UIControlStateNormal];
    commit.enabled = NO;
    [commit addTarget:self action:@selector(commitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.commit = commit;
    [self.scrollView addSubview:self.commit];

}

- (void)commitButtonClick {

    [self.textView endEditing:YES];
    if (![MSCheckInfoUtils phoneNumCheckout:self.phoneText.text]) {
        [MSToast show:@"请输入正确的联系方式"];
        return;
    }
    
    [FileManager renameFile:[self getLogFilePath:[FileManager getLogsDirPath]] toName:[self getLogFilePath:[FileManager getFeedbackDirPath]]];
    [self load];
    
    
    __weak typeof(self)weakSelf = self;
    FeedbackInfo *feedbackInfo = [[FeedbackInfo alloc] init];
    feedbackInfo.suggestion = self.textView.text;
    feedbackInfo.contactInfo = self.phoneText.text;
    feedbackInfo.attachment = [FileManager getFeedbackDirPath];
    [[[MSAppDelegate getServiceManager] feedback:feedbackInfo] subscribeError:^(NSError *error) {
        [weakSelf remove];
        [MSAlert showWithTitle:@"提示" message:@"可能网络出了点问题，意见反馈提交失败！" buttonClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                [weakSelf commitButtonClick];
            }
        } cancelButtonTitle:@"返回" otherButtonTitles:@"重新提交", nil];
    } completed:^{
        [weakSelf complete];
    }];
}

#pragma mark - delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //    float space = self.scrollView.bounds.size.height-64 - self.contactView.frame.origin.y-44;
    //    float height = 300 - space;
    //    NSLog(@"%f",height);
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.scrollView.contentOffset = CGPointMake(0, 100);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.scrollView.contentOffset = CGPointZero;
    }];
}

- (NSString *)getLogFilePath:(NSString *)path {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd"];
    NSDate *now = [TimeUtils date];
    NSString *filename = [[formatter stringFromDate:now] stringByAppendingPathExtension:@"log"];
    NSString *fullname = [path stringByAppendingPathComponent:filename];
    return fullname;
}

#pragma mark - mask view

- (void)setupMaskView {
    
    _mask = [[UIView alloc] initWithFrame:self.view.bounds];
    _mask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remove)];
    [_mask addGestureRecognizer:tap];
    self.feedbackLoadView.center = CGPointMake(self.view.center.x, self.view.center.y-100);
    [_mask addSubview:self.feedbackLoadView];

}

- (MSFeedbackLoadView *)feedbackLoadView {

    if (!_feedbackLoadView) {
        _feedbackLoadView = [[MSFeedbackLoadView alloc] initWithFrame:CGRectMake(0, 0, 180, 100)];
    }
    return _feedbackLoadView;
}

- (void)load {
    
    [self.feedbackLoadView updateTitle:@"提交中..." load:YES];
    [self.view insertSubview:self.mask atIndex:100];
    
}

- (void)complete {

    [self.feedbackLoadView updateTitle:@"提交成功，感谢您的反馈" load:NO];
    [self performSelector:@selector(pop) withObject:nil afterDelay:2.0];
    
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)remove {

    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:1 animations:^{
        [weakSelf.mask removeFromSuperview];
    }];
    
}

- (void)clearCacheImage {
    
    [FileManager deleteFile:[FileManager getFeedbackDirPath]];

}

@end
