//
//  MSPolicyFooterView.h
//  Sword
//
//  Created by msj on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPolicyFooterView : UIView
@property (strong, nonatomic) InsurancePolicy *policy;
@property (copy, nonatomic) void (^cancelBlock)(void);
@property (copy, nonatomic) void (^payBlock)(void);
@end
