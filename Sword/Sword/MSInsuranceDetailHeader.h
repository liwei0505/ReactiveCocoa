//
//  MSInsuranceDetailHeader.h
//  Sword
//
//  Created by lee on 2017/8/10.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSInsuranceDetailHeader : UIView
@property (strong, nonatomic) InsuranceDetail *detail;
@property (copy, nonatomic) void(^backButtonClick)(void);
@end
