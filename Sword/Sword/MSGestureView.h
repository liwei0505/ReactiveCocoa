//
//  MSGestureView.h
//  Sword
//
//  Created by haorenjie on 16/7/4.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IGestureInputResultDelegate <NSObject>

- (void)onGestureInputResult:(NSArray *)password;

@end

@interface MSGestureView : UIView

typedef NS_ENUM(NSInteger, PatternLockStatus) {
    PATTERN_LOCK_ST_NORMAL,
    PATTERN_LOCK_ST_ERROR,
};

@property (weak, nonatomic) id<IGestureInputResultDelegate> delegate;
@property (assign, nonatomic) PatternLockStatus lockStatus;
@property (assign, nonatomic) BOOL clip;


@end
