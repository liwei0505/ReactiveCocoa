//
//  MSSegmentView.h
//  Sword
//
//  Created by msj on 2017/8/7.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SegmentType) {
    Segment_Invest,
    Segment_Secure
};

@interface MSSegmentView : UIView
@property (assign, nonatomic) SegmentType type;
@property (copy, nonatomic) void (^block)(SegmentType type);
@end
