//
//  MSRedEnvelopHeaderView.h
//  Sword
//
//  Created by msj on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSRedEnvelopHeaderView : UIView
@property (assign, nonatomic, readonly) RedEnvelopeStatus status;
@property (copy, nonatomic) void (^block)(RedEnvelopeStatus status);
@end
