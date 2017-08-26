//
//  ProjectInfo.m
//  Sword
//
//  Created by lee on 16/6/2.
//  Copyright © 2016年 mjsfax. All rights reserved.
//

#import "ProjectInfo.h"

@implementation ProductInfo

- (instancetype)init
{
    if (self = [super init]) {
        _projectInfo = [[ProjectInfo alloc] init];
    }
    return self;
}

@end

@implementation ProjectInfo

- (BOOL)empty
{
    return (_name == nil);
}

@end

@implementation ProductFileInfo

@end
