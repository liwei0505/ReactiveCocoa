//
//  HotelTitleViewModel.h
//  RAClearn
//
//  Created by lw on 2018/4/17.
//  Copyright © 2018年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotelTitleViewModel : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *inputText;
@property (strong, nonatomic) RACSignal *titleSignal;
@end
