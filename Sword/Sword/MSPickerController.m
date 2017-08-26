//
//  MSPickerController.m
//  Sword
//
//  Created by lee on 16/6/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "MSPickerController.h"
#import "MSPickerContainerViewController.h"
#import "MSTransitionAnimator.h"

@interface MSPickerController()<UIPickerViewDataSource, UIPickerViewDelegate,
UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) MSPickerContainerViewController *containerViewController;

@end

@implementation MSPickerController

+ (id)pickerController {
    MSPickerController *pickerController = [MSPickerController new];
    return pickerController;
}

- (void)showWithViewController:(UIViewController*)viewController
                          item:(id)item
                      animated:(BOOL)animated
                    completion:(void (^)(void))completion {
    CGRect rBounds = viewController.view.bounds;
    
    self.containerViewController = [MSPickerContainerViewController new];
    self.containerViewController.view.frame = rBounds;
    
    self.containerViewController.pickerView.dataSource = self;
    self.containerViewController.pickerView.delegate = self;
    
    [self.containerViewController.backgroundButton addTarget:self action:@selector(onDismissButtonPressed:)
                                            forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerViewController.okButton addTarget:self action:@selector(onOKButtonPressed:)
                                    forControlEvents:UIControlEventTouchUpInside];
    
    self.containerViewController.transitioningDelegate = self;
    self.containerViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    __block BOOL animatedBlk = animated;
    [viewController presentViewController:self.containerViewController
                                 animated:animated
                               completion:^{
                                   if (item) {
                                       for (NSInteger i = 0; i < self.items.count; i++) {
                                           if ([self.items[i] isEqual:item]) {
                                               [self.containerViewController.pickerView selectRow:i
                                                                                      inComponent:0
                                                                                         animated:animatedBlk];
                                               break;
                                           }
                                       }
                                       if (completion) {
                                           completion();
                                       }
                                   } else {
                                       [self.containerViewController.pickerView selectRow:_selectedIndex
                                                                              inComponent:0
                                                                                 animated:animatedBlk];
                                       if (completion) {
                                           completion();
                                       }
                                   }
                               }];
}

- (IBAction)onDismissButtonPressed:(id)sender {
    [self.containerViewController dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pickerControllerDidCancel:)]) {
            [self.delegate pickerControllerDidCancel:self];
        }
    }];
}

- (IBAction)onOKButtonPressed:(id)sender {
    _selectedIndex = [self.containerViewController.pickerView selectedRowInComponent:0];
    [self.containerViewController dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pickerController: didSelectAtIndex:)]) {
            [self.delegate pickerController:self didSelectAtIndex:_selectedIndex];
        }
    }];
}

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.containerViewController dismissViewControllerAnimated:animated
                                                     completion:completion];
}

- (MSTransitionAnimator *)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    MSTransitionAnimator *animator = [MSTransitionAnimator new];
    animator.presenting = YES;
    return animator;
}

- (MSTransitionAnimator *)animationControllerForDismissedController:(UIViewController *)dismissed {
    MSTransitionAnimator *animator = [MSTransitionAnimator new];
    animator.presenting = NO;
    return animator;
}

#pragma mark - UIPickerViewDataSource, Delegat
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.items.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44.0f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.items[row] description];
}

#pragma mark - Accessors
- (void)setItems:(NSArray *)items {
    _items = [items copy];
    
    if (_items.count) {
        _selectedIndex = 0;
    } else {
        _selectedIndex = NSNotFound;
    }
    [self.containerViewController.pickerView reloadAllComponents];
}

@end
