//
//  MSPageParams.h
//  Sword
//
//  Created by lee on 17/2/13.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSPageParams : NSObject

@property (assign, nonatomic) int pageId;
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSDictionary *params;

@end
