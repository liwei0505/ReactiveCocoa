//
//  MSSetTradePasswordView.h
//  Sword
//
//  Created by lee on 2017/7/3.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSSetTradePasswordView;
@protocol MSSetTradePasswordViewDelegate <NSObject>

@optional
- (void)passWordDicChange:(MSSetTradePasswordView *)view;
- (void)passWordCompleteInput:(NSString *)password;

@end

@interface MSSetTradePasswordView : UIView

- (void)clear;
@property (nonatomic, weak) id<MSSetTradePasswordViewDelegate> delegate;

@end
