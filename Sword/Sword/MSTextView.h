//
//  MSTextView.h
//  feedback
//
//  Created by lee on 2017/5/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTextView : UITextView
@property (copy, nonatomic) NSString *placeholder;
@property (copy, nonatomic) void(^textCountBlock)(NSInteger);
@end
