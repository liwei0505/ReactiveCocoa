//
//  MSPickerContainerViewController.h
//  Sword
//
//  Created by lee on 16/6/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPickerContainerViewController : UIViewController

@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIPickerView *pickerView;

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
