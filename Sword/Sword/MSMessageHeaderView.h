//
//  MSMessageHeaderView.h
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MESSAGE_TYPE) {
    MESSAGE,
    NOTICE
};

@interface MSMessageHeaderView : UIView
@property (assign, nonatomic, readonly) MESSAGE_TYPE type;
@property (copy, nonatomic) void (^block)(MESSAGE_TYPE type);
@end
