//
//  MSRulesAlertView.h
//  Sword
//
//  Created by lee on 16/6/27.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSRulesAlertViewDelegate

- (void)alertViewButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface MSRulesAlertView : UIView <MSRulesAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)
@property (nonatomic, assign) id<MSRulesAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(MSRulesAlertView *alertView, int buttonIndex) ;

- (id)init;

/*!
 DEPRECATED: Use the [CustomIOS7AlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)alertViewButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(MSRulesAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)dealloc;


@end
