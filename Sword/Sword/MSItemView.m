//
//  MSItemView.m
//  Sword
//
//  Created by lee on 16/11/7.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSItemView.h"
#import "MSLog.h"
#import "UIColor+StringColor.h"
#import "UIButton+Custom.h"

@interface MSItemView()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *leftIcon;

@end

@implementation MSItemView

- (void)itemViewIcon:(NSString *)icon placeholder:(NSString *)placeholder {

    [self itemViewIcon:icon placeholder:placeholder item:@"delete"];
    
}

- (void)itemsViewIcon:(NSString *)icon placeholder:(NSString *)placeholder {
    
    [self itemViewIcon:icon placeholder:placeholder leftItem:@"delete" rightItem:@"hide" selected:@"show"];
}

#pragma mark - private

- (void)itemViewIcon:(NSString *)icon placeholder:(NSString *)placeholder item:(NSString *)item {
    
    [self setupLeftIcon:icon item:item selected:nil];
    
    self.textField = [MSTextField ms_createWithPlaceholder:placeholder];
    [self addSubview:self.textField];
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldValueChanged) forControlEvents:UIControlEventEditingChanged];
    [self.textField setTranslatesAutoresizingMaskIntoConstraints:NO];
   
    if (icon) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftIcon]-10-[textField]-0-[rightButton]" options:0 metrics:nil views:@{@"leftIcon":self.leftIcon,@"textField":self.textField,@"rightButton":self.rightButton}]];
        
    } else {

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[textField]-0-[rightButton]" options:0 metrics:nil views:@{@"textField":self.textField,@"rightButton":self.rightButton}]];
        
    }
    
    [self layoutSubviews];

}

- (void)itemViewIcon:(NSString *)icon placeholder:(NSString *)placeholder leftItem:(NSString *)left rightItem:(NSString *)right selected:(NSString *)selected {

    [self setupLeftIcon:icon item:right selected:selected];
   
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:left] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(itemLeftClick) forControlEvents:UIControlEventTouchUpInside];
    self.leftButton = button;
    [self addSubview:self.leftButton];
    [self.leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[left(30)]-0-[right]" options:0 metrics:nil views:@{@"left":self.leftButton,@"right":self.rightButton}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.rightButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    self.textField = [MSTextField ms_createWithPlaceholder:placeholder];
    [self addSubview:self.textField];
    [self.textField addTarget:self action:@selector(textFieldValueChanged) forControlEvents:UIControlEventEditingChanged];
    [self.textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftIcon]-10-[textField]-0-[leftButton]" options:0 metrics:nil views:@{@"leftIcon":self.leftIcon,@"textField":self.textField,@"leftButton":self.leftButton}]];
    
    [self layoutSubviews];
    
}

- (void)setupLeftIcon:(NSString *)icon item:(NSString *)item selected:(NSString *)selected {

    self.backgroundColor = [UIColor whiteColor];
    
    if (icon) {
        self.leftIcon = [[UIImageView alloc] init];
        self.leftIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.leftIcon setImage:[UIImage imageNamed:icon]];
        [self addSubview:self.leftIcon];
        [self.leftIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[icon(20)]" options:0 metrics:nil views:@{@"icon":self.leftIcon}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftIcon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftIcon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:item] forState:UIControlStateNormal];
    if (selected) {
        [button setImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
    }
    self.rightButton = button;
    [self.rightButton addTarget:self action:@selector(itemRightClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightButton];
    [self.rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(30)]-16-|" options:0 metrics:nil views:@{@"button":self.rightButton}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

}

- (void)itemRightClick {
    
    if ([self.delegate respondsToSelector:@selector(itemViewRightButtonClick:)]) {
        [self.delegate itemViewRightButtonClick:self.rightButton];
    }
}

- (void)itemLeftClick {
    
    if ([self.delegate respondsToSelector:@selector(itemViewLeftButtonClick:)]) {
        [self.delegate itemViewLeftButtonClick:self.leftButton];
    }
}

- (void)textFieldValueChanged {

    if ([self.delegate respondsToSelector:@selector(itemViewTextFieldValueChanged:)]) {
        [self.delegate itemViewTextFieldValueChanged:self.textField];
    }
}

@end
