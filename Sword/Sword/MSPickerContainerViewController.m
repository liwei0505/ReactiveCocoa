//
//  MSPickerContainerViewController.m
//  Sword
//
//  Created by lee on 16/6/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPickerContainerViewController.h"
#import "MSTransitionAnimator.h"
//#import "MSConfig.h"

const NSInteger MSOKButtonHeight = 44;
const NSInteger MSContentHeight = 216;

@interface MSPickerContainerViewController ()

@property (assign, nonatomic) BOOL onShow;

@end

@implementation MSPickerContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundButton.backgroundColor = [UIColor clearColor];
    self.backgroundButton.frame = bounds;
    
    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.okButton setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_normal"] forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_disable"] forState:UIControlStateDisabled];
    [self.okButton setBackgroundImage:[UIImage imageNamed:@"ms_btn_bottom_highlight"] forState:UIControlStateHighlighted];
    [self.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okButton setTitle:NSLocalizedString(@"str_confirm", @"") forState:UIControlStateNormal];
    self.okButton.frame = CGRectMake(0, bounds.size.height, bounds.size.width, MSOKButtonHeight);
    
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, bounds.size.height, bounds.size.width, MSContentHeight + MSOKButtonHeight)];
    self.pickerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.view addSubview:self.backgroundButton];
    [self.view addSubview:self.okButton];
    [self.view addSubview:self.pickerView];
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    CGRect bounds = self.view.bounds;
    self.backgroundButton.frame = bounds;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.okButton.frame = CGRectMake(0, bounds.size.height - MSContentHeight - MSOKButtonHeight, bounds.size.width, MSOKButtonHeight);
        self.pickerView.frame = CGRectMake(0, bounds.size.height - MSContentHeight, bounds.size.width, MSContentHeight);
        self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    } completion:^(BOOL finished) {
        if (completion) {
            _onShow = YES;
            completion();
        }
    }];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    CGRect bounds = self.view.bounds;
    self.backgroundButton.frame = bounds;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.okButton.frame = CGRectMake(0, bounds.size.height, bounds.size.width, MSOKButtonHeight);
        self.pickerView.frame = CGRectMake(0, bounds.size.height + MSOKButtonHeight, bounds.size.width, MSContentHeight);
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        if (completion) {
            _onShow = NO;
            completion();
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
