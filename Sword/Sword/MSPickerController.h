//
//  MSPickerController.h
//  Sword
//
//  Created by lee on 16/6/23.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSPickerController;

@protocol MSPickerControllerDelegate <NSObject>

@optional

- (void)pickerController:(MSPickerController *)pickerController didSelectAtIndex:(NSInteger)index;
- (void)pickerControllerDidCancel:(MSPickerController *)pickerController;

@end

@interface MSPickerController : NSObject

@property (nonatomic, assign) id<MSPickerControllerDelegate>delegate;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, readonly) NSInteger selectedIndex;

+ (id)pickerController;

- (void)showWithViewController:(UIViewController*)viewController
                          item:(id)item
                      animated:(BOOL)animated
                    completion:(void (^)(void))completion;

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end
