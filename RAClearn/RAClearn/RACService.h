//
//  RACService.h
//  RAClearn
//
//  Created by lee on 2017/10/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RACService : NSObject
- (void)qurey;
- (void)login:(void(^)(BOOL status))completion;
@end
