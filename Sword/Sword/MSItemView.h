//
//  MSItemView.h
//  Sword
//
//  Created by lee on 16/11/7.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSTextField.h"

@protocol MSItemViewDelegate <NSObject>

@optional
- (void)itemViewTextFieldValueChanged:(MSTextField *)textField;
- (void)itemViewRightButtonClick:(UIButton *)button;
- (void)itemViewLeftButtonClick:(UIButton *)button;

@end

@interface MSItemView : UIView

@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) MSTextField *textField;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, weak) id<MSItemViewDelegate> delegate;

- (void)itemViewIcon:(NSString *)icon placeholder:(NSString *)placeholder;
- (void)itemsViewIcon:(NSString *)icon placeholder:(NSString *)placeholder;

@end
