//
//  MSFormInfo.h
//  Sword
//
//  Created by haorenjie on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "ZKProtocol.h"

@interface MSFormInfo : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic, readonly) NSData *data;

@end
