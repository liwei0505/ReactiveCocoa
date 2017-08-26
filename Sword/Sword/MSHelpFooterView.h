//
//  MSHelpFooterView.h
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HELP_TYPE) {
    HELP_FEEDBACK,
    HELP_CALL
};

@interface MSHelpFooterView : UIView
@property (copy, nonatomic) void (^block)(HELP_TYPE type);
@end
