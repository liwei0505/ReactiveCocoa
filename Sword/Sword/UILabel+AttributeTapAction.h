//
//  UILabel+AttributeTapAction.h
//  自定义button
//
//  Created by lee on 17/1/6.
//  Copyright © 2017年 lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttributeModel : NSObject

@property (nonatomic, copy) NSString *str;
@property (nonatomic, assign) NSRange range;

@end

@interface UILabel (AttributeTapAction)

- (void)addAttributeTapActionWithStrings:(NSArray *)strings tapClicked:(void (^) (NSString *sting, NSRange range, NSInteger index))tapClick;

@end
