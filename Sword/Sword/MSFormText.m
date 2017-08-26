//
//  MSFormText.m
//  Sword
//
//  Created by haorenjie on 2017/6/19.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSFormText.h"

@implementation MSFormText

- (NSData *)data {
    return [self.text dataUsingEncoding:NSUTF8StringEncoding];
}

@end
